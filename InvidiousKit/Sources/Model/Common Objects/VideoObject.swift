import Foundation

public struct VideoObject: Hashable, Decodable {
    public var type = ResultType.video
    public var title: String
    public var videoId: String
    public var author: String
    public var authorId: String
    public var authorUrl: String
    public var authorVerified: Bool?
    public var videoThumbnails: [ThumbnailObject]
    public var description: String
    public var viewCount: Int
    public var lengthSeconds: Int
    public var published: Int64
    public var publishedText: String
    // Only available on premiered videos
    public var premiereTimestamp: Date? // Unix timestamp
    public var liveNow: Bool
    public var premium: Bool
    public var isUpcoming: Bool
    
    public static func == (lhs: VideoObject, rhs: VideoObject) -> Bool {
        lhs.videoId == rhs.videoId
    }
}
