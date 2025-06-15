import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    // MARK: - Private Methods
    private func setupTabBar() {
        tabBar.tintColor = .blue
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = false
    }
    
    private func setupViewControllers() {
        let networkClient = DefaultNetworkClient()
        
        // Profile
        let profileService = ProfileService(networkClient: networkClient)
        let profileViewModel = ProfileViewModel(profileService: profileService)
        let profileVC = ProfileViewController(viewModel: profileViewModel)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        
        profileNav.tabBarItem = createTabBarItem(
            title: NSLocalizedString("profile", comment: ""),
            image: UIImage(named: "profile_tab")
        )
        
        
        viewControllers = [profileNav]
    }
    
    private func createTabBarItem(title: String, image: UIImage?) -> UITabBarItem {
        let tabBarItem = UITabBarItem(
            title: title,
            image: image,
            selectedImage: nil
        )
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        tabBarItem.setTitleTextAttributes(attributes, for: .selected)
        
        return tabBarItem
    }
}
