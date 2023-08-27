import Foundation

public extension APIClient {
    func playlist(for id: String) async throws -> PlaylistObject {
        guard let idPath = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw APIError.urlCreation
        }
        let (data, _) = try await request(for: "/api/v1/playlists/\(idPath)")
        return try decoder.decode(PlaylistObject.self, from: data)
    }
}
