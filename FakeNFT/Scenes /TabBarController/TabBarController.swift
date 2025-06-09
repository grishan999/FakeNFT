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
            title: NSLocalizedString("Корзина", comment: ""),
            image: UIImage(systemName: "square.stack.3d.up.fill"),
            tag: 0
        )
        
        let cartTabBarItem = UITabBarItem(
            title: NSLocalizedString("Каталог", comment: ""),
            image: UIImage(named: "ActiveCartIcon"),
            tag: 1
        )
        
        
        let cartController = CartViewController(
            servicesAssembly: servicesAssembly
        )
        
        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        
        let cartNavigationController = UINavigationController(rootViewController: cartController)
        
        cartNavigationController.navigationBar.backgroundColor = .white
        cartNavigationController.navigationBar.barTintColor = .white
        cartNavigationController.navigationBar.isTranslucent = false
        cartNavigationController.navigationBar.shadowImage = UIImage()
    
    
    cartNavigationController.tabBarItem = cartTabBarItem
    catalogController.tabBarItem = catalogTabBarItem
    
    viewControllers = [catalogController, cartNavigationController]
    view.backgroundColor = . systemBackground
}
}
