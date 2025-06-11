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
            title: NSLocalizedString("Tab.catalog", comment: ""),
            image: UIImage(systemName: "square.stack.3d.up.fill"),
            tag: 0
        )
        
        let catalogViewModel = servicesAssembly.catalogViewModel()
        let catalogController = CatalogViewController(viewModel: catalogViewModel, servicesAssembly: servicesAssembly)
        catalogController.tabBarItem = catalogTabBarItem
        
        let navController = UINavigationController(rootViewController: catalogController)
        
        viewControllers = [navController]
    }
}
