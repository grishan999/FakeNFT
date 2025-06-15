import UIKit

final class ProfileTableViewCell: UITableViewCell {
    // MARK: - Public Properties
    static let identifier = "ProfileCell"
    
    // MARK: - Private Properties
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .textOnPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .bodyBold
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var transitionImageView: UIImageView = {
        let imageView = UIImageView()
        if let arrowImage = UIImage(
            named: "back_button"
        ) {
            imageView.image = arrowImage.withRenderingMode(
                .alwaysTemplate
            )
            imageView.tintColor = .gray
        }
        imageView.transform = CGAffineTransform(
            rotationAngle: .pi
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initializers
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        
        selectionStyle = .none
        backgroundColor = .background
        separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        layer.maskedCorners = []
        
        configureView()
    }
    
    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(
        with category: String,
        count: String?
    ) {
        categoryLabel.text = category
        if let count = count {
            countLabel.text = "(\(count))"
        } else {
            countLabel.text = ""
        }
    }
}

// MARK: - ViewConfigurable
extension ProfileTableViewCell: ViewConfigurable {
    
    func addSubviews() {
        let subViews = [
            categoryLabel,
            countLabel,
            transitionImageView
        ]
        subViews.forEach {
            contentView.addSubview($0)
        }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            countLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            transitionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transitionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            transitionImageView.widthAnchor.constraint(equalToConstant: 14),
            transitionImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    func configureView() {
        addSubviews()
        addConstraints()
    }
}

