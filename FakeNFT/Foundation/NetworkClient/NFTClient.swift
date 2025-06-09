//
//  NFTClient.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 08.06.2025.
//
import UIKit

protocol NFTClientProtocol {
    func fetchCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void)
}

struct CollectionsNetworkRequest: NetworkRequest {
    let endpoint: URL?
    let httpMethod: HttpMethod
    let headers: [String: String]
    
    
    var dto: Dto? { nil }
}

final class NFTClient: NFTClientProtocol {
    private let networkClient: NetworkClient
    private let collectionsURLString = "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net/api/v1/collections"
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
    
    func fetchCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void) {
        
        guard let url = URL(string: collectionsURLString) else {
            let error = NSError(
                domain: "NetworkError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid collections URL"]
            )
            completion(.failure(error))
            return
        }
        
        let request = CollectionsNetworkRequest(
            endpoint: url,
            httpMethod: .get,
            headers: [
                "Accept": "application/json"
            ]
        )
        
        networkClient.send(request: request, type: [NFTCollection].self) { result in
            completion(result)
        }
    }
}
