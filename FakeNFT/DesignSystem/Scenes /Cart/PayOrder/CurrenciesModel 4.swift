import UIKit

struct Currency: Decodable {
    let title: String
    let name: String
    let image: String
    let id: String
    
    
    enum CodingKeys: String, CodingKey {
        case title
        case name
        case image
        case id
    }
}
