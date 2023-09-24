import SwiftUI

@Observable
final class OpenVideoPlayerAction {
    var isPlayerOpen: Bool = false
    @ObservationIgnored
    let queue: VideoQueue

    init(queue: VideoQueue) {
        self.queue = queue
    }

    public func close() {
        isPlayerOpen = false
    }

    @MainActor
    public func callAsFunction(id: String?, openWindow: OpenWindowAction) async {
        if let id {
            queue.clear()
            try? await queue.add(id: id)
        }
        #if !os(macOS)
        await MainActor.run {
            isPlayerOpen = true
        }
        #else
        openWindow(id: "video-player", value: "video-player")
        #endif
    }
}
