import SwiftUI
import InvidiousKit

struct HorizontalSwiperVideoCard: View {
    var id: String
    var title: String
    var duration: Int
    var published: String
    var thumbnails: [ThumbnailObject]
    @Environment(OpenVideoPlayerAction.self) var openPlayer
    @Environment(\.openWindow) var openWindow

    private var formattedDuration: String {
        (Date() ..< Date().advanced(by: TimeInterval(duration))).formatted(.timeDuration)
    }

    init(videoObject: VideoObject) {
        id = videoObject.videoId
        title = videoObject.title
        duration = videoObject.lengthSeconds
        published = videoObject.publishedText
        thumbnails = videoObject.videoThumbnails
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                ZStack {
                    ThumbnailView(width: 250.0, height: 140.625, radius: 8.0, thumbnails: thumbnails)
                    VideoThumbnailTag(self.formattedDuration)
                }.frame(width: 250.0, height: 140.625)
                Text(title).lineLimit(1).font(.callout)
                Text(published).lineLimit(1).foregroundStyle(.secondary).font(.callout)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 250.0)
    }

    @MainActor
    func action() {
        Task {
            await openPlayer(id: id, openWindow: openWindow)
        }
    }
}
