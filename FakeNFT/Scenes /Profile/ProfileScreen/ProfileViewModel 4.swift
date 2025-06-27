import UIKit
import Kingfisher

protocol ProfileViewModelDelegate: AnyObject {
    func didReceiveProfileData(
        profileImageURL: String?,
        userName: String?,
        userDescription: String?,
        userWebsite: String?
    )
    
    func didReceiveMyNFT(
        myNFT: [String]?
    )
    func didReceiveFavoriteNFT(
        favoriteNFT: [String]?
    )
}

final class ProfileViewModel {
    
    // MARK: - Dependencies
    private let profileService: ProfileServiceProtocol
    weak var delegate: ProfileViewModelDelegate?
    
    // MARK: - Public Properties
    var profile: ProfileModel? {
        didSet {
            profileUpdated?()
        }
    }
    
    var profileImageUrl: String {
        profile?.avatar ?? ""
    }
    
    var userName: String {
        profile?.name ?? ""
    }
    
    var userDescription: String {
        profile?.description ?? ""
    }
    
    var userWebsite: String {
        profile?.website ?? ""
    }
    
    var items: [ProfileItem] = []
    var myNFT: [String] = []
    var favoriteNFT: [String] = []
    var nftImages: [String: UIImage] = [:]
    
    //MARK: - Callbacks
    var profileUpdated: (() -> Void)?
    var profileImageUpdated: ((UIImage?) -> Void)?
    
    // MARK: - Initializer
    init(
        profileService: ProfileServiceProtocol
    ) {
        self.profileService = profileService
    }
    
    // MARK: - Data Loading
    func loadProfile() {
        profileService.loadProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                print(self.userName)
                self.myNFT = profile.nfts
                self.delegate?.didReceiveMyNFT(myNFT: myNFT)
                self.favoriteNFT = profile.likes
                self.loadProfileImage()
                self.items = [
                    ProfileItem(
                        categoryName: localizedString(key: "myNFT"),
                        count: profile.nfts.count
                    ),
                    ProfileItem(
                        categoryName: localizedString(key: "favoriteNFT"),
                        count: profile.likes.count
                    ),
                    ProfileItem(
                        categoryName: localizedString(key: "aboutTheDeveloper")
                    )
                ]
                self.profileUpdated?()
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error)")
            }
        }
    }
    
    func loadProfileImage() {
        guard let imageURL = URL(string: profileImageUrl) else {
            print("Некорректный URL: \(profileImageUrl)")
            return
        }
        KingfisherManager.shared.retrieveImage(with: imageURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.profileImageUpdated?(value.image)
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
                if case .processorError(let reason) = error {
                    print("Ошибка процессора: \(reason)")
                }
                self.profileImageUpdated?(nil)
            }
        }
    }
    
    // MARK: - Логика обработки нажатий на ячейки
    func didSelectItem(at index: Int) -> ProfileAction {
        switch index {
        case 0:
            return .navigateToMyNFTs
        case 1:
            return .navigateToFavorites
        case 2:
            return .openUserWebsite(url: userWebsite)
        default:
            return .none
        }
    }
    //MARK: - Method Delegate
    
    func fetchProfileData() {
        let profileImageURL = profileImageUrl
        let userName = userName
        let userDescription = userDescription
        let userWebsite = userWebsite
        
        delegate?.didReceiveProfileData(
            profileImageURL: profileImageURL,
            userName: userName,
            userDescription: userDescription,
            userWebsite: userWebsite
        )
    }
    
    func fetchNFTData() {
        let myNFT = myNFT
        delegate?.didReceiveMyNFT(
            myNFT: myNFT
        )
    }
    
    func fetchFavoriteNFTData() {
        let favoriteNFT = favoriteNFT
        delegate?.didReceiveFavoriteNFT(
            favoriteNFT: favoriteNFT
        )
    }
}
