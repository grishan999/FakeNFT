import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileTab()
    }
    
    private func setupProfileTab() {
        let networkClient = DefaultNetworkClient()
        let storage = NftStorageImpl()
        
        let profileService = ProfileService(
            networkClient: networkClient
        )
        
        let profileViewModel = ProfileViewModel(
            profileService: profileService
        )
        
        let profileChangeViewModel = ProfileChangeViewModel(
            profileService: profileService
        )
        
        let profileViewController = UINavigationController(
            rootViewController: ProfileViewController(
                viewModel: profileViewModel,
                profileChangeViewModel: profileChangeViewModel,
                networkClient: networkClient,
                storage: storage
            )
        )
        
        tabBar.tintColor = .blueUniversal
        tabBar.unselectedItemTintColor = .buttonColor
        
        viewControllers = [
            generateVC(
                viewController: profileViewController,
                title: NSLocalizedString("profile", comment: ""),
                image: UIImage(named: "profile_tab")
            )
        ]
    }
    
    private func generateVC(
        viewController: UIViewController,
        title: String,
        image: UIImage?
    ) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .medium)]
        viewController.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        viewController.tabBarItem.setTitleTextAttributes(attributes, for: .selected)
        
        return viewController
    }
}
