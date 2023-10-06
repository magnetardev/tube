import InvidiousKit
import SwiftData
import SwiftUI

@main
struct TubeApp: App {
    static var client = APIClient()
    @Bindable var playerState: OpenVideoPlayerAction
    var settings = Settings()
    var queue: VideoQueue
    @State var hasValidInstance: Bool? = nil

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
            switch hasValidInstance {
            case .some(true):
                RootView()
                #if !os(macOS)
                    .fullScreenCover(isPresented: $playerState.isPlayerOpen) {
                        playerState.isPlayerOpen = false
                    } content: {
                        playerView
                    }
                    .statusBar(hidden: false)
                #endif
            case .some(false):
                OnboardingView(hasValidInstance: $hasValidInstance)
            case .none:
                ProgressView()
                    .task {
                        await validateInstance()
                    }
            }
        }
        .environment(playerState)
        .environment(queue)
        .modelContainer(for: [FollowedChannel.self])
        .environment(settings)
        .onChange(of: settings.invidiousInstance) {
            Task {
                await validateInstance()
            }
        }
        #if os(macOS)
            WindowGroup(id: "video-player", for: String.self) { _ in
                playerView
                    .environment(playerState)
                    .environment(queue)
                    .modelContainer(for: [FollowedChannel.self])
            } defaultValue: {
                "video-player"
            }
        #endif
    }

    func validateInstance() async {
        guard
            let instanceUrlString = settings.invidiousInstance,
            let instanceUrl = URL(string: instanceUrlString)
        else {
            await MainActor.run {
                TubeApp.client.setApiUrl(url: nil)
                hasValidInstance = false
            }
            return
        }
        let response = await APIClient.isValidInstance(url: instanceUrl)
        await MainActor.run {
            if response {
                TubeApp.client.setApiUrl(url: instanceUrl)
            }
            hasValidInstance = response
        }
    }
}
