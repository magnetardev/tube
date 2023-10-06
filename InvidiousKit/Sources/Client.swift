import Foundation

public enum APIError: LocalizedError {
    case urlCreation
}

public final class APIClient {
    public var baseUrl: URL?
    var session: URLSession
    static var decoder = JSONDecoder()
    
    public init(apiUrl: URL? = nil, session: URLSession = .shared) {
        self.baseUrl = apiUrl
        self.session = session
    }
    
    public func setApiUrl(url: URL?) {
        baseUrl = url
    }
    
    func requestUrl(for string: String, with queryItems: [URLQueryItem]? = nil) -> URL? {
        guard var url = URL(string: string, relativeTo: baseUrl) else {
            return nil
        }
        if let queryItems = queryItems {
            if #available(iOS 16, macOS 13, tvOS 16, *) {
                url.append(queryItems: queryItems)
            } else {
                guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return nil
                }
                components.queryItems = queryItems
                return components.url
            }
        }
        return url
    }
    
    func request(for string: String, with queryItems: [URLQueryItem]? = nil) async throws -> (Data, URLResponse) {
        guard let url = requestUrl(for: string, with: queryItems) else {
            throw APIError.urlCreation
        }
        return try await session.data(from: url)
    }
    
    public static func isValidInstance(url: URL) async -> Bool {
        guard
            let statsUrl = URL(string: "/api/v1/stats", relativeTo: url),
            let (data, _) = try? await URLSession.shared.data(from: statsUrl),
            let stats = try? decoder.decode(Stats.self, from: data)
        else {
            return false
        }
        return stats.software.name == "invidious"
    }
}

private struct Stats: Decodable {
    var software: Stats.Software
    
    struct Software: Decodable {
        var name: String
    }
}
