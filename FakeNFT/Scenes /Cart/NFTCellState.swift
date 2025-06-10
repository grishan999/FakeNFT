import Foundation

// MARK: - NFT Cell State
enum NFTCellState {
    case loading(id: String)           // Загружается
    case loaded(nft: nftCartModel)     // Загружена
    case error(id: String, error: Error) // Ошибка загрузки
    
    var id: String {
        switch self {
        case .loading(let id):
            return id
        case .loaded(let nft):
            return nft.id 
        case .error(let id, _):
            return id
        }
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var nft: nftCartModel? {
        if case .loaded(let nft) = self {
            return nft
        }
        return nil
    }
}


