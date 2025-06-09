import Foundation

// MARK: - Order Model
struct Order: Codable {
    let id: String
    let nfts: [String] // Массив ID NFT
}
