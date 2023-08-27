import InvidiousKit
import Observation
import SwiftUI

@Observable
class TrendingViewModel {
    var loading: Bool = true
    var videos: [VideoObject] = []
    var error: Error?

    func load() async {
        do {
            videos = try await TubeApp.client.trending(for: .news)
        } catch {
            self.error = error
        }
        loading = false
    }
}

struct TrendingView: View {
    var model: TrendingViewModel

    var body: some View {
        ScrollView {
            ContentGridView {
                ForEach(model.videos, id: \.videoId) { video in
                    VideoGridItem(
                        id: video.videoId,
                        title: video.title,
                        author: video.author, 
                        authorId: video.authorId,
                        duration: video.lengthSeconds,
                        published: video.publishedText,
                        thumbnails: video.videoThumbnails
                    )
                }
            }.padding()
        }
        .navigationTitle("Trending")
        .asyncTaskOverlay(error: model.error, isLoading: model.loading)
        .task {
            await model.load()
        }.refreshable {
            await model.load()
        }
    }
}

#Preview {
    TrendingView(model: TrendingViewModel())
}
