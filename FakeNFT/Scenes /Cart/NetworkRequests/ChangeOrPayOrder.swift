import Foundation

struct ChangeOrPayOrder: NetworkRequest {
    let nftIds: [String]
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    var httpMethod: HttpMethod {
        .put
    }
    
    var dto: Dto? {
        return ChangeOrPayOrderDto(nftIds: nftIds)
    }
}

// MARK: - DTO для ChangeOrPayOrder
struct ChangeOrPayOrderDto: Dto {
    let nftIds: [String]
    
    func asDictionary() -> [String: String] {
        // Создаем словарь где каждый nftId становится отдельным параметром nfts
        var dictionary: [String: String] = [:]
        
        for (index, nftId) in nftIds.enumerated() {
            dictionary["nfts[\(index)]"] = nftId
        }
        
        return dictionary
    }
}
