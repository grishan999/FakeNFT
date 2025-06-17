import UIKit
import SwiftUI

// MARK: - Preview
struct ProfileViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ProfileViewController().showPreview()
    }
}

final class ProfileViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = ProfileViewModel(
        profile: ProfileModel(
            profileImage: "user_pic",
            userName: "Joaquin Phoenix",
            userDescription: """
            Дизайнер из Казани, люблю цифровое искусство
            и бейглы. В моей коллекции уже 100+ NFT,
            и еще больше — на моём сайте. Открыт
            к коллаборациям.
            """,
            userWebsite: "Joaquin Phoenix.com"
        )
    )
    
    // MARK: - Private Priorities
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
        let imageView = UIImageView(image: UIImage(named: viewModel.profileImage))
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
        button.addTarget(self, action: #selector(profileLinkTapped), for: .touchUpInside)
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
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroudColor
        configureView()
        setupNavigationBar()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: changeProfileButton)
    }
    
    @objc
    private func didTapChangeButton() {
        print("Изменяем профиль")
    }
    
    @objc
    private func profileLinkTapped() {
        print("Переходим по ссылке")
    }
    private func setupBindings() {
        viewModel.profileUpdated = { [weak self] in
            self?.nameLabel.text = self?.viewModel.userName
            self?.informationLabel.text = self?.viewModel.userDescription
            self?.profileLink.setTitle(self?.viewModel.userWebsite, for: .normal)
        }
    }
    
    private func handleAction(_ action: ProfileAction) {
        switch action {
        case .navigateToMyNFTs:
            print("Переходим на экран Мои NFT")
            
        case .navigateToFavorites:
            print("Переходим на экран Избранные NFT")
            
        case .openUserWebsite:
            print("Переходим на экран О разработчике")
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
            profileLink.topAnchor.constraint(equalTo: informationLabel.bottomAnchor, constant: 8),
            
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
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.items[indexPath.row]
        if let count = item.count {
            cell.configure(with: item.categoryName, count: "\(count)")
        } else {
            cell.configure(with: item.categoryName, count: nil)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = viewModel.didSelectItem(at: indexPath.row)
        handleAction(action)
    }
}


