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
        self.isPlayerOpen = false
    }

    public func callAsFunction(id: String?) async {
        if let id {
            queue.clear()
            try? await queue.add(id: id)
        }
        await MainActor.run {
            isPlayerOpen = true
        }
    }
}
