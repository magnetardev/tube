import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarSelection?
    @Query(sort: \FollowedChannel.name) var following: [FollowedChannel]
    @Environment(\.modelContext) private var context

    var body: some View {
        List(selection: $selection) {
            Section("Tube") {
                Label("Feed", systemImage: "doc.text.image").tag(SidebarSelection.feed)
                Label("Trending", systemImage: "chart.line.uptrend.xyaxis").tag(SidebarSelection.trending)
                Label("Search", systemImage: "magnifyingglass").tag(SidebarSelection.search)
            }
            Section("Channels") {
                ForEach(following, id: \.id) { channel in
                    Label(channel.name, systemImage: "person")
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Unfollow", role: .destructive) {
                                unfollowChannel(channel: channel)
                            }
                        }
                        .tag(SidebarSelection.channel(channel.id))
                }.listItemTint(.secondary)
            }
        }.navigationTitle("Tube")
    }

    func unfollowChannel(channel: FollowedChannel) {
        // FIXME: proper error handling
        do {
            let id = channel.id
            try context.delete(model: FollowedChannel.self, where: #Predicate { $0.id == id })
        } catch {}
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selection: .constant(SidebarSelection.feed))
    } detail: {}
}
