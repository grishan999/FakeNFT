import UIKit

final class TabBarController: UITabBarController {
    var servicesAssembly: ServicesAssembly! {
        didSet {
            setupViewControllers()
        }
    }
    
    private func setupViewControllers() {
        guard servicesAssembly != nil else { return }
        
        // Настройка таба Каталога
        let catalogTabBarItem = UITabBarItem(
            title: NSLocalizedString("Каталог", comment: ""),
            image: UIImage(systemName: "square.stack.3d.up.fill"),
            tag: 0
        )
        
        let catalogViewModel = servicesAssembly.catalogViewModel()
        let catalogController = CatalogViewController(
            viewModel: catalogViewModel,
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem
        
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        
        // Настройка таба Корзины
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
        
        // Настройки TabBar
        tabBar.unselectedItemTintColor = .black
        
        // Установка контроллеров
        viewControllers = [catalogNavigationController, cartNavigationController]
        view.backgroundColor = .systemBackground
    }
}
