import UIKit
import SwiftUI

// MARK: - Preview
struct FavoriteNFTViewControllerPreview: PreviewProvider {
    static var previews: some View {
        FavoriteNFTViewController().showPreview()
    }
}

class FavoriteNFTViewController: UIViewController {
    // MARK: - ViewModel
    var viewModel: ProfileViewModel?
    
    // MARK: - UI Elements
    private lazy var backButton: UIButton = {
        let button = UIButton()
        if let imageButton = UIImage(named: "back_button")?.withRenderingMode(.alwaysTemplate) {
            // Переворачиваем изображение на 180 градусов
            let flippedImage = imageButton.withHorizontallyFlippedOrientation()
            button.setImage(flippedImage, for: .normal)
            button.tintColor = .buttonColor
            button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        }
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            FavoriteNFTCollectionViewCell.self,
            forCellWithReuseIdentifier: FavoriteNFTCollectionViewCell.identifier
        )
        collectionView.backgroundColor = .backgroudColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupView()
        update()
    }
    
    //MARK: - Private Methods
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.title = localizedString(key: "favoriteNFT")
        let customFont = UIFont.bodyBold
        let attributes: [NSAttributedString.Key: Any] = [
            .font: customFont,
            .foregroundColor: UIColor.buttonColor
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    @objc
    private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func update() {
        if viewModel != nil {
            collectionView.reloadData()
            checkIfCollectionIsEmpty()
        } else {
            print("viewModel is nil")
        }
    }
    
    private func showPlaceHolder() {
        let backgroundView = PlaceHolderView(frame: view.frame)
        backgroundView.setupNoFavoriteNFTState()
        view.addSubview(backgroundView)
    }
    
    private func checkIfCollectionIsEmpty() {
        if viewModel?.favoriteNFTNames.isEmpty == true {
            showPlaceHolder()
        }
    }
}

// MARK: - ViewConfigurable
extension FavoriteNFTViewController: ViewConfigurable {
    func addSubviews() {
        let subViews = [collectionView]
        subViews.forEach { view.addSubview($0) }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupView() {
        view.backgroundColor = .backgroudColor
        setupNavBar()
        configureView()
    }
}

// MARK: - DataSource
extension FavoriteNFTViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.favoriteNFTNames.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteNFTCollectionViewCell.identifier, for: indexPath) as? FavoriteNFTCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let nftData = viewModel?.configureNFT(for: indexPath.item, from: .favoriteNFT) {
            
            cell.nftImageView.image = nftData.image
            cell.nameLabel.text = nftData.name
        }
        return cell
    }
}

// MARK: - Delegate
extension FavoriteNFTViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 168, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }
}


