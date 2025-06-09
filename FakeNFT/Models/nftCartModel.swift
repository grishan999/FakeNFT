import Foundation

struct nftCartModel: Decodable {
    let images: [String]
    let name: String
    let price: Double
    let rating: Int
    
    // Computed property - первая картинка из массива
    var nftPictureURL: String? {
        return images.first
    }
    
    // Computed property для URL
    var imageURL: URL? {
        guard let firstImageURL = nftPictureURL else { return nil }
        return URL(string: firstImageURL)
    }
    
    enum CodingKeys: String, CodingKey {
        case images
        case name
        case price
        case rating
    }
}
