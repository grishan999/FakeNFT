import UIKit

final class SuccessPaymentViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var successImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "SuccessNFT")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var successLabel: UILabel = {
        let label = UILabel()
        label.text = "Успех! Оплата прошла,\nпоздравляем с покупкой!"
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backToCatalogButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вернуться в каталог", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backToCatalogTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(successImageView)
        view.addSubview(successLabel)
        view.addSubview(backToCatalogButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Success Image
            successImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            successImageView.widthAnchor.constraint(equalToConstant: 200),
            successImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Success Label
            successLabel.topAnchor.constraint(equalTo: successImageView.bottomAnchor, constant: 32),
            successLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            successLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Back to Catalog Button
            backToCatalogButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backToCatalogButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            backToCatalogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            backToCatalogButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func backToCatalogTapped() {
        
        //  Получаем TabBarController из SceneDelegate
        if let tabBarController = getTabBarControllerFromSceneDelegate() {
            print("🎯 Найден TabBarController из SceneDelegate")
            
            //  CartViewController находится во второй вкладке (index 1)
            if let cartNavController = tabBarController.viewControllers?[1] as? UINavigationController,
               let cartVC = cartNavController.viewControllers.first as? CartViewController {
                
                print("🛒 Найден CartViewController в TabBar")
                
                //  Создаем пустое состояние корзины
                let emptyState = CartViewState(
                    cellStates: [],
                    doneLoading: true,
                    footerInfo: CartViewState.FooterInfo(
                        count: 0,
                        totalPrice: 0.0,
                        isPayButtonEnabled: false
                    )
                )
                //  Обновляем состояние CartViewController напрямую
                cartVC.updateCartToEmptyState(emptyState)
                
                //  Закрываем ВСЕ modal экраны до TabBar, потом переключаем вкладку
                tabBarController.dismiss(animated: true) { [weak tabBarController] in
                    print("🔄 Все modal экраны закрыты, переключаемся на вкладку корзины")
                    tabBarController?.selectedIndex = 1
                    print(" Переключились на вкладку корзины")
                }
                
            } else {
                print(" CartViewController не найден в TabBar")
                dismiss(animated: true)
            }
            
        } else {
            print(" TabBarController не найден в SceneDelegate")
            dismiss(animated: true)
        }
    }
    
    private func getTabBarControllerFromSceneDelegate() -> TabBarController? {
        //  Получаем активную WindowScene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window,
              let tabBarController = window.rootViewController as? TabBarController else {
            return nil
        }
        
        return tabBarController
    }
    
}

// MARK: - Factory Method
extension SuccessPaymentViewController {
    static func create() -> SuccessPaymentViewController {
        return SuccessPaymentViewController()
    }
}
