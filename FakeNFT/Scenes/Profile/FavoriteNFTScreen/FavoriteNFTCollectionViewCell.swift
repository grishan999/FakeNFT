import UIKit

final class FavoriteNFTCollectionViewCell: UICollectionViewCell {
    // MARK: - Public Properties
    static let identifier = "FaforiteNFTCollectionViewCell"
    
    // MARK: - UI Elements
    lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .fontColor
        label.font = .bodyBold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var starsImageView: UIImageView = {
        let imageView = UIImageView()
        if let arrowImage = UIImage(named: "rating_4") {
            imageView.image = arrowImage
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var countMoneyLabel: UILabel = {
        let label = UILabel()
        label.text = "1,78 ETH"
        label.textColor = .fontColor
        label.font = .caption1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewConfigurable
extension FavoriteNFTCollectionViewCell: ViewConfigurable {
    func addSubviews() {
        let subViews = [
            nftImageView,
            nameLabel,
            starsImageView,
            countMoneyLabel
        ]
        subViews.forEach { contentView.addSubview($0) }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 80),
            nftImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 7),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 12),
            nameLabel.widthAnchor.constraint(equalToConstant: 76),
            
            starsImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            starsImageView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            starsImageView.widthAnchor.constraint(equalToConstant: 68),
            starsImageView.heightAnchor.constraint(equalToConstant: 12),
            
            countMoneyLabel.topAnchor.constraint(equalTo: starsImageView.bottomAnchor, constant: 8),
            countMoneyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            countMoneyLabel.widthAnchor.constraint(equalToConstant: 61),
            countMoneyLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configureView() {
        addSubviews()
        addConstraints()
    }
}


