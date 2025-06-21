import UIKit

final class MyNFTTableViewCell: UITableViewCell {
    // MARK: - Public Properties
    static let identifier = "MyNFTCell"
    
    // MARK: - UI Elements
    lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        if let imageButton = UIImage(named: "heart") {
            button.setImage(imageButton, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        if let arrowImage = UIImage(named: "rating_2") {
            imageView.image = arrowImage
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var fromLabel: UILabel = {
        let label = UILabel()
        label.text = "от John Doe"
        label.textColor = .fontColor
        label.font = .caption2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var payLabel: UILabel = {
        let label = UILabel()
        label.text = "цена"
        label.textColor = .fontColor
        label.font = .caption2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countMoneyLabel: UILabel = {
        let label = UILabel()
        label.text = "1,78 ETH"
        label.textColor = .fontColor
        label.font = .bodyBold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .backgroudColor
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layer.maskedCorners = []
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewConfigurable
extension MyNFTTableViewCell: ViewConfigurable {
    func addSubviews() {
        let subViews = [
            nftImageView,
            likeButton,
            nameLabel,
            starsImageView,
            fromLabel,
            payLabel,
            countMoneyLabel
        ]
        subViews.forEach { contentView.addSubview($0) }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            likeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            likeButton.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor, constant: 68),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 23),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            
            starsImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            starsImageView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            starsImageView.widthAnchor.constraint(equalToConstant: 68),
            starsImageView.heightAnchor.constraint(equalToConstant: 12),
            
            fromLabel.topAnchor.constraint(equalTo: starsImageView.bottomAnchor, constant: 4),
            fromLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            payLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 33),
            payLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -81),
            
            countMoneyLabel.topAnchor.constraint(equalTo: payLabel.bottomAnchor, constant: 2),
            countMoneyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -39)
        ])
    }
    
    func configureView() {
        addSubviews()
        addConstraints()
    }
}

