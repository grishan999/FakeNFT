import Foundation

// MARK: - ProfileModel
struct ProfileModel: Decodable {
    var name: String
    var avatar: String
    var description: String
    var website: String
    var nfts: [String]
    var likes: [String]
    let id: String
}

