import Foundation

struct nftCartModelRequest: NetworkRequest {
    let id: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
    }
    
    var dto: Dto? { nil }
}
