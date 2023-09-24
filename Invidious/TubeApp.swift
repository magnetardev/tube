import InvidiousKit
import SwiftData
import SwiftUI

func getApiUrl() -> URL {
    guard let string = Bundle.main.infoDictionary?["INVIDIOUS_ORIGIN"] as? String else {
        preconditionFailure("INVIDIOUS_ORIGIN is not present")
    }
    guard let url = URL(string: "https://" + string) else {
        preconditionFailure("INVIDIOUS_ORIGIN is not a valid URL: \(string)")
    }
    return url
}

@main
struct TubeApp: App {
    static var client = APIClient(apiUrl: getApiUrl())
    @Bindable var playerState: OpenVideoPlayerAction
    var queue: VideoQueue

    init() {
        queue = VideoQueue()
        playerState = OpenVideoPlayerAction(queue: queue)
    }

    var playerView: some View {
        NavigationStack {
            VideoView(model: VideoViewModel())
                .background(.windowBackground)
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
            #if !os(macOS)
                .fullScreenCover(isPresented: $playerState.isPlayerOpen) {
                    playerState.isPlayerOpen = false
                } content: {
                    playerView
                }
            #endif
                .environment(playerState)
                .environment(queue)
                .modelContainer(for: [FollowedChannel.self])
        }
        WindowGroup(id: "video-player", for: String.self) { _ in
            playerView
                .environment(playerState)
                .environment(queue)
                .modelContainer(for: [FollowedChannel.self])
        } defaultValue: {
            "video-player"
        }
    }
}
