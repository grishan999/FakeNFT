//
//  NFTCollectionViewController.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 11.06.2025.
//

import UIKit
import Kingfisher
import ProgressHUD

final class NFTCollectionViewController: UIViewController {
    
    private let stateService: NFTStateServiceProtocol = NFTStateService()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = .label
        label.text = "Автор коллекции:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var authorButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .caption1
        button.setTitleColor(.systemBlue, for: .normal)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(authorButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(NFTCollectionCell.self, forCellWithReuseIdentifier: NFTCollectionCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var viewModel: NFTCollectionViewModelProtocol
    private var maxCellHeight: CGFloat = 0
    
    init(viewModel: NFTCollectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupBindings()
        
        loadInitialStates()
        viewModel.loadNFTs()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
    }
    
    private func loadInitialStates() {
            stateService.getLikedNFTs { _ in }
            stateService.getCartNFTs { _ in }
        }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "nav_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        navigationItem.leftBarButtonItem = backButtonItem
    
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setContentHidden(true)

        view.addSubview(coverImageView)
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 310)
        ])
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.addSubview(titleLabel)
        
        let authorStack = UIStackView(arrangedSubviews: [authorTitleLabel, authorButton])
        authorStack.axis = .horizontal
        authorStack.spacing = 4
        authorStack.alignment = .firstBaseline
        authorStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(authorStack)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            authorStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: authorStack.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.onNFTsUpdate = { [weak self] in
            guard let self = self else { return }
            self.updateCollectionData()
        }
        
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.setContentHidden(true)
                ProgressHUD.show()
            } else {
                ProgressHUD.dismiss()
            }
        }
    }
    
    private func setContentHidden(_ isHidden: Bool) {
        coverImageView.isHidden = isHidden
        titleLabel.isHidden = isHidden
        authorTitleLabel.isHidden = isHidden
        authorButton.isHidden = isHidden
        descriptionLabel.isHidden = isHidden
        collectionView.isHidden = isHidden
    }
    
    private func updateCollectionData() {
        guard let collection = viewModel.collection else {
            setContentHidden(true)
            return
        }
        
        coverImageView.kf.setImage(with: collection.cover)
        titleLabel.text = collection.name
        authorButton.setTitle(collection.author, for: .normal)
        descriptionLabel.text = collection.description
        
        collectionView.reloadData()
        updateCollectionViewHeight()
        
        let hasNFTs = !viewModel.nfts.isEmpty
        setContentHidden(!hasNFTs)
    }
    
    private func updateCollectionViewHeight() {
        maxCellHeight = 0
        for i in 0..<viewModel.nfts.count {
            let indexPath = IndexPath(item: i, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? NFTCollectionCell {
                let cellHeight = cell.systemLayoutSizeFitting(
                    CGSize(width: cell.bounds.width, height: UIView.layoutFittingCompressedSize.height),
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                ).height
                maxCellHeight = max(maxCellHeight, cellHeight)
            }
        }
        
        if maxCellHeight == 0 {
            maxCellHeight = 192
        }
        
        let itemCount = viewModel.nfts.count
        let rows = ceil(CGFloat(itemCount) / 3.0)
        let totalHeight = rows * maxCellHeight + (rows - 1) * 8 + 16
        
        collectionView.constraints.filter { $0.firstAttribute == .height }.forEach { $0.isActive = false }
        collectionView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        view.layoutIfNeeded()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func authorButtonTapped() {
        guard let url = URL(string: "https://practicum.yandex.ru/ios-developer/?from=catalog") else {
            assertionFailure("Invalid URL")
            return
        }
        let webViewController = AuthorWebView(url: url)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}

extension NFTCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTCollectionCell.reuseIdentifier, for: indexPath) as! NFTCollectionCell
            let nft = viewModel.nfts[indexPath.item]
            let isLiked = stateService.isLiked(nftId: nft.id)
            let isInCart = stateService.isInCart(nftId: nft.id)
            cell.configure(with: nft, isLiked: isLiked, isInCart: isInCart)
            return cell
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 32) / 3
        return CGSize(width: width, height: maxCellHeight > 0 ? maxCellHeight : 192)
    }
}
