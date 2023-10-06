import Foundation

public struct Search {
    public struct Suggestions: Decodable {
        public var query: String
        public var suggestions: [String]
    }

    public enum Result: Decodable, Hashable, Identifiable {
        case video(VideoObject)
        case channel(ChannelObject)
        case playlist(PlaylistObject)
        
        public var id: String {
            switch self {
            case .video(let data): 
                return data.videoId
            case .channel(let data): 
                return data.authorId
            case .playlist(let data): 
                return data.playlistId
            }
        }

        public static func == (lhs: Search.Result, rhs: Search.Result) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let response = try? container.decode(VideoObject.self) {
                self = .video(response)
            } else if let response = try? container.decode(ChannelObject.self) {
                self = .channel(response)
            } else if let response = try? container.decode(PlaylistObject.self) {
                self = .playlist(response)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot initialize Result")
            }
        }
    }
}

public extension APIClient {
    func search(query: String, page: Int32) async throws -> [Search.Result] {
        let (data, _) = try await request(for: "/api/v1/search", with: [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: page.description)
        ])
        return try Self.decoder.decode([Search.Result].self, from: data)
    }
}
