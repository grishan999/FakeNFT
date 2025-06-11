//
//  NFTCollectionViewModel.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 11.06.2025.
//

import Foundation

protocol NFTCollectionViewModelProtocol {
    var nfts: [Nft] { get }
    var onNFTsUpdate: (() -> Void)? { get set }
    var onLoadingStateChange: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func loadNFTs()
}

final class NFTCollectionViewModel: NFTCollectionViewModelProtocol {
    var onNFTsUpdate: (() -> Void)?
    var onLoadingStateChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private(set) var nfts: [Nft] = [] {
        didSet { onNFTsUpdate?() }
    }
    
    private let collectionId: String
    private let networkClient: NetworkClient
    private let nftService: NftService
    private let dispatchGroup = DispatchGroup()

    init(collectionId: String, networkClient: NetworkClient, nftService: NftService) {
        self.collectionId = collectionId
        self.networkClient = networkClient
        self.nftService = nftService
    }

    func loadNFTs() {
        onLoadingStateChange?(true)
        fetchCollection { [weak self] result in
            switch result {
            case .success(let collection):
                self?.loadFullNFTs(from: collection.nfts)
            case .failure(let error):
                self?.onError?(error.localizedDescription)
                self?.onLoadingStateChange?(false)
            }
        }
    }
    
    private func fetchCollection(completion: @escaping (Result<NFTCollection, Error>) -> Void) {
        let urlString = "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net/api/v1/collections/\(collectionId)"
        guard let url = URL(string: urlString) else {
            return completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        }

        let request = createCollectionRequest(url: url)

        networkClient.send(request: request, type: NFTCollection.self) { result in
            completion(result.mapError { $0 })
        }
    }

    private func createCollectionRequest(url: URL) -> some NetworkRequest {
        struct CollectionRequest: NetworkRequest {
            var endpoint: URL?
            var httpMethod: HttpMethod = .get
            var dto: Dto?

            init(endpoint: URL?) {
                self.endpoint = endpoint
            }
        }

        return CollectionRequest(endpoint: url)
    }

    private func loadFullNFTs(from ids: [String]) {
        var loadedNFTs: [Nft] = []

        for id in ids {
            self.dispatchGroup.enter()
            nftService.loadNft(id: id) { result in
                switch result {
                case .success(let nft):
                    loadedNFTs.append(nft)
                case .failure(_):
                    print("Ошибка загрузки NFT с ID $id): $error.localizedDescription)")
                }
                self.dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.nfts = loadedNFTs
            self.onLoadingStateChange?(false)
        }
    }
}
