import UIKit
import Kingfisher

final class CartTableViewCell: UITableViewCell {
    static let identifier = "CartTableViewCell"
    
    // MARK: - Callback
    var onRemove: (() -> Void)?
    
    // MARK: - UI Elements
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6 // ✅ Фон для placeholder
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Цена"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var priceValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Delete_NFT_Icon"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(nftImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(starsStackView)
        containerView.addSubview(priceLabel)
        containerView.addSubview(priceValueLabel)
        containerView.addSubview(removeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // NFT Image
            nftImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nftImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
            nameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // Stars stack view
            starsStackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            starsStackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 12),
            
            // Price label
            priceLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 20),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            // Price value label
            priceValueLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            priceValueLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceValueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Remove button
            removeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            removeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 40),
            removeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Configuration
    func configure(with nft: nftCartModel) {
        // ✅ Загружаем изображение с Kingfisher
        if let imageURL = nft.imageURL {
            nftImageView.kf.setImage(
                with: imageURL,
                placeholder: createPlaceholderImage(), // ✅ Заглушка
                options: [
                    .transition(.fade(0.3)), // ✅ Плавное появление
                    .cacheOriginalImage,     // ✅ Кешируем оригинал
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 108, height: 108))) // ✅ Оптимизация
                ]
            )
        } else {
            // ✅ Если нет URL - показываем заглушку
            nftImageView.image = createPlaceholderImage()
        }
        
        nameLabel.text = nft.name
        priceValueLabel.text = String(format: "%.2f ETH", nft.price)
        
        setupStars(rating: nft.rating)
    }
    
    // ✅ Создание заглушки
    private func createPlaceholderImage() -> UIImage? {
        let size = CGSize(width: 108, height: 108)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Фон заглушки
            UIColor.systemGray6.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Иконка в центре
            let iconSize: CGFloat = 40
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            
            if let icon = UIImage(systemName: "photo")?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal) {
                icon.draw(in: iconRect)
            }
        }
    }
    
    private func setupStars(rating: Int) {
        // Очищаем предыдущие звезды
        starsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем 5 звезд
        for i in 1...5 {
            let starImageView = UIImageView()
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
            starImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
            
            if i <= rating {
                starImageView.image = UIImage(systemName: "star.fill")
                starImageView.tintColor = .systemYellow
            } else {
                starImageView.image = UIImage(systemName: "star")
                starImageView.tintColor = .systemGray3
            }
            
            starsStackView.addArrangedSubview(starImageView)
        }
    }
    
    // MARK: - Actions
    @objc private func removeButtonTapped() {
        onRemove?()
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        // ✅ Отменяем загрузку изображения при reuse
        nftImageView.kf.cancelDownloadTask()
        nftImageView.image = nil
        nameLabel.text = nil
        priceValueLabel.text = nil
        starsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onRemove = nil
    }
}
