import InvidiousKit
import SwiftUI

struct VideoListItem: View {
    var title: String
    var author: String
    var thumbnails: [ThumbnailObject]

    var body: some View {
        HStack {
            ThumbnailView(width: 78, height: 44, thumbnails: thumbnails)
            VStack(alignment: .leading) {
                Text(title).lineLimit(1)
                Text(author).lineLimit(1).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        VideoListItem(title: "Video Title", author: "Author", thumbnails: [])
    }.listStyle(.plain)
}
