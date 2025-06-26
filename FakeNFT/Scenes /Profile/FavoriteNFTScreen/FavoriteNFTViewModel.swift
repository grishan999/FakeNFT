import UIKit
import Kingfisher

final class FavoriteNFTViewModel {
    
    // MARK: - Dependencies
    private let nftService: NftService
    
    // MARK: - Public Properties
    var nft: Nft? {
        didSet {
            nftsUpdated?()
        }
    }
    
    var nftImageUrl: String {
        return nft?.images.first?.absoluteString ?? ""
    }
    
    var nftsUpdated: (() -> Void)?
    var nftsImageUpdate: ((String, UIImage?) -> Void)?
    
    // MARK: - Data for UIController
    var likedNFTs: [Nft] = []
    var favoriteNFT: [String]? = []
    var nftImages: [String: UIImage] = [:]
    
    // MARK: - Initializer
    init(nftService: NftService) {
        self.nftService = nftService
    }
    
    func configure(
        with viewModel: ProfileViewModel
    ) {
        viewModel.delegate = self
        viewModel.fetchFavoriteNFTData()
    }
    
    // MARK: - Data Loading
    func loadLikedNFTs(likes: [String]) {
        likedNFTs = []
        let dispatchGroup = DispatchGroup()
        
        for nftId in likes {
            dispatchGroup.enter()
            nftService.loadNft(id: nftId) { [weak self] result in
                guard let self = self else { return }
                defer { dispatchGroup.leave() }
                
                switch result {
                case .success(let nft):
                    self.likedNFTs.append(nft)
                    self.nft = nft
                    self.loadNFTImage(for: nft)
                    
                case .failure(let error):
                    print("Ошибка загрузки NFT с id \(nftId): \(error)")
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.nftsUpdated?()
        }
    }
    
    func loadNFTImage(for nft: Nft) {
            guard let imageURL = nft.images.first else { return } 

            KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.nftImages[nft.id] = value.image

                    if let index = self.likedNFTs.firstIndex(where: { $0.id == nft.id }) {
                        let oldNFT = self.likedNFTs[index]
                        let newNFT = Nft(
                            id: oldNFT.id,
                            images: oldNFT.images,
                            name: nftImageUrl.extractNFTName(from: nftImageUrl) ?? oldNFT.name,
                            rating: oldNFT.rating,
                            description: oldNFT.description,
                            price: oldNFT.price,
                            author: oldNFT.author
                        )
                        self.likedNFTs[index] = newNFT
                    }
                    self.nftsImageUpdate?(nft.id, value.image)

                case .failure(let error):
                    print("Ошибка загрузки изображения NFT: \(error)")
                    self.nftsImageUpdate?(nft.id, nil)
                }
            }
        }
    
    func ratingImage(
        for nft: Nft
    ) -> UIImage? {
        let rating = min(max(nft.rating, 0), 5)
        return UIImage(
            named: "rating_\(rating)"
        )
    }
}

//MARK - Delegate
extension FavoriteNFTViewModel: ProfileViewModelDelegate {
    func didReceiveProfileData(
        profileImageURL: String?,
        userName: String?,
        userDescription: String?,
        userWebsite: String?
    ) {  // TODO:
    }
    
    func didReceiveMyNFT(
        myNFT: [String]?
    ) {// TODO:
    }
    
    func didReceiveFavoriteNFT(
        favoriteNFT: [String]?
    ) {
        self.favoriteNFT = favoriteNFT
    }
}
