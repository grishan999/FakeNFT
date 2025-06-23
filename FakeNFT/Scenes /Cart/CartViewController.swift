import Foundation
import UIKit
import ProgressHUD

enum SortTypeCart: String, CaseIterable {
    case price = "price"
    case rating = "rating"
    case name = "name"
}

//  Единая структура состояния - все данные для View в одном месте
struct CartViewState {
    var cellStates: [NFTCellState]
    let doneLoading: Bool
    let footerInfo: FooterInfo?
    
    struct FooterInfo {
        let count: Int
        let totalPrice: Double
        let isPayButtonEnabled: Bool
    }
    
    //  Статический метод для начального состояния
    static var initial: CartViewState {
        return CartViewState(cellStates: [], doneLoading: false, footerInfo: nil)
    }
}

final class CartViewController: UIViewController {
    
    // MARK: - Properties
    
    private let servicesAssembly: ServicesAssembly
    private let viewModel: CartViewModelProtocol
    
    //  View хранит только текущее состояние для отображения
    private var currentState: CartViewState = .initial
    
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .left
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
    
    private lazy var emptyCartLabel: UILabel = {
        let label = UILabel()
        label.text = "Корзина пуста"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(servicesAssembly: ServicesAssembly, viewModel: CartViewModelProtocol) {
        self.servicesAssembly = servicesAssembly
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings() //  Настраиваем связи сразу при создании
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
        
        //  Просто сообщаем ViewModel что View готово
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //viewModel.viewDidLoad()
    }
    
    private func setupEmptyCartLabel() {
        view.addSubview(emptyCartLabel)
        
        NSLayoutConstraint.activate([
            emptyCartLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCartLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyCartLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyCartLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func updateEmptyState(_ state: CartViewState) {
        let shouldShowEmptyLabel = state.doneLoading && state.cellStates.isEmpty
        
        //  Показываем/скрываем "Корзина пуста"
        emptyCartLabel.isHidden = !shouldShowEmptyLabel
        
        //  Скрываем/показываем footer при пустой корзине
        footerView.isHidden = shouldShowEmptyLabel
        
        //  Скрываем/показываем tableView при пустой корзине
        tableView.isHidden = shouldShowEmptyLabel
        
        print("🛒 Empty state: \(shouldShowEmptyLabel)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    
    // MARK: - Bindings Setup
    
    //  Настраиваем реактивные связи с ViewModel
    private func setupBindings() {
        //  ПОЛНОЕ ОБНОВЛЕНИЕ: только для skeleton ячеек, удаления
        viewModel.onStateChanged = { [weak self] state in
            self?.updateStateWithFullReload(state)
        }
        
        //  ТОЧЕЧНОЕ ОБНОВЛЕНИЕ: только для загрузки отдельных NFT
        viewModel.onStateChangedWithIndex = { [weak self] state, index in
            self?.updateStateWithCellReload(state, changedIndex: index)
        }
        
        // ОБНОВЛЕНИЕ FOOTER: только footer, никаких reloadData()
        viewModel.onFooterUpdated = { [weak self] state in
            self?.updateFooterOnly(state)
               self?.sortNfts()
        }
        
        //  Подписываемся на ошибки
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        //  Подписываемся на запросы показа диалога удаления
        viewModel.onShowDeleteConfirmation = { [weak self] nftID, imageURL in
            self?.showDeleteConfirmation(nftID: nftID, imageURL: imageURL)
        }
        
        // Подписываемся на получение сортированного массива
        viewModel.onGetSortedNfts = { [weak self] nftsArray in
            self?.currentState.cellStates = nftsArray
            self?.tableView.reloadData()
        }
        
        
    }
    
    // MARK: - State Updates
    
    private func sortNfts(){
        guard let sortOrder = FilterStorage.shared.chosenFilter else { return }
        
        switch sortOrder {
        case "price":
            viewModel.sortBy(.price)
        case "rating":
            viewModel.sortBy(.rating)
        case "name":
            viewModel.sortBy(.name)
        default:
            print(" Неизвестная сортировка: '\(sortOrder)'")
        }
    }
    
    //  ПОЛНОЕ ОБНОВЛЕНИЕ: reloadData() - вызывается только для skeleton, footer, удаления
    private func updateStateWithFullReload(_ state: CartViewState) {
        print(" ПОЛНОЕ обновление: reloadData()")
        
        if state.cellStates.isEmpty {
            ProgressHUD.dismiss()
            footerView.isHidden = true
            emptyCartLabel.isHidden = false
            return
        }
        
        currentState = state
        
        //  ЕДИНСТВЕННЫЕ случаи reloadData():
        // 1. Создание skeleton ячеек
        // 2. Завершение загрузки (обновление footer)
        // 3. Удаление NFT
        tableView.reloadData()
        
        //  Обновляем footer на основе нового состояния
        updateFooter(state)
        
        //  Скрываем прогресс после получения данных
        ProgressHUD.dismiss()
    }
    
    // ТОЧЕЧНОЕ ОБНОВЛЕНИЕ: reloadRows() - вызывается для загрузки отдельных NFT
    private func updateStateWithCellReload(_ state: CartViewState, changedIndex: Int) {
        print(" ТОЧЕЧНОЕ обновление ячейки \(changedIndex)")
        
        currentState = state
        
        //  Проверяем валидность индекса
        guard changedIndex < state.cellStates.count else {
            print(" Индекс \(changedIndex) выходит за границы массива (\(state.cellStates.count))")
            return
        }
        
        //  Обновляем только конкретную ячейку
        let indexPath = IndexPath(row: changedIndex, section: 0)
        
        // Проверяем что ячейка видна на экране
        if tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
            tableView.reloadRows(at: [indexPath], with: .none)
            print(" Перерисована только ячейка \(changedIndex)")
        } else {
            print("👻 Ячейка \(changedIndex) не видна, пропускаем обновление")
            // Ячейка не видна - она обновится автоматически при появлении
        }
        
        //  Обновляем footer (может измениться при загрузке NFT)
        updateFooter(state)
        
        //  Скрываем прогресс после получения данных
        ProgressHUD.dismiss()
    }
    
    //  ОБНОВЛЕНИЕ FOOTER: только footer, никаких reloadData()
    private func updateFooterOnly(_ state: CartViewState) {
        print(" ОБНОВЛЕНИЕ только footer")
        
        currentState = state
        
        //  Обновляем только footer
        updateFooter(state)
        
        //  Скрываем прогресс после получения данных
        ProgressHUD.dismiss()
    }
    
    //  Обновляем footer на основе состояния
    private func updateFooter(_ state: CartViewState) {
        updateEmptyState(state)
        
        if state.doneLoading == false {
            //  Показываем shimmer во время загрузки
            showFooterShimmer()
            footerActivityIndicator.startAnimating()
            payButton.isEnabled = false
            payButton.alpha = 0.5
        } else if let footerInfo = state.footerInfo {
            //  Показываем реальные данные
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
    
    //  Показываем диалог подтверждения удаления
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
                print(" Подтверждено удаление NFT: \(confirmedNFTID)")
                //  Делегируем выполнение удаления ViewModel
                self?.viewModel.confirmRemoveItem(nftID: confirmedNFTID)
            },
            onCancel: { cancelledNFTID in
                print(" Отменено удаление NFT: \(cancelledNFTID)")
            }
        )
    }
    
    // MARK: - UI Setup
    
    private func setupProgressHUD() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .black
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        setupNavigationBar()
        setupEmptyCartLabel()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = ""
        
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(named: "MenuButton"), for: .normal)
        menuButton.tintColor = .black
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        //  Создаем контейнер с отступами
        let containerView = UIView()
        containerView.addSubview(menuButton)
        
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            menuButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            menuButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            menuButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            containerView.widthAnchor.constraint(equalToConstant: 42),
            containerView.heightAnchor.constraint(equalToConstant: 42)
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
            payButton.heightAnchor.constraint(equalToConstant: 44),
            
            footerActivityIndicator.centerXAnchor.constraint(equalTo: nftCountLabel.centerXAnchor),
            footerActivityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func menuButtonTapped() {
        showSortingActionSheet()
    }
    
    private func showSortingActionSheet() {
        let alertController = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        //  Опции сортировки
        let sortByPriceAction = UIAlertAction(title: "По цене", style: .default) { _ in
            print("Сортировка по цене")
            
            FilterStorage.shared.chosenFilter = "price"
            self.viewModel.sortBy(.price)
        }
        
        let sortByRatingAction = UIAlertAction(title: "По рейтингу", style: .default) { _ in
            print("Сортировка по рейтингу")
            FilterStorage.shared.chosenFilter = "rating"
            self.viewModel.sortBy(.rating)
        }
        
        let sortByNameAction = UIAlertAction(title: "По названию", style: .default) { _ in
            print("Сортировка по названию")
            FilterStorage.shared.chosenFilter = "name"
            self.viewModel.sortBy(.name)
        }
        
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel) { _ in
            print("Отменена сортировка")
        }
        
        //  Добавляем действия в алерт
        alertController.addAction(sortByPriceAction)
        alertController.addAction(sortByRatingAction)
        alertController.addAction(sortByNameAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    @objc private func payButtonTapped() {
        print("payButtonTapped")
        let payOrderViewModel = PayOrderViewModel(servicesAssembly: servicesAssembly, nfts: currentState.cellStates)
        let payOrderVC = PayOrderViewController(viewModel: payOrderViewModel)
        payOrderViewModel.view = payOrderVC
        
        
        let navVC = UINavigationController(rootViewController: payOrderVC)
        
        navVC.modalPresentationStyle = .fullScreen
        
        
        self.present(navVC, animated: true)
    }
    
    func updateCartToEmptyState(_ emptyState: CartViewState) {
        print("🧹 Прямое обновление CartViewController до пустого состояния")
        
        //  Обновляем внутреннее состояние
        currentState = emptyState
        
        //  Обновляем UI
        DispatchQueue.main.async { [weak self] in
           
            // Перезагружаем таблицу (теперь она будет пустая)
            self?.tableView.reloadData()
            
            // Обновляем empty state и footer
            self?.updateEmptyState(emptyState)
            self?.updateFooter(emptyState)
            
            print(" Корзина успешно очищена и показан empty state")
        }
    }
    
    // MARK: - Shimmer Animation
    
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
        //  Используем currentState как единственный источник данных
        return currentState.cellStates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        //  Безопасно получаем состояние ячейки
        let cellState = currentState.cellStates[indexPath.row]
        cell.configure(with: cellState)
        
        //  Передаем действие удаления во ViewModel
        cell.onRemove = { [weak self] nftID in
            guard let nftID = nftID else {
                print(" Не удалось получить nftID для удаления")
                return
            }
            
            print("🗑️ Запрос удаления NFT: \(nftID)")
            //  View делегирует решение ViewModel
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
