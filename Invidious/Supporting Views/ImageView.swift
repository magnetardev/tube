import InvidiousKit
import SwiftUI

struct ImageView: View {
    let width: CGFloat
    let height: CGFloat
    var images: [ImageObject]

    var preferredImage: ImageObject? {
        let image = images
            .sorted { $0.width <= $1.width }
            .first { $0.width >= Int(width) }
        guard var image else { return nil }
        if !image.url.starts(with: "http") {
            image.url = "https:\(image.url)"
        }
        return image
    }

    var body: some View {
        Group {
            if let imageUrl = preferredImage?.url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {}
            }
        }
        .frame(maxWidth: width, maxHeight: height)
        .aspectRatio(width / height, contentMode: .fill)
        .background(Rectangle().foregroundStyle(.background))
        .cornerRadius(width / 2)
        .clipped()
    }
}

#Preview {
    ImageView(width: 100, height: 100, images: [])
}
