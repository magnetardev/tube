import InvidiousKit
import SwiftUI

struct FollowedChannelFeedView: View {
    var channel: FollowedChannel
    @State var videos: [VideoObject]? = nil

    var body: some View {
        Section {
            if let videos {
                if videos.isEmpty {
                    MessageBlock(title: "No Videos", message: "This channel doesn't have any videos yet.").padding()
                } else {
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: [.init(.flexible(minimum: 200, maximum: 300))], alignment: .top, spacing: 16.0) {
                            ForEach(videos, id: \.videoId) { video in
                                HorizontalSwiperVideoCard(videoObject: video)
                            }
                        }.padding(.horizontal)
                    }
                }
            } else {
                ProgressView()
                    .padding()
                    .task(id: channel.id) {
                        guard videos?.isEmpty != true else { return }
                        do {
                            let result = try await TubeApp.client.videos(for: channel.id, continuation: nil)
                            videos = result.videos
                        } catch {
                            print(error)
                        }
                    }
            }
        } header: {
            HStack(spacing: 8) {
                NavigationLink(value: NavigationDestination.channel(channel.id)) {
                    Text(channel.name).font(.title3).fontWeight(.semibold).foregroundStyle(.primary)
                    Image(systemName: "chevron.right").foregroundStyle(.secondary)
                }.buttonStyle(.plain)
            }.padding(.horizontal)
        }
    }
}
