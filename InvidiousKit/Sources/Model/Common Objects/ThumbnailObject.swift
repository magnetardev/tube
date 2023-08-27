import Foundation

public struct ThumbnailObject: Hashable, Decodable {
    public var quality: String
    public var url: String
    public var width: Int
    public var height: Int
    
    public static func == (lhs: ThumbnailObject, rhs: ThumbnailObject) -> Bool {
        lhs.url == rhs.url
    }
}
