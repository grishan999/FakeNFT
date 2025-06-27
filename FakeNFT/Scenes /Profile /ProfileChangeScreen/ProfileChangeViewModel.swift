import UIKit
import Kingfisher

final class ProfileChangeViewModel {
    
    // MARK: - Dependencies
    private let profileService: ProfileServiceProtocol
    
    // MARK: - Public Properties
    var profile: ProfileModel? {
        didSet {
            profileUpdated?()
        }
    }
    
    var profileImageUrl: String?
    var userName: String?
    var userDescription: String?
    var userWebsite: String?
    
    //MARK: - Callbacks
    var profileUpdated: (() -> Void)?
    var profileImageUpdated: ((UIImage?) -> Void)?
    
    // MARK: - Initializer
    init(
        profileService: ProfileServiceProtocol
    ) {
        self.profileService = profileService
    }
    
    func configure(
        with viewModel: ProfileViewModel
    ) {
        viewModel.delegate = self
        viewModel.fetchProfileData()
    }
    
    
    // MARK: - Data Loading
    func updateProfile(
        name: String,
        avatar: String,
        description: String,
        website: String,
        completion: @escaping (Result<ProfilePutResponse, Error>) -> Void
    ) {
        profileService.sendProfilePutRequest(
            param1: name,
            param2: avatar,
            param3: description,
            param4: website
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                print("Профиль успешно обновлен")
                self.userName = response.name
                self.userDescription = response.description
                self.userWebsite = response.website
                self.profileImageUrl = response.avatar
                self.profileUpdated?()
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadProfileImage() {
        guard let imageURL = URL(string: profileImageUrl ?? "") else {
            print("Некорректный URL: \(String(describing: profileImageUrl))")
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
}

extension ProfileChangeViewModel: ProfileViewModelDelegate {
    func didReceiveFavoriteNFT(favoriteNFT: [String]?) {}
    
    func didReceiveMyNFT(myNFT: [String]?) {}
    
    func didReceiveProfileData(
        profileImageURL: String?,
        userName: String?,
        userDescription: String?,
        userWebsite: String?
    ) {
        self.profileImageUrl = profileImageURL
        self.userName = userName
        self.userDescription = userDescription
        self.userWebsite = userWebsite
    }
}
