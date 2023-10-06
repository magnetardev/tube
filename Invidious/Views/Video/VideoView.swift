import AVKit
import InvidiousKit
import Observation
import SwiftUI

@Observable
class VideoViewModel: Identifiable {
    var showingInfo: Bool = false
    var infoSelectedTab: SelectedTab = .info

    enum SelectedTab {
        case info
        case comments
        case recommended
    }
}

struct VideoView: View {
    @Bindable var model: VideoViewModel
    @State var player: AVPlayer?
    @State var showingQueue: Bool = false
    @Environment(VideoQueue.self) private var queue
    @Environment(OpenVideoPlayerAction.self) private var playerState

    var body: some View {
        VideoPlayerView(player: queue.playerQueue)
            .background(.black, ignoresSafeAreaEdges: .all)
            .navigationTitle(queue.current?.title ?? "Video")
            .toolbar {
                #if !os(macOS)
                    ToolbarItem(placement: .navigation) {
                        Button {
                            playerState.close()
                        } label: {
                            Label("Close", systemImage: "chevron.down")
                        }
                    }
                #endif
                ToolbarItem {
                    Button {
                        showingQueue = true
                    } label: {
                        Label("Queue", systemImage: "list.and.film")
                    }.popover(isPresented: $showingQueue) {
                        VideoQueueListView()
                            .frame(minWidth: 300, minHeight: 200)
                    }
                }
                
                if let video = queue.current, let url = URL(string: "https://youtube.com/watch?v=\(video.videoId)") {
                    ToolbarItem {
                        ShareLink(video.title, item: url)
                    }
                } else {
                    ToolbarItem {
                        Button {} label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }.disabled(true)
                    }
                }
                
                ToolbarItem {
                    Button {
                        model.showingInfo.toggle()
                    } label: {
                        Label("Video Details, Comments, & Recommended", systemImage: "info.circle")
                    }
                }
            }
        #if !os(macOS)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .inspector(isPresented: $model.showingInfo) {
                if let video = queue.current {
                    VideoDetailsView(video: video)
                } else {
                    Text("No video playing.")
                }
            }
    }
}

// #Preview {
//    VideoView()
// }
