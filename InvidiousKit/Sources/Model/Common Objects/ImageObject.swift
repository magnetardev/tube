import Foundation

public struct ImageObject: Hashable, Decodable {
    public var url: String
    public var width: Int
    public var height: Int
    
    public static func == (lhs: ImageObject, rhs: ImageObject) -> Bool {
        lhs.url == rhs.url
    }
}
