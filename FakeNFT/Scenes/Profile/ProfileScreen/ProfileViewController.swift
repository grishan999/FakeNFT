import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel: ProfileViewModel
    private var profileChangeViewModel: ProfileChangeViewModel
    private let myNFTViewModel: MyNFTViewModel
    private let favoriteNFTViewModel: FavoriteNFTViewModel
    
    init(viewModel: ProfileViewModel,
         profileChangeViewModel: ProfileChangeViewModel,
         networkClient: NetworkClient,
         storage: NftStorage) {
        let nftService = NftServiceImpl(
            networkClient: networkClient,
            storage: storage
        )
        let profileService = ProfileService(
            networkClient: networkClient
        )
        
        self.profileChangeViewModel = ProfileChangeViewModel(
            profileService: profileService
        )
        
        self.myNFTViewModel = MyNFTViewModel(
            nftService: nftService
        )
        
        self.favoriteNFTViewModel = FavoriteNFTViewModel(
            nftService: nftService
        )
        
        self.viewModel = viewModel
        self.profileChangeViewModel = profileChangeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private lazy var changeProfileButton: UIButton = {
        let button = UIButton()
        if let imageButton = UIImage(named: "edit_button")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(imageButton, for: .normal)
            button.tintColor = .buttonColor
            button.addTarget(self, action: #selector(didTapChangeButton), for: .touchUpInside)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.userName
        label.textColor = .fontColor
        label.font = .headline3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.userDescription
        label.textColor = .fontColor
        label.font = .caption2
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var profileLink: UIButton = {
        let button = UIButton()
        button.setTitle(viewModel.userWebsite, for: .normal)
        button.titleLabel?.font = .caption1
        button.setTitleColor(.blueUniversal, for: .normal)
        button.addTarget(
            self,
            action: #selector(profileLinkTapped),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroudColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            ProfileTableViewCell.self,
            forCellReuseIdentifier: ProfileTableViewCell.identifier
        )
        return tableView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.loadProfile()
    }
    
    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)
        setupBindings()
        viewModel.loadProfile()
    }
    
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: changeProfileButton
        )
    }
    
    @objc
    private func didTapChangeButton() {
        let profileChangeViewController = ProfileChangeViewController(
            viewModel: profileChangeViewModel,
            newProfileViewModel: viewModel
        )
        setupBindings()
        viewModel.loadProfile()
        present(
            profileChangeViewController,
            animated: true,
            completion: nil
        )
    }
    
    @objc private func profileLinkTapped() {
        if !viewModel.userWebsite.isEmpty,
           let url = URL(
            string: viewModel.userWebsite
           ) {
            UIApplication.shared.open(
                url,
                options: [:],
                completionHandler: nil
            )
        } else {
            print("Некорректный URL")
        }
    }
    
    // MARK: - Setup Methods
    private func setupBindings() {
        updateScreenInformation()
        updateImage()
    }
    
    private func updateScreenInformation() {
        viewModel.profileUpdated = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.nameLabel.text = self.viewModel.userName
                self.informationLabel.text = self.viewModel.userDescription
                self.profileLink.setTitle(self.viewModel.userWebsite, for: .normal)
                self.tableView.reloadData()
            }
        }
    }
    
    private func updateImage() {
        viewModel.profileImageUpdated = { [weak self] (image: UIImage?) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.profileImage.image = image
            }
        }
    }
    
    private func handleAction(_ action: ProfileAction) {
        switch action {
        case .navigateToMyNFTs:
            let myNFTVC = MyNFTViewController(
                viewModel: myNFTViewModel,
                newProfileViewModel: viewModel
            )
            myNFTVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(myNFTVC, animated: true)
            
        case .navigateToFavorites:
            let favoritesVC = FavoriteNFTViewController(
                viewModel: favoriteNFTViewModel,
                newProfileViewModel: viewModel
            )
            favoritesVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(favoritesVC, animated: true)
            
        case .openUserWebsite(let url):
            let webViewController = AboutDeveloperViewController()
            webViewController.urlString = url
            webViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webViewController, animated: true)
        default:
            break
        }
    }
}

// MARK: - ViewConfigurable
extension ProfileViewController: ViewConfigurable {
    func addConstraints() {
        NSLayoutConstraint.activate([
            changeProfileButton.widthAnchor.constraint(equalToConstant: 42),
            changeProfileButton.heightAnchor.constraint(equalToConstant: 42),
            
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 108),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor, constant: 21),
            
            informationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            informationLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20),
            informationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            profileLink.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileLink.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 190),
            
            tableView.topAnchor.constraint(equalTo: profileLink.bottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func addSubviews() {
        let subViews = [
            profileImage,
            nameLabel,
            informationLabel,
            profileLink,
            tableView
        ]
        subViews.forEach { view.addSubview($0) }
    }
    
    private func setupView() {
        view.backgroundColor = .backgroudColor
        configureView()
        setupNavigationBar()
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.items.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.identifier,
            for: indexPath
        )
                as? ProfileTableViewCell else
        {
            return UITableViewCell()
        }
        
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item.categoryName,
                       count: item.count != nil ? "\(item.count!)" : nil)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 54
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let action = viewModel.didSelectItem(at: indexPath.row)
        handleAction(action)
    }
}

