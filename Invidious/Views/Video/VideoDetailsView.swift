import InvidiousKit
import Observation
import SwiftUI

struct VideoDetailsView: View {
    var video: Video
    @State var selectedTab: VideoViewModel.SelectedTab = .info
    @Environment(VideoQueue.self) var queue

    var body: some View {
        VStack(alignment: .leading) {
            Text(video.title)
            HStack {
                ImageView(width: 44, height: 44, images: video.authorThumbnails)
                VStack(alignment: .leading) {
                    Text(video.author)
                    Text(video.subCountText).foregroundStyle(.secondary)
                }
                Spacer()
                FollowButton(channelId: video.authorId, channelName: video.author)
            }
            Picker(selection: $selectedTab) {
                Text("Info").tag(VideoViewModel.SelectedTab.info)
                Text("Comments").tag(VideoViewModel.SelectedTab.comments)
                Text("Related").tag(VideoViewModel.SelectedTab.recommended)
            } label: {}
                .pickerStyle(.segmented)
                .labelsHidden()
        }
        .padding([.top, .horizontal])
        Group {
            switch selectedTab {
            case .info:
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(video.description)
                    }.padding()
                }
            case .comments:
                CommentsView(model: CommentsViewModel(videoId: video.videoId))
            case .recommended:
                List(video.recommendedVideos, id: \.videoId) { video in
                    Button {
                        Task {
                            queue.clear()
                            try? await queue.add(id: video.videoId)
                        }
                    } label: {
                        VideoListItem(title: video.title, author: video.author, thumbnails: video.videoThumbnails)
                    }.buttonStyle(.plain)
                        .contextMenu(ContextMenu(menuItems: {
                            Button {
                                Task {
                                    do {
                                        try await queue.add(id: video.videoId)
                                    } catch {
                                        print("Error")
                                    }
                                }
                            } label: {
                                Text("Add to Queue")
                            }
                        }))
                }.listStyle(.inset)
            }
        }
    }
}

#Preview {
    VideoDetailsView(video: Video(title: "Some Video", videoId: "", videoThumbnails: [], description: "Hello", published: 0, keywords: [], viewCount: 0, likeCount: 120, dislikeCount: 400, paid: false, premium: false, isFamilyFriendly: false, allowedRegions: [], genre: "", genreUrl: "", author: "Some Creator", authorId: "", authorUrl: "", authorThumbnails: [], subCountText: "100", lengthSeconds: 123, allowRatings: true, rating: 0, isListed: true, liveNow: false, isUpcoming: false, adaptiveFormats: [], formatStreams: [], captions: [], recommendedVideos: []))
}
