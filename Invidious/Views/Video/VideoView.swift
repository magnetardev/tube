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
        VStack {
            VideoPlayerView(player: queue.playerQueue)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .navigationTitle(queue.current?.title ?? "Video")
        #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
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
                ToolbarItem {
                    Button {
                        model.showingInfo.toggle()
                    } label: {
                        Label("Video Details, Comments, & Recommended", systemImage: "info.circle")
                    }
                }
            }
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
