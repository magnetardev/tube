import AVKit
import Foundation
import SwiftUI

#if canImport(AppKit)
    struct VideoPlayerView: NSViewControllerRepresentable {
        var player: AVPlayer

        typealias NSViewControllerType = NSViewController

        func makeNSViewController(context _: Context) -> NSViewController {
            let viewController = NSViewController()
            let videoView = AVPlayerView()
            videoView.player = player
            videoView.player?.play()
            videoView.allowsPictureInPicturePlayback = true
            videoView.showsFullScreenToggleButton = true
            viewController.view = videoView

            return viewController
        }

        func updateNSViewController(_: NSViewController, context _: Context) {}
    }
#else
    struct VideoPlayerView: UIViewControllerRepresentable {
        var player: AVPlayer

        typealias NSViewControllerType = AVPlayerViewController

        func makeUIViewController(context _: Context) -> UIViewController {
            let videoView = AVPlayerViewController()
            videoView.player = player
            videoView.player?.play()
            videoView.allowsPictureInPicturePlayback = true
            return videoView
        }

        func updateUIViewController(_: UIViewController, context _: Context) {}
    }
#endif
