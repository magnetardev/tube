import AVFoundation
import AVKit
import Foundation
import InvidiousKit
import MediaPlayer
import Observation

enum VideoQueueError: LocalizedError {
    case missingUrl
}

@Observable
final class VideoQueue: NSObject {
    private(set) var playerQueue: AVQueuePlayer
    private(set) var current: Video? = nil
    private(set) var playing: Bool = false
    private(set) var videos: [VideoItem] = []

    struct VideoItem: Identifiable, Equatable {
        static func == (lhs: VideoQueue.VideoItem, rhs: VideoQueue.VideoItem) -> Bool {
            lhs.id == rhs.id
        }

        let id = UUID()
        var player: AVPlayerItem
        var info: Video
    }

    override init() {
        self.playerQueue = AVQueuePlayer()
        super.init()
        playerQueue.allowsExternalPlayback = true
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: .defaultToSpeaker)
        } catch {
            print(error.localizedDescription)
        }
        #endif
        playerQueue.addObserver(
            self,
            forKeyPath: #keyPath(AVQueuePlayer.currentItem),
            options: [.old, .new],
            context: nil
        )
        playerQueue.addObserver(
            self,
            forKeyPath: #keyPath(AVQueuePlayer.timeControlStatus),
            options: [.new],
            context: nil
        )
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "currentItem":
            if let oldItem = change?[NSKeyValueChangeKey.oldKey] as? AVPlayerItem {
                guard let index = videos.firstIndex(where: { $0.player == oldItem }) else { return }
                videos.remove(at: index)
            }
            if let newItem = change?[NSKeyValueChangeKey.newKey] as? AVPlayerItem {
                current = videos.first { $0.player == newItem }?.info
                let center = MPNowPlayingInfoCenter.default()
                center.nowPlayingInfo = if let current {
                    [
                        MPMediaItemPropertyTitle: current.title,
                        MPMediaItemPropertyArtist: current.author,
                    ]
                } else {
                    nil
                }
            }
        case "timeControlStatus":
            playing = playerQueue.timeControlStatus == .playing
        default: break
        }
    }

    func clear() {
        playerQueue.removeAllItems()
        videos.removeAll()
    }

    func remove(video: VideoItem) {
        playerQueue.remove(video.player)
        guard let index = videos.firstIndex(of: video) else { return }
        videos.remove(at: index)
    }

    func skip(to item: VideoItem) {
        guard playerQueue.currentItem != nil, videos.contains(item) else {
            return
        }

        while let player = playerQueue.currentItem, player != item.player {
            playerQueue.advanceToNextItem()
        }
    }

    func add(id: String) async throws {
        let video = try await TubeApp.client.video(for: id)
        try await MainActor.run {
            try add(video: video)
        }
    }

    func add(video: Video) throws {
        let player = try player(for: video)
        videos.append(VideoItem(player: player, info: video))
        playerQueue.insert(player, after: nil)
    }

    private func player(for video: Video) throws -> AVPlayerItem {
        let sortedStreams = video.formatStreams.sorted {
            let aQuality = Int($0.quality.trimmingCharacters(in: .letters)) ?? -1
            let bQuality = Int($1.quality.trimmingCharacters(in: .letters)) ?? -1
            return aQuality > bQuality
        }
        let item = if let hlsUrlStr = video.hlsUrl, let hlsUrl = URL(string: hlsUrlStr) {
            AVPlayerItem(url: hlsUrl)
        } else if let stream = sortedStreams.first, let streamUrl = URL(string: stream.url) {
            AVPlayerItem(url: streamUrl)
        } else {
            throw VideoQueueError.missingUrl
        }

        #if !os(macOS)
        var metadata: [AVMetadataItem] = []
        let titleMetadata = AVMutableMetadataItem()
        titleMetadata.identifier = .commonIdentifierTitle
        titleMetadata.value = video.title as any NSCopying & NSObjectProtocol
        if let copy = titleMetadata.copy() as? AVMetadataItem {
            metadata.append(copy)
        }
        let subtitleMetadata = AVMutableMetadataItem()
        subtitleMetadata.identifier = .iTunesMetadataTrackSubTitle
        subtitleMetadata.value = video.author as any NSCopying & NSObjectProtocol
        if let copy = subtitleMetadata.copy() as? AVMetadataItem {
            metadata.append(copy)
        }
        item.externalMetadata = metadata
        #endif
        return item
    }
}
