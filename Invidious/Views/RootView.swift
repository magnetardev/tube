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
    case settings
}

struct RootView: View {
    @State var selection: SidebarSelection? = .feed
    @State var path = NavigationPath()
    @State var query: String = ""
    @Environment(VideoQueue.self) var queue
    @Environment(OpenVideoPlayerAction.self) private var openPlayer
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        NavigationStack(path: $path) {
            FeedView()
            #if os(iOS)
                .safeAreaPadding(.bottom, 76)
            #endif
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .channel(let id):
                        ChannelView(model: ChannelViewModel(channelId: id))
                        #if os(iOS)
                            .safeAreaPadding(.bottom, 76)
                        #endif
                    case .playlist(let id):
                        PlaylistView(model: PlaylistViewModel(playlistId: id))
                        #if os(iOS)
                            .safeAreaPadding(.bottom, 76)
                        #endif
                    case .settings:
                        SettingsView()
                        #if os(iOS)
                            .safeAreaPadding(.bottom, 76)
                        #endif
                    }
                }
        }
        .onOpenURL { url in
            guard
                let queryItem = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first,
                let value = queryItem.value
            else {
                return
            }

            var newPath = NavigationPath()
            switch queryItem.name {
            case "playlist":
                newPath.append(NavigationDestination.playlist(value))
                path = newPath
            case "channel":
                newPath.append(NavigationDestination.channel(value))
                path = newPath
            case "video":
                Task {
                    await openPlayer(id: value, openWindow: openWindow)
                }
            default:
                return
            }
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            VideoMiniplayerView(queue: queue)
                .frame(height: 76)
                .background(Material.ultraThickMaterial)
        }
    }
}
