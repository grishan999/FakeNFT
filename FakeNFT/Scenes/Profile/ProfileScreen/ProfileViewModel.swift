import UIKit
import Kingfisher

protocol ProfileViewModelDelegate: AnyObject {
    func didReceiveProfileData(
        profileImageURL: String?,
        userName: String?,
        userDescription: String?,
        userWebsite: String?
    )
    func didReceiveMyNFT(myNFT: [String]?)
    func didReceiveFavoriteNFT(favoriteNFT: [String]?)
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
    
    var myNFT: [String] = []
    var favoriteNFT: [String] = []
    
    // MARK: - Callbacks
    var profileUpdated: (() -> Void)?
    var profileImageUpdated: ((UIImage?) -> Void)?
    
    // MARK: - Initializer
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }
    
    // MARK: - Data Loading
    func loadProfile() {
        profileService.loadProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.myNFT = profile.nfts
                self.delegate?.didReceiveMyNFT(myNFT: self.myNFT)
                self.favoriteNFT = profile.likes
                self.delegate?.didReceiveFavoriteNFT(favoriteNFT: self.favoriteNFT)
                self.loadProfileImage()
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
                self.profileImageUpdated?(nil)
            }
        }
    }
    
    // MARK: - Action Handling
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
}
