

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
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
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.userDescription
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var profileLink: UIButton = {
        let button = UIButton()
        button.setTitle(viewModel.userWebsite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
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
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "Cell"
        )
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.loadProfile()
    }
    
    // MARK: - Private Methods
    @objc private func profileLinkTapped() {
        if !viewModel.userWebsite.isEmpty,
           let url = URL(string: viewModel.userWebsite) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Некорректный URL")
        }
    }
    
    private func setupBindings() {
        updateScreenInformation()
        updateImage()
    }
    
    private func updateScreenInformation() {
        activityIndicator.startAnimating()
        viewModel.profileUpdated = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
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
        case .openUserWebsite(let url):
            let webViewController = UIViewController()
            webViewController.view.backgroundColor = .white
            webViewController.title = "Website"
            navigationController?.pushViewController(webViewController, animated: true)
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // Примерное количество ячеек
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Мои NFT"
        case 1:
            cell.textLabel?.text = "Избранные NFT"
        case 2:
            cell.textLabel?.text = "О разработчике"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            viewModel.didSelectItem(at: 0)
        case 1:
            viewModel.didSelectItem(at: 1)
        case 2:
            viewModel.didSelectItem(at: 2)
        default:
            break
        }
    }
}

// MARK: - View Configuration
extension ProfileViewController {
    private func setupView() {
        view.backgroundColor = .white
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        [profileImage, nameLabel, informationLabel, profileLink, tableView, activityIndicator].forEach {
            view.addSubview($0)
        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            
            informationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            informationLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20),
            informationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            profileLink.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileLink.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: profileLink.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
