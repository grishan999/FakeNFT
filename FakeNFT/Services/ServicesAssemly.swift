final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    
    func catalogViewModel() -> CatalogViewModel {
        let nftClient = NFTClient(networkClient: networkClient)
        return CatalogViewModel(nftClient: nftClient)
    }
    
    func nftCollectionViewModel(collectionId: String) -> NFTCollectionViewModelProtocol {
            NFTCollectionViewModel(collectionId: collectionId, networkClient: networkClient, nftService: nftService)
        }
}
