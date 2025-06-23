//
//  CatalogViewModel.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 03.06.2025.
//

enum SortType: String {
    case byName
    case byCount
    case none
}

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
    
    private let sortTypeKey = "CatalogSortType"
    private let userDefaults = UserDefaults.standard
    
    var onCategoriesUpdate: (([CatalogCategory]) -> Void)?
    var onLoadingUpdate: ((Bool) -> Void)?
    var onErrorUpdate: ((String?) -> Void)?
    
    private let nftClient: NFTClientProtocol
    
    init(nftClient: NFTClientProtocol) {
        self.nftClient = nftClient
    }
    
    private var currentSortType: SortType {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: sortTypeKey) else {
                return .none
            }
            let type = SortType(rawValue: rawValue) ?? .none
            return type
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: sortTypeKey)
            UserDefaults.standard.synchronize() 
        }
    }
    
    private func applySavedSort() {
        switch currentSortType {
        case .byName:
            sortByName()
        case .byCount:
            sortByCount()
        case .none:
            break
        }
    }
    
    func loadCategories() {
        isLoading = true
        error = nil
        
        nftClient.fetchCollections { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let collections):
                    let unsortedCategories = collections.map {
                        CatalogCategory(
                            id: $0.id,
                            imageUrl: $0.cover,
                            title: $0.name,
                            count: $0.nfts.count
                        )
                    }
                    
                    switch self.currentSortType {
                    case .byName:
                        self.categories = unsortedCategories.sorted { $0.title < $1.title }
                    case .byCount:
                        self.categories = unsortedCategories.sorted { $0.count > $1.count }
                    case .none:
                        self.categories = unsortedCategories
                    }
                
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    func sortByName() {
        categories.sort { $0.title.lowercased() < $1.title.lowercased() }
        currentSortType = .byName
        onCategoriesUpdate?(categories)
    }

    func sortByCount() {
        categories.sort { $0.count > $1.count }
        currentSortType = .byCount
        onCategoriesUpdate?(categories)
    }
}
