import InvidiousKit
import SwiftUI

enum SidebarSelection: Hashable {
    case feed
    case trending
    case search
    case channel(String)
}

enum NavigationDestination: Hashable {
    case channel(String)
    case playlist(String)
}

struct RootView: View {
    @State var selection: SidebarSelection? = .feed
    @State var path = NavigationPath()
    @State var query: String = ""
    @Environment(VideoQueue.self) var queue

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            NavigationStack(path: $path) {
                Group {
                    switch selection {
                    case .feed:
                        FeedView()
                    case .trending:
                        TrendingView(model: TrendingViewModel())
                    case .search:
                        SearchResultsView()
                    case .channel(let id):
                        ChannelView(model: ChannelViewModel(channelId: id))
                    case .none:
                        ScrollView {
                            Text("No Selection")
                        }
                    }
                }.safeAreaPadding(.bottom, 76).navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .channel(let id):
                        ChannelView(model: ChannelViewModel(channelId: id))
                    case .playlist(let id):
                        PlaylistView(model: PlaylistViewModel(playlistId: id))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            VideoMiniplayerView(queue: queue)
                .frame(height: 76)
                .background(Material.ultraThickMaterial)
        }
    }
}

