import Foundation

public enum TrendingCategory: String, Hashable {
    case movies
    case music
    case gaming
    case news
}

public extension APIClient {
    func trending(for category: TrendingCategory) async throws -> [VideoObject] {
        let (data, _)  = try await request(
            for: "/api/v1/trending",
            with: [URLQueryItem(name: "type", value: category.rawValue)]
        )
        return try decoder.decode([VideoObject].self, from: data)
    }
}
