import InvidiousKit
import SwiftUI

struct ChannelHeaderView: View {
    var channel: Channel
    @Binding var selection: ChannelViewModel.ChannelTab

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ImageView(width: 64, height: 64, images: channel.authorThumbnails)
                VStack(alignment: .leading) {
                    Group {
                        if channel.authorVerified {
                            Text(channel.author) + Text(" ") + Text(Image(systemName: "checkmark.seal.fill")).foregroundStyle(.tint)
                        } else {
                            Text(channel.author)
                        }
                    }.fontWeight(.medium)
                    Text("\(channel.subCount.formatted()) Subscribers").foregroundStyle(.secondary)
                }
                Spacer()
            }

            GeometryReader { proxy in
                Picker(selection: $selection) {
                    Text("Videos").tag(ChannelViewModel.ChannelTab.videos(.videos))
                    Text("Shorts").tag(ChannelViewModel.ChannelTab.videos(.shorts))
                    Text("Streams").tag(ChannelViewModel.ChannelTab.videos(.streams))
                    Text("Playlists").tag(ChannelViewModel.ChannelTab.playlists)
                } label: {}.labelsHidden().modify {
                    if proxy.size.width >= 768 {
                        $0.pickerStyle(.segmented)
                    } else {
                        $0.pickerStyle(.menu)
                    }
                }
            }
        }.padding()
    }
}
