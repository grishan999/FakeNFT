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
            guard let rawValue = userDefaults.string(forKey: sortTypeKey) else {
                return .none
            }
            return SortType(rawValue: rawValue) ?? .none
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: sortTypeKey)
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
                    self?.applySavedSort()
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func sortByName() {
        categories.sort {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
        currentSortType = .byName
        onCategoriesUpdate?(categories)
    }
    
    func sortByCount() {
        categories.sort { $0.count > $1.count }
        onCategoriesUpdate?(categories)
        currentSortType = .byCount
    }
}
