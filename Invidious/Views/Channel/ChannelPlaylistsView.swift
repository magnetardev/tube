import InvidiousKit
import Observation
import SwiftUI

@Observable
class ChannelPlaylistsViewModel {
    var channelId: String
    var playlists: [PlaylistObject] = []
    var continuation: String?
    var done = false
    var loading = true
    var error: Error?

    init(channelId: String) {
        self.channelId = channelId
    }

    func load() async {
        loading = false
        do {
            let response = try await TubeApp.client.playlists(for: channelId, continuation: continuation)
            continuation = response.continuation
            if let video = playlists.first, response.playlists.firstIndex(of: video) != nil {
                done = true
            } else {
                playlists.append(contentsOf: response.playlists)
            }
        } catch {
            self.error = error
        }
        loading = false
    }
}

struct ChannelPlaylistsView: View {
    var model: ChannelPlaylistsViewModel

    var body: some View {
        LazyVStack {
            ContentGridView {
                ForEach(model.playlists, id: \.playlistId) { playlist in
                    PlaylistItemView(
                        id: playlist.playlistId,
                        title: playlist.title,
                        thumbnail: playlist.playlistThumbnail,
                        author: playlist.author,
                        videoCount: playlist.videoCount
                    )
                }
            }
            if !model.done {
                ProgressView()
                    .task(id: model.channelId) {
                        await model.load()
                    }.refreshable {
                        await model.load()
                    }
            }
        }.padding().asyncTaskOverlay(error: model.error, isLoading: model.loading)
    }
}

// #Preview {
//    ChannelPlaylistsView()
// }
