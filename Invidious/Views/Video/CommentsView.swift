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

    func getMarkdownContent(comment: CommentsResponse.Comment) -> AttributedString? {
        return try? AttributedString(markdown: comment.content)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(model.comments, id: \.commentId) { comment in
                    VStack(alignment: .leading, spacing: 4.0) {
                        HStack {
                            ImageView(width: 32, height: 32, images: comment.authorThumbnails)
                            Text(comment.author).fontWeight(.medium)
                            Spacer()
                            Text(comment.publishedText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(comment.content).font(.subheadline).padding(.vertical, 8.0)
                        HStack {
                            Image(systemName: "hand.thumbsup")
                            Text(comment.likeCount.formatted())
                            Spacer()
                            if comment.isPinned {
                                Image(systemName: "pin.fill")
                            }
                            if comment.creatorHeart != nil {
                                Image(systemName: "heart.fill").foregroundStyle(.red)
                            }
                        }
                        .padding(.bottom)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        if comment != model.comments.last {
                            Divider()
                        }
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
