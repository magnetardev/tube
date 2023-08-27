import Foundation
import SwiftData

@Model
class FollowedChannel {
    @Attribute(.unique) var id: String = ""
    var name: String = ""
    var dateFollowed: Date = Date()
    
    init(id: String, name: String, dateFollowed: Date) {
        self.id = id
        self.name = name
        self.dateFollowed = dateFollowed
    }
}
