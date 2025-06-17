import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateTabBar()
    }
    
    private func generateTabBar() {
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        let catalogViewController = UINavigationController(rootViewController: CatalogViewController())
        let cartViewController = UINavigationController(rootViewController: CartViewController())
        let statisticsViewController = UINavigationController(rootViewController: StatisticsViewController())
        
        tabBar.tintColor = .blueUniversal
        tabBar.unselectedItemTintColor = .buttonColor
        viewControllers = [
            generateVC(viewController: profileViewController,
                       title: NSLocalizedString("profile", comment: ""),
                       image: UIImage(named: "profile_tab")
                      ),
            generateVC(viewController: catalogViewController,
                       title: NSLocalizedString("catalog", comment: ""),
                       image: UIImage(named: "catalog_tab")
                      ),
            generateVC(viewController: cartViewController,
                       title: NSLocalizedString("cart", comment: ""),
                       image: UIImage(named: "cart_tab")
                      ),
            generateVC(viewController: statisticsViewController,
                       title: NSLocalizedString("statistics", comment: ""),
                       image: UIImage(named: "stats_tab")
                      )
        ]
    }
    
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .medium)]
        viewController.tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        viewController.tabBarItem.setTitleTextAttributes(attributes, for: .selected)
        
        return viewController
    }
}

