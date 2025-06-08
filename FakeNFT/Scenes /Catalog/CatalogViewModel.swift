//
//  CatalogViewModel.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 03.06.2025.
//

import Foundation  

final class CatalogViewModel {

    private(set) var categories: [CatalogCategory] = [] {
        didSet { onCategoriesUpdate?(categories) }
    }
    
    private(set) var isLoading = false {
        didSet { onLoadingUpdate?(isLoading) }
    }
    
    private(set) var error: String? {
        didSet { onErrorUpdate?(error) }
    }
    
    var onCategoriesUpdate: (([CatalogCategory]) -> Void)?
    var onLoadingUpdate: ((Bool) -> Void)?
    var onErrorUpdate: ((String?) -> Void)?
    
    private let nftClient: NFTClientProtocol
    
    init(nftClient: NFTClientProtocol) {
        self.nftClient = nftClient
    }
    
    func loadCategories() {
        isLoading = true
        error = nil

        nftClient.fetchCollections { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let collections):
                    self?.categories = collections.compactMap { collection in
                        guard let url = URL(string: collection.cover) else {
                            print("Invalid URL string: \(collection.cover)")
                            return nil
                        }
                        return CatalogCategory(
                            imageUrl: url,
                            title: collection.name,
                            count: collection.nfts.count
                        )
                    }
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}
