import SwiftData
import SwiftUI

struct FollowButton: View {
    var channelId: String
    var channelName: String
    @Environment(\.modelContext) private var context
    @State var isFollowed: Bool = false
    @State var loading = true

    var body: some View {
        Button {
            if isFollowed {
                // FIXME: handle failure
                do {
                    try context.delete(
                        model: FollowedChannel.self,
                        where: #Predicate { $0.id == channelId }
                    )
                    self.isFollowed = false
                } catch {}
            } else {
                context.insert(FollowedChannel(id: channelId, name: channelName, dateFollowed: Date()))
                self.isFollowed = true
            }
        } label: {
            if self.isFollowed {
                Label("Unfollow", systemImage: "heart.fill")
            } else {
                Label("Follow", systemImage: "heart")
            }
        }.disabled(loading).onAppear {
            do {
                loading = true
                let request = FetchDescriptor<FollowedChannel>(predicate: #Predicate { $0.id == channelId })
                let count = try context.fetchCount(request)
                isFollowed = count > 0
            } catch {
                // FIXME: handle failure
            }
            self.loading = false
        }
    }
}

// #Preview {
//    FollowButton()
// }
