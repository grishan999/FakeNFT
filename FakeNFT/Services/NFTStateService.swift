//
//  NFTStateService.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 15.06.2025.
//
import UIKit

protocol NFTStateServiceProtocol {
    func getLikedNFTs(completion: @escaping (Result<Set<String>, Error>) -> Void)
    func getCartNFTs(completion: @escaping (Result<Set<String>, Error>) -> Void)
    func updateLikeState(nftId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func updateCartState(nftId: String, isInCart: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func isLiked(nftId: String) -> Bool
    func isInCart(nftId: String) -> Bool
}

final class NFTStateService: NFTStateServiceProtocol {
    private let networkClient: NetworkClient
    private var likedNFTs: Set<String> = []
    private var cartNFTs: Set<String> = []
    private var isLoadingLikes = false
    private var isLoadingCart = false
    
    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
        loadInitialStates()
    }
    
    private func loadInitialStates() {
        getLikedNFTs { _ in }
        getCartNFTs { _ in }
    }
    
    func getLikedNFTs(completion: @escaping (Result<Set<String>, Error>) -> Void) {
        guard !isLoadingLikes else { return }
        isLoadingLikes = true
        
        let request = ProfileRequest()
        networkClient.send(request: request, type: ProfileResponse.self) { [weak self] result in
            self?.isLoadingLikes = false
            switch result {
            case .success(let response):
                self?.likedNFTs = Set(response.likes)
                completion(.success(Set(response.likes)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCartNFTs(completion: @escaping (Result<Set<String>, Error>) -> Void) {
        guard !isLoadingCart else { return }
        isLoadingCart = true
        
        let request = OrderRequest()
        networkClient.send(request: request, type: OrderResponse.self) { [weak self] result in
            self?.isLoadingCart = false
            switch result {
            case .success(let response):
                self?.cartNFTs = Set(response.nfts)
                completion(.success(Set(response.nfts)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateLikeState(nftId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let request = LikeRequest(nftId: nftId, isLike: isLiked)
        networkClient.send(request: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if isLiked {
                        self?.likedNFTs.insert(nftId)
                    } else {
                        self?.likedNFTs.remove(nftId)
                    }
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateCartState(nftId: String, isInCart: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let orderRequest = OrderRequest()
        
        networkClient.send(request: orderRequest) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: data)
                    var currentNFTs = orderResponse.nfts
                    
                    if isInCart {
                        if !currentNFTs.contains(nftId) {
                            currentNFTs.append(nftId)
                        }
                    } else {
                        currentNFTs.removeAll { $0 == nftId }
                    }
                    
                    let cartRequest = CartRequest(nfts: currentNFTs, isInCart: true)
                    self?.networkClient.send(request: cartRequest) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func isLiked(nftId: String) -> Bool {
        return likedNFTs.contains(nftId)
    }
    
    func isInCart(nftId: String) -> Bool {
        return cartNFTs.contains(nftId)
    }
}
