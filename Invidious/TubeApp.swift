import InvidiousKit
import SwiftData
import SwiftUI

func getApiUrl() -> URL {
    guard let string = Bundle.main.infoDictionary?["INVIDIOUS_ORIGIN"] as? String else {
        preconditionFailure("INVIDIOUS_ORIGIN is not present")
    }
    guard let url = URL(string: "https://" + string) else  {
        preconditionFailure("INVIDIOUS_ORIGIN is not a valid URL: \(string)")
    }
    return url
}

@main
struct TubeApp: App {
    static var client = APIClient(apiUrl: getApiUrl())
    var playerState: OpenVideoPlayerAction
    var queue: VideoQueue

    init() {
        queue = VideoQueue()
        playerState = OpenVideoPlayerAction(queue: queue)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if self.playerState.isPlayerOpen {
                    NavigationStack {
                        VideoView(model: VideoViewModel())
                            .background(.windowBackground)
                    }
                } else {
                    RootView()
                }
            }
            .environment(playerState)
            .environment(queue)
            .modelContainer(for: [FollowedChannel.self])
        }
    }
}
