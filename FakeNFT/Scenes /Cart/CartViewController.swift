import Foundation
import UIKit
import ProgressHUD

// ✅ Единая структура состояния - все данные для View в одном месте
struct CartViewState {
    let cellStates: [NFTCellState]
    let doneLoading: Bool
    let footerInfo: FooterInfo?
    
    struct FooterInfo {
        let count: Int
        let totalPrice: Double
        let isPayButtonEnabled: Bool
    }
    
    // ✅ Статический метод для начального состояния
    static var initial: CartViewState {
        return CartViewState(cellStates: [], doneLoading: false, footerInfo: nil)
    }
}

final class CartViewController: UIViewController {
    
    // MARK: - Properties
    
    private let servicesAssembly: ServicesAssembly
    private let viewModel: CartViewModelProtocol
    
    // ✅ View хранит только текущее состояние для отображения
    private var currentState: CartViewState = .initial
    
    // MARK: - UI Elements (все элементы остаются прежними)
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.identifier)
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP LightGrey")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nftCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("К оплате", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private lazy var footerActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .black
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Init
    
    // ✅ Инжектируем ViewModel через протокол для лучшей тестируемости
    init(servicesAssembly: ServicesAssembly, viewModel: CartViewModelProtocol) {
        self.servicesAssembly = servicesAssembly
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings() // ✅ Настраиваем связи сразу при создании
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressHUD()
        ProgressHUD.show("Загрузка корзины...")
        setupUI()
        updateFooter(currentState)
        
        // ✅ Просто сообщаем ViewModel что View готово
        viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    // MARK: - Bindings Setup
    
    // ✅ Настраиваем реактивные связи с ViewModel
    private func setupBindings() {
        // ✅ Подписываемся на изменения состояния
        viewModel.onStateChanged = { [weak self] state in
            self?.updateState(state)
        }
        
        // ✅ Подписываемся на ошибки
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        // ✅ Подписываемся на запросы показа диалога удаления
        viewModel.onShowDeleteConfirmation = { [weak self] nftID, imageURL in
            self?.showDeleteConfirmation(nftID: nftID, imageURL: imageURL)
        }
    }
    
    // MARK: - State Updates
    
    private func updateState(_ state: CartViewState) {
        
        
        currentState = state
        
        // 🔄 Простое обновление - всегда перерисовываем таблицу
        tableView.reloadData()
        
        // 🦶 Обновляем footer на основе нового состояния
        updateFooter(state)
        
        // 🫥 Скрываем прогресс после получения данных
        ProgressHUD.dismiss()
        
    }
    
    private func updateState(_ state: CartViewState, changedIndex: Int? = nil) {
         
         currentState = state
         
         // 🎯 ОПТИМИЗАЦИЯ: обновляем только изменившуюся ячейку
         if let changedIndex = changedIndex,
            changedIndex < state.cellStates.count {
             
             print("🎯 Оптимизированное обновление ячейки \(changedIndex)")
             
             // Обновляем только конкретную ячейку
             let indexPath = IndexPath(row: changedIndex, section: 0)
             
             // Проверяем что ячейка видна
             if tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                 tableView.reloadRows(at: [indexPath], with: .fade)
                 print("✅ Перерисована только ячейка \(changedIndex)")
             }
         } else {
             // Полное обновление таблицы
             //tableView.reloadData()
             print("🔄 Полное обновление таблицы")
         }
         
         updateFooter(state)
         ProgressHUD.dismiss()
     }
    

    
    // ✅ Обновляем footer на основе состояния
    private func updateFooter(_ state: CartViewState) {
        if state.doneLoading == false {
            // ✅ Показываем shimmer во время загрузки
            showFooterShimmer()
            footerActivityIndicator.startAnimating()
            payButton.isEnabled = false
            payButton.alpha = 0.5
        } else if let footerInfo = state.footerInfo {
            // ✅ Показываем реальные данные
            hideFooterShimmer()
            footerActivityIndicator.stopAnimating()
            nftCountLabel.text = "\(footerInfo.count) NFT"
            totalPriceLabel.text = String(format: "%.2f ETH", footerInfo.totalPrice)
            payButton.isEnabled = footerInfo.isPayButtonEnabled
            payButton.alpha = footerInfo.isPayButtonEnabled ? 1.0 : 0.5
        }
    }
    
    // MARK: - Error Handling
    
    private func showError(_ message: String) {
        ProgressHUD.dismiss()
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // ✅ Показываем диалог подтверждения удаления
    private func showDeleteConfirmation(nftID: String, imageURL: URL?) {
        if imageURL == nil {
            showError("Ошибка, попробуйте позже")
            return
        }
        
        DeleteConfirmationViewController.present(
            from: self,
            nftID: nftID,
            nftImageURL: imageURL,
            onDelete: { [weak self] confirmedNFTID in
                print("🎯 Подтверждено удаление NFT: \(confirmedNFTID)")
                // ✅ Делегируем выполнение удаления ViewModel
                self?.viewModel.confirmRemoveItem(nftID: confirmedNFTID)
            },
            onCancel: { cancelledNFTID in
                print("❌ Отменено удаление NFT: \(cancelledNFTID)")
            }
        )
    }
    
    // MARK: - UI Setup (методы остаются прежними)
    
    private func setupProgressHUD() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .black
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = ""
        
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(named: "MenuButton"), for: .normal)
        menuButton.tintColor = .black
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        // ✅ Создаем контейнер с отступами
        let containerView = UIView()
        containerView.addSubview(menuButton)
        
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            menuButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            menuButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16), // отступ слева
            menuButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            containerView.widthAnchor.constraint(equalToConstant: 60), // ширина контейнера
            containerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: containerView)
    }
    
    private func addSubviews() {
        view.addSubview(footerView)
        view.addSubview(tableView)
        
        footerView.addSubview(nftCountLabel)
        footerView.addSubview(totalPriceLabel)
        footerView.addSubview(payButton)
        footerView.addSubview(footerActivityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Footer view
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 76),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            // Footer elements
            nftCountLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16),
            nftCountLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            nftCountLabel.widthAnchor.constraint(equalToConstant: 79),
            nftCountLabel.heightAnchor.constraint(equalToConstant: 20),
            
            totalPriceLabel.topAnchor.constraint(equalTo: nftCountLabel.bottomAnchor, constant: 4),
            totalPriceLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            totalPriceLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 90),
            totalPriceLabel.heightAnchor.constraint(equalToConstant: 20),
            
            payButton.leadingAnchor.constraint(equalTo: totalPriceLabel.trailingAnchor, constant: 24),
            payButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            payButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            payButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16),
            payButton.widthAnchor.constraint(equalToConstant: 240),
            
            footerActivityIndicator.centerXAnchor.constraint(equalTo: nftCountLabel.centerXAnchor),
            footerActivityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func menuButtonTapped() {
        print("Menu button tapped")
    }
    
    @objc private func payButtonTapped() {
        print("Pay button tapped")
    }
    
    // MARK: - Shimmer Animation (методы остаются прежними)
    
    private func showFooterShimmer() {
        view.layoutIfNeeded()
        addShimmerToLabel(nftCountLabel, width: 50)
        addShimmerToLabel(totalPriceLabel, width: 80)
        addPulseToPayButton()
    }
    
    private func hideFooterShimmer() {
        removeShimmerFromLabel(nftCountLabel)
        removeShimmerFromLabel(totalPriceLabel)
        removePulseFromPayButton()
    }
    
    private func addShimmerToLabel(_ label: UILabel, width: CGFloat) {
        label.text = ""
        label.backgroundColor = UIColor.systemGray5
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.layoutIfNeeded()
        
        let labelBounds = label.bounds.isEmpty ? CGRect(x: 0, y: 0, width: width, height: 20) : label.bounds
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray3.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = labelBounds
        gradientLayer.cornerRadius = 8
        gradientLayer.name = "shimmerLayer"
        
        label.layer.insertSublayer(gradientLayer, at: 0)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.autoreverses = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }
    
    private func removeShimmerFromLabel(_ label: UILabel) {
        label.backgroundColor = .clear
        label.layer.cornerRadius = 0
        label.clipsToBounds = false
        
        label.layer.sublayers?.removeAll { layer in
            layer.name == "shimmerLayer"
        }
    }
    
    private func addPulseToPayButton() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 0.5
        pulseAnimation.toValue = 0.3
        pulseAnimation.duration = 1.0
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.autoreverses = true
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        payButton.layer.add(pulseAnimation, forKey: "pulseAnimation")
    }
    
    private func removePulseFromPayButton() {
        payButton.layer.removeAnimation(forKey: "pulseAnimation")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !currentState.doneLoading {
            updateShimmerFrames()
        }
    }
    
    private func updateShimmerFrames() {
        updateShimmerFrame(for: nftCountLabel)
        updateShimmerFrame(for: totalPriceLabel)
    }
    
    private func updateShimmerFrame(for label: UILabel) {
        guard let shimmerLayer = label.layer.sublayers?.first(where: { $0.name == "shimmerLayer" }) else {
            return
        }
        shimmerLayer.frame = label.bounds
    }
}

// MARK: - UITableViewDataSource

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ✅ Используем currentState как единственный источник данных
        return currentState.cellStates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        // ✅ Безопасно получаем состояние ячейки
        let cellState = currentState.cellStates[indexPath.row]
        cell.configure(with: cellState)
        
        // ✅ Передаем действие удаления во ViewModel
        cell.onRemove = { [weak self] nftID in
            guard let nftID = nftID else {
                print("❌ Не удалось получить nftID для удаления")
                return
            }
            
            print("🗑️ Запрос удаления NFT: \(nftID)")
            // ✅ View делегирует решение ViewModel
            self?.viewModel.removeItemRequested(nftID: nftID)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
