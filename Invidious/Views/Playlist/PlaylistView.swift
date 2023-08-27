import SwiftUI
import InvidiousKit
import Observation

@Observable
class PlaylistViewModel {
    var playlistId: String
    var title: String?
    var videos: [PlaylistObject.PlaylistVideo] = []
    var loading = true
    var error: Error?
    
    init(playlistId: String) {
        self.playlistId = playlistId
    }
    
    func load() async {
        loading = true
        do {
            let response = try await TubeApp.client.playlist(for: playlistId)
            title = response.title
            videos = response.videos
        } catch {
            print(error)
            self.error = error
        }
        loading = false
    }
}

struct PlaylistView: View {
    var model: PlaylistViewModel
    
    var body: some View {
        ScrollView {
            ContentGridView {
                ForEach(model.videos, id: \.videoId) { video in
                    VideoGridItem(
                        id: video.videoId,
                        title: video.title,
                        author: video.author ?? "Unknown Channel", 
                        authorId: nil,
                        duration: video.lengthSeconds,
                        published: "",
                        thumbnails: video.videoThumbnails
                    )
                }
            }.padding()
        }
        .navigationTitle(model.title ?? "Playlist")
        .asyncTaskOverlay(error: model.error, isLoading: model.loading)
        .task {
            await model.load()
        }.refreshable {
            await model.load()
        }
    }
}

//#Preview {
//    PlaylistView()
//}
