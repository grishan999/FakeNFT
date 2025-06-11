import UIKit

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
            image: UIImage(systemName: "square.stack.3d.up.fill"),
            tag: 0
        )
        
        let cartTabBarItem = UITabBarItem(
            title: NSLocalizedString("Корзина", comment: ""),
            image: UIImage(named: "ActiveCartIcon"),
            tag: 1
        )
        
        // ✅ Используем новый CartViewModel вместо старого ViewModel
        let viewModel: CartViewModelProtocol = CartViewModel(servicesAssembly: servicesAssembly)
        
        // ✅ Передаем ViewModel через протокол
        let cartController = CartViewController(
            servicesAssembly: servicesAssembly,
            viewModel: viewModel
        )
        
        // ❌ УБИРАЕМ эту строку - теперь связи настраиваются через bindings
        // viewModel.view = cartController
        
        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        
        let cartNavigationController = UINavigationController(rootViewController: cartController)
        
        cartNavigationController.navigationBar.backgroundColor = .white
        cartNavigationController.navigationBar.barTintColor = .white
        cartNavigationController.navigationBar.tintColor = .black
        cartNavigationController.navigationBar.isTranslucent = true
        cartNavigationController.navigationBar.shadowImage = UIImage()
        
        // ✅ Настройки для tab bar (ПОСЛЕ создания viewControllers)
              // активная иконка
        tabBar.unselectedItemTintColor = .black  // неактивные иконки
       
        
        cartNavigationController.tabBarItem = cartTabBarItem
        catalogController.tabBarItem = catalogTabBarItem
        
        viewControllers = [catalogController, cartNavigationController]
        view.backgroundColor = .systemBackground
    }
}
