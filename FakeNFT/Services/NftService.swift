import Foundation

typealias NftCompletion = (Result<Nft, Error>) -> Void
typealias OrderCompletion = (Result<Order, Error>) -> Void
typealias nftCartModelCompletion = (Result<nftCartModel, Error>) -> Void
typealias currenciesCompletion = (Result<[Currency], Error>) -> Void


protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    func loadOrder(id: String, completion: @escaping OrderCompletion)
    func loadNftCartModel(id: String, completion: @escaping nftCartModelCompletion)
    func changeOrPaytOrder(nftIds: [String], completion: @escaping OrderCompletion)
    func loadCurrencies(completion : @escaping currenciesCompletion)
}

final class NftServiceImpl: NftService {

    private let networkClient: NetworkClient
    private let storage: NftStorage

    init(networkClient: NetworkClient, storage: NftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }

    func loadOrder(id: String, completion: @escaping OrderCompletion) {
        let request = OrderRequest(id: id)
        
        networkClient.send(request: request, type: Order.self) { [weak storage] result in
            switch result {
            case .success(let order):
                print("Loaded order: \(order.id) with \(order.nfts.count) NFTs")
                            print("NFT IDs: \(order.nfts)")
                
                order.nfts.forEach{ nftID in
                }
                completion(.success(order))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadNft(id: String, completion: @escaping NftCompletion) {
        if let nft = storage.getNft(with: id) {
            completion(.success(nft))
            return
        }

        let request = NFTRequest(id: id)
        
        networkClient.send(request: request, type: Nft.self) { [weak storage] result in
            switch result {
            case .success(let nft):
                storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadNftCartModel(id: String, completion: @escaping nftCartModelCompletion) {
//        if let nft = storage.getNft(with: id) {
//            completion(.success(nft))
//            return
//        }

        let request = nftCartModelRequest(id: id)
        
        networkClient.send(request: request, type: nftCartModel.self) { [weak storage] result in
            switch result {
            case .success(let nft):
                //storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func changeOrPaytOrder(nftIds: [String], completion: @escaping OrderCompletion) {
        let request = ChangeOrPayOrder(nftIds: nftIds)  // Передаем массив
        
        networkClient.send(request: request, type: Order.self) { [weak storage] result in
            switch result {
            case .success(let order):
                print("Loaded order: \(order.id) with \(order.nfts.count) NFTs")
                            print("NFT IDs: \(order.nfts)")
                
                order.nfts.forEach{ nftID in
                }
                completion(.success(order))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadCurrencies(completion: @escaping currenciesCompletion) {
        let request = CurrencyRequest()
        
        networkClient.send(request: request, type: [Currency].self) { result in
            switch result {
            case .success(let currencies):
                completion(.success(currencies))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}
