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
        return nil  //  Больше не нужно, NetworkClient использует nftIds напрямую
    }
}
