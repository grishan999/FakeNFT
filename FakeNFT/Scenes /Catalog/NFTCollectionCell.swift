//
//  NFTCollectionCell.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 11.06.2025.
//

import UIKit
import Kingfisher

final class NFTCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "NFTCollectionCell"
    private let networkClient: NetworkClient = DefaultNetworkClient()
    private var nft: Nft?
    private var stateService: NFTStateServiceProtocol = NFTStateService()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "dislike"), for: .normal)
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private let starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .costMedium
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cartButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "addToCart"), for: .normal)
        button.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private let textContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isInCart = false {
        didSet {
            updateCartButtonState()
        }
    }
    
    private var isLiked = false {
        didSet {
            updateLikeButtonState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadInitialStates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func loadInitialStates() {
        loadLikesFromServer()
        loadCartStateFromServer()
    }
    
    private func loadLikesFromServer() {
        stateService.getLikedNFTs { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let likes):
                    guard let nftId = self?.nft?.id else { return }
                    self?.isLiked = likes.contains(nftId)
                    self?.updateLikeButtonState()
                case .failure:
                    break
                }
            }
        }
    }
    
    private func loadCartStateFromServer() {
        stateService.getCartNFTs { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cartItems):
                    guard let nftId = self?.nft?.id else { return }
                    self?.isInCart = cartItems.contains(nftId)
                    self?.updateCartButtonState()
                case .failure:
                    break
                }
            }
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        textContainer.addSubview(starsStackView)
        textContainer.addSubview(titleLabel)
        textContainer.addSubview(priceLabel)
        
        contentView.addSubview(imageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(textContainer)
        contentView.addSubview(cartButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 108),
            imageView.heightAnchor.constraint(equalToConstant: 108),
            
            likeButton.topAnchor.constraint(equalTo: imageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),
            
            cartButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40),
            
            textContainer.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textContainer.trailingAnchor.constraint(equalTo: cartButton.leadingAnchor, constant: -8),
            textContainer.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            
            starsStackView.topAnchor.constraint(equalTo: textContainer.topAnchor),
            starsStackView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            starsStackView.widthAnchor.constraint(equalToConstant: 68),
            starsStackView.heightAnchor.constraint(equalToConstant: 12),
            
            titleLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: textContainer.bottomAnchor)
        ])
    }
    
    func configure(with nft: Nft, isLiked: Bool, isInCart: Bool) {
        self.nft = nft
        titleLabel.text = nft.name
        priceLabel.text = "\(nft.price) ETH"
        self.isLiked = isLiked
        self.isInCart = isInCart
        
        if let url = nft.images.first {
            imageView.kf.setImage(with: url)
        }
        
        setupStars(rating: nft.rating)
    }
    
    private func setupStars(rating: Int) {
        starsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 0..<5 {
            let star = UIImageView()
            let imageName = i < rating ? "star" : "star_empty"
            star.image = UIImage(named: imageName)
            star.contentMode = .scaleAspectFit
            star.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            NSLayoutConstraint.activate([
                star.widthAnchor.constraint(equalToConstant: 12),
                star.heightAnchor.constraint(equalToConstant: 12)
            ])
            
            starsStackView.addArrangedSubview(star)
        }
    }
    
    @objc private func cartButtonTapped() {
        guard let nftId = nft?.id else { return }
        let newValue = !isInCart
        
        stateService.updateCartState(nftId: nftId, isInCart: newValue) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isInCart = newValue
                    self?.updateCartButtonState()
                case .failure:
                    break
                }
            }
        }
    }
    
    @objc private func likeButtonTapped() {
        guard let nftId = nft?.id else { return }
        let newValue = !isLiked
        
        stateService.updateLikeState(nftId: nftId, isLiked: newValue) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isLiked = newValue
                    self?.updateLikeButtonState()
                case .failure:
                    break
                }
            }
        }
    }
    
    private func updateCartButtonState() {
        let imageName = isInCart ? "deleteAtCart" : "addToCart"
        cartButton.setImage(UIImage(named: imageName), for: .normal)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.cartButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.cartButton.transform = .identity
            }
        })
    }
    
    private func updateLikeButtonState() {
        let imageName = isLiked ? "like" : "dislike"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.likeButton.transform = .identity
            }
        })
    }
}
