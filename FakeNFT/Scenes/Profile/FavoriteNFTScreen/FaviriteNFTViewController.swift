import UIKit

final class FavoriteNFTViewController: UIViewController {
    // MARK: - ViewModel
    private var likedNFTs: [Nft] = []
    
    private let viewModel: FavoriteNFTViewModel
    private var newProfileViewModel: ProfileViewModel
    
    init(
        viewModel: FavoriteNFTViewModel,
        newProfileViewModel: ProfileViewModel
    ) {
        self.viewModel = viewModel
        self.newProfileViewModel = newProfileViewModel
        super.init(
            nibName: nil,
            bundle: nil
        )
    }
    
    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private lazy var backButton: UIButton = {
        let button = UIButton()
        if let imageButton = UIImage(named: "back_button")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(
                imageButton,
                for: .normal
            )
            button.tintColor = .buttonColor
            button.addTarget(
                self,
                action: #selector(didTapBackButton),
                for: .touchUpInside
            )
        }
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
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
        viewModel.configure(with: newProfileViewModel)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupView()
        setupBindings()
        loadNFTs()
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
    
    private func showPlaceHolder() {
        let backgroundView = PlaceHolderView(
            frame: view.frame
        )
        backgroundView.setupNoFavoriteNFTState()
        view.addSubview(backgroundView)
    }
    
    private func checkIfCollectionIsEmpty() {
        if viewModel.favoriteNFT?.isEmpty == true {
            showPlaceHolder()
        }
    }
    
    private func loadNFTs() {
        viewModel.loadLikedNFTs(
            likes: viewModel.favoriteNFT ?? []
        )
    }
    
    private func setupBindings() {
        checkIfCollectionIsEmpty()
        updateAfterDownloadData()
        updateCellLoadingNFT()
    }
    
    private func updateAfterDownloadData() {
        viewModel.nftsUpdated = { [weak self] in
            self?.likedNFTs = self?.viewModel.likedNFTs ?? []
            self?.collectionView.reloadData()
        }
    }
    
    private func updateCellLoadingNFT() {
        viewModel.nftsImageUpdate = { [weak self] nftId, image in
            guard let self = self else { return }
            
            if let index = self.likedNFTs.firstIndex(where: { $0.id == nftId }) {
                let indexPath = IndexPath(item: index, section: 0)
                
                if let cell = self.collectionView.cellForItem(at: indexPath) as? FavoriteNFTCollectionViewCell {
                    cell.nftImageView.image = image ?? UIImage(named: "placeholder")
                }
            }
        }
    }
}

// MARK: - ViewConfigurable
extension FavoriteNFTViewController: ViewConfigurable {
    func addSubviews() {
        view.addSubview(collectionView)
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
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return likedNFTs.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FavoriteNFTCollectionViewCell.identifier,
            for: indexPath
        ) as? FavoriteNFTCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let nft = viewModel.likedNFTs[indexPath.item]
        let image = viewModel.nftImages[nft.id] ?? UIImage(named: "placeholder")
        let ratingImage = viewModel.ratingImage(for: nft)
        cell.configure(with: nft, image: image, ratingImage: ratingImage)
        
        return cell
    }
}

// MARK: - Delegate
extension FavoriteNFTViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 168, height: 80)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 7
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 20
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(
            width: collectionView.bounds.width,
            height: 20
        )
    }
}


