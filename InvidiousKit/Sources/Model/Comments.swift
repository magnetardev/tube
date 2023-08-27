import Foundation

public struct CommentsResponse: Decodable {
    public var commentCount: Int32?
    public var videoId: String
    public var comments: [Comment]
    public var continuation: String?

    public struct Comment: Hashable, Decodable {
        public static func == (lhs: CommentsResponse.Comment, rhs: CommentsResponse.Comment) -> Bool {
            lhs.commentId == rhs.commentId
        }

        public var author: String
        public var authorThumbnails: [ImageObject]
        public var authorId: String
        public var authorUrl: String
        public var isEdited: Bool
        public var isPinned: Bool
        public var content: String
        public var contentHtml: String
        public var published: Int64
        public var publishedText: String
        public var likeCount: Int32
        public var commentId: String
        public var authorIsChannelOwner: Bool
        public var creatorHeart: CreatorHeart?

        public struct CreatorHeart: Hashable, Decodable {
            public static func == (
                lhs: CommentsResponse.Comment.CreatorHeart,
                rhs: CommentsResponse.Comment.CreatorHeart
            ) -> Bool {
                lhs.creatorThumbnail == rhs.creatorThumbnail
            }

            public var creatorThumbnail: String
            public var creatorName: String
        }
    }
}

public enum CommentsOrder: String {
    case new
    case top
}

public extension APIClient {
    func comments(
        for id: String,
        order: CommentsOrder? = nil,
        continuation: String? = nil
    ) async throws -> CommentsResponse {
        guard let idPath = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw APIError.urlCreation
        }

        // FIXME: surely there's a way to optimize this?
        var queryItems: [URLQueryItem]?
        if order != nil || continuation != nil {
            var items = [URLQueryItem]()
            if let order {
                items.append(URLQueryItem(name: "sort_by", value: order.rawValue))
            }
            if let continuation {
                items.append(URLQueryItem(name: "continuation", value: continuation))
            }
            queryItems = items
        }

        let (data, _) = try await request(for: "/api/v1/comments/\(idPath)", with: queryItems)
        return try decoder.decode(CommentsResponse.self, from: data)
    }
}
