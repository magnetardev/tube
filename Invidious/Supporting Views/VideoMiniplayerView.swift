import SwiftUI

struct VideoMiniplayerView: View {
    @Environment(OpenVideoPlayerAction.self) var openPlayer
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openWindow) var openWindow
    var queue: VideoQueue

    var body: some View {
        HStack {
            if let video = queue.current {
                ThumbnailView(width: 78, height: 44, thumbnails: video.videoThumbnails)
                VStack(alignment: .leading) {
                    Text(video.title).lineLimit(1)
                    Text(video.author).lineLimit(1).foregroundStyle(.secondary)
                }
            } else {
                RoundedRectangle(cornerRadius: 4.0, style: .continuous).fill(.foreground)
                    .frame(width: 78, height: 44)
                Text("Nothing Playing").lineLimit(1)
            }
            Spacer()
            Button {
                if queue.playerQueue.timeControlStatus == .paused {
                    queue.playerQueue.play()
                } else {
                    queue.playerQueue.pause()
                }
            } label: {
                if queue.playing {
                    Label("Pause", systemImage: "pause.fill")
                } else {
                    Label("Play", systemImage: "play.fill")
                }
            }
            Button {
                queue.playerQueue.advanceToNextItem()
            } label: {
                Label("Next Entry", systemImage: "forward.fill")
            }.padding(.leading)
        }
        .padding()
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        #if os(macOS)
            .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(colorScheme == .light ? .init(white: 0.5, opacity: 0.25) : .init(white: 0.0, opacity: 0.5)), alignment: .top)
        #else
            .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundStyle(.separator).opacity(0.25), alignment: .top)
        #endif
            .tint(.primary)
            .onTapGesture {
                Task {
                    await openPlayer(id: nil, openWindow: openWindow)
                }
            }.contextMenu(ContextMenu(menuItems: {
                Button {
                    queue.clear()
                } label: {
                    Text("Clear Queue")
                }
            }))
    }
}

#Preview {
    VStack {
        Spacer()
        VideoMiniplayerView(queue: VideoQueue())
    }
}
