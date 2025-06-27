import UIKit

final class TabBarController: UITabBarController {
    var servicesAssembly: ServicesAssembly! {
        didSet {
            setupViewControllers()
        }
    }
    
    private func setupViewControllers() {
        guard servicesAssembly != nil else { return }
        
        let catalogTabBarItem = UITabBarItem(
            title: NSLocalizedString("Каталог", comment: ""),
            image: UIImage(named: "catalog_tab"),
            tag: 0
        )
        
        let catalogViewModel = servicesAssembly.catalogViewModel()
        let catalogController = CatalogViewController(
            viewModel: catalogViewModel,
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        
        let cartTabBarItem = UITabBarItem(
            title: NSLocalizedString("Корзина", comment: ""),
            image: UIImage(named: "ActiveCartIcon"),
            tag: 1
        )
        
        let cartViewModel: CartViewModelProtocol = CartViewModel(servicesAssembly: servicesAssembly)
        let cartController = CartViewController(
            servicesAssembly: servicesAssembly,
            viewModel: cartViewModel
        )
        let cartNavigationController = UINavigationController(rootViewController: cartController)
        
        // Стиль навигации для Корзины
        cartNavigationController.navigationBar.backgroundColor = .white
        cartNavigationController.navigationBar.barTintColor = .white
        cartNavigationController.navigationBar.tintColor = .black
        cartNavigationController.navigationBar.isTranslucent = true
        cartNavigationController.navigationBar.shadowImage = UIImage()
        cartNavigationController.tabBarItem = cartTabBarItem
        
        let profileTabBarItem = UITabBarItem(
            title: NSLocalizedString("profile", comment: ""),
            image: UIImage(named: "profile_tab"),
            tag: 2
        )
        
        let profileService = ProfileService(networkClient: DefaultNetworkClient())
        let profileViewModel = ProfileViewModel(profileService: profileService)
        let profileChangeViewModel = ProfileChangeViewModel(profileService: profileService)
        
        let profileController = ProfileViewController(
            viewModel: profileViewModel,
            profileChangeViewModel: profileChangeViewModel,
            networkClient: DefaultNetworkClient(),
            storage: NftStorageImpl()
        )
        
        let profileNavigationController = UINavigationController(rootViewController: profileController)
        profileNavigationController.tabBarItem = profileTabBarItem
        
        tabBar.tintColor = .blueUniversal
        tabBar.unselectedItemTintColor = .black
        
        viewControllers = [
            catalogNavigationController,
            cartNavigationController,
            profileNavigationController
        ]
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .medium)]
        viewControllers?.forEach {
            $0.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
            $0.tabBarItem.setTitleTextAttributes(attributes, for: .selected)
        }
    }
}
