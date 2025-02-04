

//import Foundation
//
//struct Feature: Codable, Identifiable, Hashable {
//    var id: Int?
//    var createdAt: Date
//    var text: String
//    var isComplete: Bool
//    var userID: UUID
//    
//    enum CodingKeys: String, CodingKey {
//        case id, text
//        case createdAt = "created_at"
//        case isComplete = "is_complete"
//        case userID = "user_id"
//    }
//}

import Foundation

struct Feature: Codable,Identifiable,Hashable{
    var id:Int?
    var createdAt:Date
    var text:String
    var isComplete:Bool
    var userID:UUID
    
    enum CodingKeys: String,CodingKey{
        case id,text
        case createdAt="created_at"
        case isComplete="is_complete"
        case userID="user_id"
    }
}
