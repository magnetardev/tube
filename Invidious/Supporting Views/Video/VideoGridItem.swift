import InvidiousKit
import SwiftUI

struct VideoGridItem: View {
    var id: String
    var title: String
    var author: String
    var authorId: String?
    var duration: Int
    var published: String
    var thumbnails: [ThumbnailObject]
    @Environment(OpenVideoPlayerAction.self) var openPlayer
    @Environment(VideoQueue.self) var queue
    @Environment(\.openWindow) private var openWindow
    
    private var formattedDuration: String {
        (Date() ..< Date().advanced(by: TimeInterval(duration))).formatted(.timeDuration)
    }

    var body: some View {
        Button {
            Task {
                await openPlayer(id: id, openWindow: openWindow)
            }
        } label: {
            VStack(alignment: .leading) {
                ZStack {
                    ThumbnailView(width: 360.0, height: 202.5, thumbnails: thumbnails)
                    VideoThumbnailTag(self.formattedDuration)
                }
                VStack(alignment: .leading, spacing: 2.0) {
                    Text(title).lineLimit(1)
                    Text(author).lineLimit(1).foregroundStyle(.secondary)
                    Text(published).lineLimit(1).foregroundStyle(.secondary)
                }
            }
        }.buttonStyle(.plain).contextMenu(ContextMenu(menuItems: {
            Button {
                Task {
                    do {
                        try await queue.add(id: id)
                    } catch {
                        print("Error")
                    }
                }
            } label: {
                Text("Add to Queue")
            }
            if let authorId {
                NavigationLink(value: NavigationDestination.channel(authorId)) {
                    Text("View Channel")
                }
            }
        }))
    }
}
