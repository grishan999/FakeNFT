import Foundation
import UIKit
import ProgressHUD

final class CartViewController: UIViewController {
    
    let servicesAssembly: ServicesAssembly
    
    // MARK: - Data Properties
    private var nftCellStates: [NFTCellState] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.updateFooterInfo()
            }
        }
    }
    
    // MARK: - UI Elements
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
        button.isEnabled = false // ✅ Изначально отключена
        button.alpha = 0.5       // ✅ Визуально показываем что отключена
        return button
    }()
    
    // ✅ Индикатор загрузки для footer
    private lazy var footerActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .black
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // ✅ Состояние загрузки footer
    private var isFooterLoading = true {
        didSet {
            updateFooterLoadingState()
        }
    }
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
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
        updateFooterLoadingState() // ✅ Показываем shimmer с самого начала
        loadOrder()
    }

    
    // MARK: - Progress HUD Setup
    private func setupProgressHUD() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .black
    }
    
    // MARK: - Data Loading
    private func loadOrder() {
        servicesAssembly.nftService.loadOrder(id: "1") { [weak self] result in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                
                switch result {
                case .success(let order):
                    print("📦 Loaded order with \(order.nfts.count) NFTs")
                    self?.createSkeletonCells(for: order.nfts)
                    self?.loadNFTsData(ids: order.nfts)
                case .failure(let error):
                    self?.showError("Ошибка загрузки корзины: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // ✅ Создаем skeleton ячейки сразу после получения ID
    private func createSkeletonCells(for nftIDs: [String]) {
        nftCellStates = nftIDs.map { .loading(id: $0) }
        isFooterLoading = true // ✅ Включаем загрузку footer
        print("🔄 Created \(nftCellStates.count) skeleton cells")
    }
    
    // ✅ Загружаем данные для каждой NFT
    private func loadNFTsData(ids: [String]) {
        for (index, id) in ids.enumerated() {
            loadSingleNFT(id: id, at: index)
        }
    }
    
    private func loadSingleNFT(id: String, at index: Int) {
        servicesAssembly.nftService.loadNftCartModel(id: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self, index < self.nftCellStates.count else { return }
                
                switch result {
                case .success(let nft):
                    // ✅ Обновляем конкретную ячейку
                    self.nftCellStates[index] = .loaded(nft: nft)
                    self.updateSpecificCell(at: index)
                    print("✅ Loaded NFT at index \(index): \(nft.name)")
                    
                case .failure(let error):
                    // ✅ Показываем ошибку для конкретной ячейки
                    self.nftCellStates[index] = .error(id: id, error: error)
                    self.updateSpecificCell(at: index)
                    print("❌ Failed to load NFT at index \(index): \(error)")
                }
            }
        }
    }
    
    // ✅ Обновляем только конкретную ячейку
    private func updateSpecificCell(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        // Проверяем что ячейка видима
        if tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        // ✅ Проверяем загружены ли все NFT
        checkIfAllNFTsLoaded()
    }
    
    // ✅ Проверяем завершена ли загрузка всех NFT
    private func checkIfAllNFTsLoaded() {
        let loadedCount = nftCellStates.filter { !$0.isLoading }.count
        let totalCount = nftCellStates.count
        
        if loadedCount == totalCount && totalCount > 0 {
            // ✅ Все NFT загружены
            isFooterLoading = false
            print("🎉 All NFTs loaded! Showing final footer data")
        }
        
        updateFooterInfo()
    }
    
    // ✅ Управление состоянием загрузки footer
    private func updateFooterLoadingState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.isFooterLoading {
                // Показываем shimmer анимацию
                self.showFooterShimmer()
                self.footerActivityIndicator.startAnimating()
                self.payButton.isEnabled = false
                self.payButton.alpha = 0.5
            } else {
                // Скрываем shimmer анимацию
                self.hideFooterShimmer()
                self.footerActivityIndicator.stopAnimating()
                self.payButton.isEnabled = true
                self.payButton.alpha = 1.0
            }
        }
    }
    
    // ✅ Показываем shimmer анимацию в footer
    private func showFooterShimmer() {
        // ✅ Принудительно обновляем layout перед добавлением shimmer
        view.layoutIfNeeded()
        
        // Shimmer для количества NFT
        addShimmerToLabel(nftCountLabel, width: 50)
        
        // Shimmer для цены
        addShimmerToLabel(totalPriceLabel, width: 80)
        
        // ✅ Добавляем пульсацию к кнопке
        addPulseToPayButton()
    }
    
    // ✅ Скрываем shimmer анимацию
    private func hideFooterShimmer() {
        removeShimmerFromLabel(nftCountLabel)
        removeShimmerFromLabel(totalPriceLabel)
        removePulseFromPayButton()
    }
    
    // ✅ Добавляем shimmer анимацию к label
    private func addShimmerToLabel(_ label: UILabel, width: CGFloat) {
        // Очищаем текст
        label.text = ""
        
        // Устанавливаем фон для shimmer
        label.backgroundColor = UIColor.systemGray5
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        
        // ✅ Принудительно обновляем layout чтобы получить правильные размеры
        label.layoutIfNeeded()
        
        // ✅ Используем реальные размеры label вместо фиксированных
        let labelBounds = label.bounds.isEmpty ? CGRect(x: 0, y: 0, width: width, height: 20) : label.bounds
        
        // Создаем градиент для shimmer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray3.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        // ✅ Используем размеры label для правильного позиционирования
        gradientLayer.frame = labelBounds
        gradientLayer.cornerRadius = 8
        gradientLayer.name = "shimmerLayer"
        
        // ✅ Вставляем слой на задний план
        label.layer.insertSublayer(gradientLayer, at: 0)
        
        // Анимация движения shimmer
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.autoreverses = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }
    
    // ✅ Удаляем shimmer анимацию с label
    private func removeShimmerFromLabel(_ label: UILabel) {
        // Убираем фон
        label.backgroundColor = .clear
        label.layer.cornerRadius = 0
        label.clipsToBounds = false
        
        // Удаляем shimmer слои
        label.layer.sublayers?.removeAll { layer in
            layer.name == "shimmerLayer"
        }
    }
    
    // ✅ Обновляем shimmer слои при изменении размеров (если понадобится)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Обновляем shimmer слои если они активны
        if isFooterLoading {
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
    
    // ✅ Добавляем пульсацию к кнопке оплаты
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
    
    // ✅ Убираем пульсацию с кнопки оплаты
    private func removePulseFromPayButton() {
        payButton.layer.removeAnimation(forKey: "pulseAnimation")
    }
    
    // MARK: - Error Handling
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        addSubviews()
        setupConstraints()
        setupNavigationBar()
        // ✅ Убираем updateFooterInfo() отсюда - он будет вызываться из updateFooterLoadingState()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = ""
        
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .black
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    private func addSubviews() {
        view.addSubview(footerView)
        view.addSubview(tableView)
        
        footerView.addSubview(nftCountLabel)
        footerView.addSubview(totalPriceLabel)
        footerView.addSubview(payButton)
        footerView.addSubview(footerActivityIndicator) // ✅ Добавляем индикатор
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
            nftCountLabel.heightAnchor.constraint(equalToConstant: 20), // ✅ Фиксированная высота для shimmer
            
            totalPriceLabel.topAnchor.constraint(equalTo: nftCountLabel.bottomAnchor, constant: 4),
            totalPriceLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            totalPriceLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 90),
            totalPriceLabel.heightAnchor.constraint(equalToConstant: 20), // ✅ Фиксированная высота для shimmer
            
            payButton.leadingAnchor.constraint(equalTo: totalPriceLabel.trailingAnchor, constant: 24),
            payButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            payButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            payButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16),
            
            // ✅ Footer activity indicator
           // footerActivityIndicator.centerXAnchor.constraint(equalTo: nftCountLabel.trailingAnchor),
            footerActivityIndicator.centerXAnchor.constraint(equalTo: nftCountLabel.centerXAnchor),
            footerActivityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
        ])
    }
    
    private func updateFooterInfo() {
        // ✅ Не обновляем данные пока загружается
        guard !isFooterLoading else { return }
        
        let loadedNFTs = nftCellStates.compactMap { $0.nft }
        let count = nftCellStates.count
        let totalPrice = loadedNFTs.reduce(0) { $0 + $1.price }
        
        DispatchQueue.main.async { [weak self] in
            // ✅ Сначала убираем shimmer, потом показываем данные
            self?.hideFooterShimmer()
            self?.nftCountLabel.text = "\(count) NFT"
            self?.totalPriceLabel.text = String(format: "%.2f ETH", totalPrice)
        }
    }
    
    // MARK: - Actions
    @objc private func menuButtonTapped() {
        print("Menu button tapped")
    }
    
    @objc private func payButtonTapped() {
        print("Pay button tapped")
    }
    
    private func removeItem(at index: Int) {
        guard index < nftCellStates.count else { return }
        
        nftCellStates.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        
        // ✅ Проверяем состояние после удаления
        checkIfAllNFTsLoaded()
        
        print("✅ NFT удален из корзины")
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nftCellStates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        let cellState = nftCellStates[indexPath.row]
        cell.configure(with: cellState)
        
        // ✅ Передаем nftID в замыкание и показываем новое подтверждение
            cell.onRemove = { [weak self] nftID in
                guard let nftID = nftID else {
                    print("❌ Не удалось получить nftID для удаления")
                    return
                }
                
                print("🗑️ Запрос удаления NFT: \(nftID)")
                self?.showDeleteConfirmation(for: nftID)
            }
            
            return cell
    }
    
    // ✅ Показываем кастомное подтверждение удаления с ID и изображением
        func showDeleteConfirmation(for nftID: String) {
            // Находим NFT в массиве чтобы получить его изображение
            let nftImageURL = getNFTImageURL(for: nftID)
            
            DeleteConfirmationViewController.present(
                from: self,
                nftID: nftID,
                nftImageURL: nftImageURL,
                onDelete: { [weak self] confirmedNFTID in
                    print("🎯 Подтверждено удаление NFT: \(confirmedNFTID)")
                    self?.removeItemByID(confirmedNFTID)
                },
                onCancel: { cancelledNFTID in
                    print("❌ Отменено удаление NFT: \(cancelledNFTID)")
                }
            )
        }
        
        // ✅ Получаем URL изображения NFT по ID
        private func getNFTImageURL(for nftID: String) -> URL? {
            guard let cellState = nftCellStates.first(where: { $0.id == nftID }) else {
                return nil
            }
            
            switch cellState {
            case .loaded(let nft):
                return nft.imageURL
            default:
                return nil
            }
        }
        
    // ✅ Удаляем NFT по ID
    func removeItemByID(_ nftID: String) {
        // Получаем текущие NFT ID из состояния
        let currentNftIds = nftCellStates.map { $0.id }
        
        // ✅ Фильтруем массив (убираем удаляемый NFT)
        let filteredNftIds = currentNftIds.filter { $0 != nftID }
        
        print("🗑️ Удаляем NFT \(nftID)")
        print("📋 Было NFT: \(currentNftIds)")
        print("📋 Стало NFT: \(filteredNftIds)")
        
        // ✅ Отправляем PUT с отфильтрованным массивом
        servicesAssembly.nftService.changeOrder(nftIds: filteredNftIds) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ NFT \(nftID) успешно удален с сервера")
                    
                    // ✅ Обновляем UI - удаляем из массива
                    if let index = self?.nftCellStates.firstIndex(where: { $0.id == nftID }) {
                        self?.removeItem(at: index)
                    }
                    
                case .failure(let error):
                    print("❌ Ошибка удаления NFT \(nftID): \(error)")
                    self?.showError("Ошибка удаления товара: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}
