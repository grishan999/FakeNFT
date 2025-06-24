import Foundation

protocol CustomQueryStringDto: Dto {
    func asQueryString() -> String
}


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
struct ChangeOrPayOrderDto: CustomQueryStringDto {
    let nftIds: [String]
    
    //  Обязательный метод от Dto (не используется)
    func asDictionary() -> [String: String] {
        return [:] // Пустой - используем asQueryString()
    }
    
    //  Специальный метод для формирования повторяющихся параметров
    func asQueryString() -> String {
        return nftIds.map { "nfts=\($0)" }.joined(separator: "&")
    }
}
