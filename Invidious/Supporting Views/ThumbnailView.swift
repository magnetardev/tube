import InvidiousKit
import SwiftUI

struct ThumbnailView: View {
    let width: CGFloat
    let height: CGFloat
    let radius: CGFloat
    var thumbnails: [ThumbnailObject]

    var preferredThumbnail: ThumbnailObject? {
        thumbnails
            .sorted { $0.width <= $1.width }
            .first { $0.width >= Int(width) }
    }

    var body: some View {
        Rectangle().foregroundStyle(.background)
            .frame(maxWidth: width, maxHeight: height)
            .aspectRatio(16 / 9, contentMode: .fill)
            .background(Rectangle().foregroundStyle(.background))
            .overlay {
                if let thumbnailUrl = preferredThumbnail?.url, let url = URL(string: thumbnailUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                            .frame(maxWidth: width, maxHeight: height)
                    } placeholder: {}
                        .frame(maxWidth: width, maxHeight: height)
                        .clipped()
                }
            }
            .cornerRadius(radius)
            .clipped()
    }
}

#Preview {
    ThumbnailView(width: 100, height: 56.25, radius: 4.0, thumbnails: [])
}
