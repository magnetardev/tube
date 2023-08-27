import Foundation

public struct Video: Decodable {
    public var title: String
    public var videoId: String
    public var videoThumbnails: [ThumbnailObject]

    public var description: String
    public var published: Int64

    public var keywords: [String]
    public var viewCount: Int64
    public var likeCount: Int32
    public var dislikeCount: Int32

    public var paid: Bool
    public var premium: Bool
    public var isFamilyFriendly: Bool
    public var allowedRegions: [String]
    public var genre: String
    public var genreUrl: String

    public var author: String
    public var authorId: String
    public var authorUrl: String
    public var authorThumbnails: [ImageObject]

    public var subCountText: String
    public var lengthSeconds: Int32
    public var allowRatings: Bool
    public var rating: Float32
    public var isListed: Bool
    public var liveNow: Bool
    public var isUpcoming: Bool
    public var premiereTimestamp: Int64?

    public var hlsUrl: String?
    public var adaptiveFormats: [AdaptiveFormat]
    public var formatStreams: [FormatStream]
    public var captions: [Caption]
    public var recommendedVideos: [RecommendedVideo]

    public struct AdaptiveFormat: Decodable {
        public var index: String
        public var bitrate: String
        public var `init`: String
        public var url: String
        public var itag: String
        public var type: String
        public var clen: String
        public var lmt: String
        public var projectionType: String
        public var container: String?
        public var encoding: String?
        public var qualityLabel: String?
        public var resolution: String?
    }

    public struct FormatStream: Decodable {
        public var url: String
        public var itag: String
        public var type: String
        public var quality: String
        public var container: String
        public var encoding: String
        public var qualityLabel: String
        public var resolution: String
        public var size: String
    }

    public struct Caption: Decodable {
        public var label: String
        public var languageCode: String?
        public var url: String
    }

    public struct RecommendedVideo: Decodable {
        public var videoId: String
        public var title: String
        public var videoThumbnails: [ThumbnailObject]
        public var author: String
        public var lengthSeconds: Int32
        public var viewCountText: String
    }

    public init(
        title: String,
        videoId: String,
        videoThumbnails: [ThumbnailObject],
        description: String,
        published: Int64,
        keywords: [String],
        viewCount: Int64,
        likeCount: Int32,
        dislikeCount: Int32,
        paid: Bool,
        premium: Bool,
        isFamilyFriendly: Bool,
        allowedRegions: [String],
        genre: String,
        genreUrl: String,
        author: String,
        authorId: String,
        authorUrl: String,
        authorThumbnails: [ImageObject],
        subCountText: String,
        lengthSeconds: Int32,
        allowRatings: Bool,
        rating: Float32,
        isListed: Bool,
        liveNow: Bool,
        isUpcoming: Bool,
        premiereTimestamp: Int64? = nil,
        hlsUrl: String? = nil,
        adaptiveFormats: [Video.AdaptiveFormat],
        formatStreams: [Video.FormatStream],
        captions: [Video.Caption],
        recommendedVideos: [Video.RecommendedVideo]
    ) {
        self.title = title
        self.videoId = videoId
        self.videoThumbnails = videoThumbnails
        self.description = description
        self.published = published
        self.keywords = keywords
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.paid = paid
        self.premium = premium
        self.isFamilyFriendly = isFamilyFriendly
        self.allowedRegions = allowedRegions
        self.genre = genre
        self.genreUrl = genreUrl
        self.author = author
        self.authorId = authorId
        self.authorUrl = authorUrl
        self.authorThumbnails = authorThumbnails
        self.subCountText = subCountText
        self.lengthSeconds = lengthSeconds
        self.allowRatings = allowRatings
        self.rating = rating
        self.isListed = isListed
        self.liveNow = liveNow
        self.isUpcoming = isUpcoming
        self.premiereTimestamp = premiereTimestamp
        self.hlsUrl = hlsUrl
        self.adaptiveFormats = adaptiveFormats
        self.formatStreams = formatStreams
        self.captions = captions
        self.recommendedVideos = recommendedVideos
    }
}

public extension APIClient {
    func video(for id: String) async throws -> Video {
        guard let idPath = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw APIError.urlCreation
        }
        let (data, _) = try await request(for: "/api/v1/videos/\(idPath)")
        return try decoder.decode(Video.self, from: data)
    }
}
