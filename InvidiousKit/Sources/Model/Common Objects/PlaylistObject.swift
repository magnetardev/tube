import Foundation

public struct PlaylistObject: Hashable, Decodable {
    public var type = ResultType.playlist

    public var title: String
    public var playlistId: String
    public var playlistThumbnail: String?

    public var author: String
    public var authorId: String

    public var videoCount: Int
    public var videos: [PlaylistVideo]

    public static func == (lhs: PlaylistObject, rhs: PlaylistObject) -> Bool {
        lhs.playlistId == rhs.playlistId
    }

    public struct PlaylistVideo: Hashable, Decodable {
        public var title: String
        public var videoId: String
        public var lengthSeconds: Int
        public var videoThumbnails: [ThumbnailObject]
        
        public var author: String?

        public static func == (lhs: PlaylistObject.PlaylistVideo, rhs: PlaylistObject.PlaylistVideo) -> Bool {
            lhs.videoId == rhs.videoId
        }
    }
}
