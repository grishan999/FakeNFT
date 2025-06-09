import Foundation
import UIKit
import ProgressHUD

final class CartViewController: UIViewController {
    
    let servicesAssembly: ServicesAssembly
    private var NftIDs = [String]() {
        didSet {
            NftIDs.forEach { id in
                loadNftCartModel(id: id)
            }
            
        }
    }
    private var NftArray = [nftCartModel]() {
        didSet {
            NftArray.forEach { nft in
                print("!!!!!!!!!!!!!\(nft.name) \(nft.nftPictureURL) \(nft.price)")
                tableView.reloadData()
                if  NftArray.count == NftIDs.count {
                    updateFooterInfo()
                }
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
        return button
    }()
    
    // MARK: - Data
    private var cartItems: [nftCartModel] = []
    
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
        ProgressHUD.show("Загрузка данных...")
        setupUI()
        loadData()
        loadOrder()
    }
    
    // MARK: - Progress HUD Setup
    private func setupProgressHUD() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .black
    }
    
    private func loadOrder() {
        
        servicesAssembly.nftService.loadOrder(id: "1") { [weak self] result in
            switch result {
            case .success(let nft):
                self?.NftIDs = nft.nfts
                ProgressHUD.dismiss()
            case .failure(let error):
                ProgressHUD.dismiss()
                print(error)
            }
        }
    }
    
    private func loadNftCartModel(id: String) {
        
        servicesAssembly.nftService.loadNftCartModel(id: id) { [weak self] result in
            switch result {
            case .success(let nft):
                self?.NftArray.append(nft)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        addSubviews()
        setupConstraints()
        updateFooterInfo()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = ""
        
        // Кнопка меню (гамбургер) справа
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .black
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    private func addSubviews() {
        // ✅ Сначала добавляем ВСЕ subviews в правильном порядке
        view.addSubview(footerView)
        view.addSubview(tableView)
        
        footerView.addSubview(nftCountLabel)
        footerView.addSubview(totalPriceLabel)
        footerView.addSubview(payButton)
    }
    
    private func setupConstraints() {
        // ✅ Теперь все элементы уже в view hierarchy
        NSLayoutConstraint.activate([
            // Footer view (сначала footer!)
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 76),
            
            // TableView (теперь можем ссылаться на footerView)
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            // Footer elements
            nftCountLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16),
            nftCountLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            nftCountLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 79),
            
            totalPriceLabel.topAnchor.constraint(equalTo: nftCountLabel.bottomAnchor, constant: 4),
            totalPriceLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            totalPriceLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 90),
            
            payButton.leadingAnchor.constraint(equalTo: totalPriceLabel.trailingAnchor, constant: 24),
            payButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            payButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            payButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16),

        ])
    }
    
    private func loadData() {
        cartItems = NFTmockModel.shared.getMockData
        tableView.reloadData()
        updateFooterInfo()
    }
    
    private func updateFooterInfo() {
        let count = NftArray.count
        let totalPrice = NftArray.reduce(0) { $0 + $1.price }
        
        nftCountLabel.text = "\(count) NFT"
        totalPriceLabel.text = String(format: "%.2f ETH", totalPrice)
    }
    
    // MARK: - Actions
    @objc private func menuButtonTapped() {
        // Действие для кнопки меню
        print("Menu button tapped")
    }
    
    @objc private func payButtonTapped() {
        // Действие для кнопки оплаты
        print("Pay button tapped")
    }
    
    private func removeItem(at index: Int) {
        cartItems.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        updateFooterInfo()
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NftArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        let item = NftArray[indexPath.row]
        cell.configure(with: item)
        cell.onRemove = { [weak self] in
            self?.removeItem(at: indexPath.row)
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
