import SwiftUI

struct VideoQueueListView: View {
    @Environment(VideoQueue.self) var queue

    var body: some View {
        List(queue.videos) { entry in
            Button {
                queue.playerQueue.advanceToNextItem()
            } label: {
                VideoListItem(title: entry.info.title, author: entry.info.author, thumbnails: entry.info.videoThumbnails)
            }.buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Delete", role: .destructive) {
                        queue.remove(video: entry)
                    }
                }
        }.listStyle(.inset)
    }
}

#Preview {
    VideoQueueListView()
}
