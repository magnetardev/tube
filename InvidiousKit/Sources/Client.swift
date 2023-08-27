import Foundation

public enum APIError: LocalizedError {
    case urlCreation
}

public class APIClient {
    let baseUrl: URL
    var session: URLSession
    var decoder = JSONDecoder()
    
    public init(apiUrl: URL, session: URLSession = .shared) {
        self.baseUrl = apiUrl
        self.session = session
    }
    
    func requestUrl(for string: String, with queryItems: [URLQueryItem]? = nil) -> URL? {
        guard var url = URL(string: string, relativeTo: self.baseUrl) else {
            return nil
        }
        if let queryItems = queryItems {
            if #available(iOS 16, macOS 13, *) {
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
}

