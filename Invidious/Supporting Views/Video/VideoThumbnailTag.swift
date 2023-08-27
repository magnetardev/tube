import SwiftUI

struct VideoThumbnailTag: View {
    var content: String

    init(_ content: String) {
        self.content = content
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Group {
                    Text(content)
                        .padding(.horizontal, 6.0)
                        .padding(.vertical, 2.0)
                        .font(.caption2)
                }
                .background(.black)
                .foregroundStyle(.white)
                .cornerRadius(4.0)
                .padding([.bottom, .trailing], 4.0)
            }
        }
    }
}

#Preview {
    VideoThumbnailTag("4m 30s")
}
