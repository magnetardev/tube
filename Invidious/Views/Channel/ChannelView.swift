import InvidiousKit
import Observation
import SwiftUI

@Observable
class ChannelViewModel {
    var channelId: String
    var loading = true
    var error: Error?
    var channel: Channel?
    var videos: [VideoObject] = []
    var selectedTab: ChannelTab = .videos(.videos)
    
    init(channelId: String) {
        self.channelId = channelId
    }
    
    enum ChannelTab: Hashable {
        case videos(ChannelVideosViewModel.VideosList)
        case playlists
        
        var displayName: String {
            switch self {
            case .videos(.videos):
                "Videos"
            case .videos(.shorts):
                "Shorts"
            case .videos(.streams):
                "Streams"
            case .playlists:
                "Playlists"
            }
        }
    }
    
    func load() async {
        loading = true
        do {
            channel = try await TubeApp.client.channel(for: channelId)
        } catch {
            print(error)
            self.error = error
        }
        loading = false
    }
}

struct ChannelView: View {
    @Bindable var model: ChannelViewModel
    
    var body: some View {
        ScrollView {
            if let channel = model.channel {
                ChannelHeaderView(channel: channel, selection: $model.selectedTab)
                switch model.selectedTab {
                case .videos(let list):
                    ChannelVideosView(model: ChannelVideosViewModel(list: list, channelId: model.channelId))
                case .playlists:
                    ChannelPlaylistsView(model: ChannelPlaylistsViewModel(channelId: model.channelId))
                }
            }
        }
        .navigationTitle("Channel")
        .asyncTaskOverlay(error: model.error, isLoading: model.loading)
        .task(id: model.channelId) {
            await model.load()
        }.refreshable {
            await model.load()
        }
    }
}
