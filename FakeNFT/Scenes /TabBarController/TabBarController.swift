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
        
        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem
        
        viewControllers = [catalogController]
        view.backgroundColor = .systemBackground 
    }
}
