//
//  PutRequests.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 15.06.2025.
//

import Foundation
import Foundation

struct LikeRequest: NetworkRequest {
    let likes: [String]
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    
    var httpMethod: HttpMethod {
        .put
    }
    
    var dto: Dto? {
        return LikeDTO(likes: likes)
    }
}

struct LikeDTO: Dto {
    let likes: [String]
    
    func asDictionary() -> [String: String] {
        let likesString = likes.joined(separator: ",")
        return ["likes": likesString]
    }
}

struct CartRequest: NetworkRequest {
    let nfts: [String]
    let isInCart: Bool
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    var httpMethod: HttpMethod {
        .put
    }
    
    var dto: Dto? {
        return CartDTO(nfts: nfts, isInCart: isInCart)
    }
}

struct CartDTO: Dto {
    let nfts: [String]
    let isInCart: Bool
    
    func asDictionary() -> [String: String] {
        let nftsString = nfts.joined(separator: ",")
        return ["nfts": nftsString, "isInCart": isInCart ? "true" : "false"]
    }
}

struct ProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct OrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}

struct ProfileResponse: Decodable {
    let likes: [String]
}

struct OrderResponse: Decodable {
    let nfts: [String]
}
