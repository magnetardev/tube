import InvidiousKit
import Observation
import SwiftUI

@Observable
class CommentsViewModel {
    var videoId: String
    var loading: Bool = true
    var comments: [CommentsResponse.Comment] = []
    var error: Error?

    init(videoId: String) {
        self.videoId = videoId
    }

    func load() async {
        loading = true
        do {
            let response = try await TubeApp.client.comments(for: videoId)
            comments = response.comments
        } catch {
            self.error = error
        }
        loading = false
    }
}

struct CommentsView: View {
    var model: CommentsViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(model.comments, id: \.commentId) { comment in
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(comment.author).fontWeight(.medium)
                        Text(comment.content)
                        HStack {
                            Image(systemName: "hand.thumbsup")
                            Text(comment.likeCount.formatted())
                            Spacer()
                        }.padding(.top, 4.0)
                    }
                }
            }.padding()
        }.asyncTaskOverlay(error: model.error, isLoading: model.loading)
            .task(id: model.videoId) {
                await model.load()
            }
    }
}

// #Preview {
//    CommentsView()
// }
