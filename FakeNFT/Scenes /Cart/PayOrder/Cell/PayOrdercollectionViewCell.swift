import UIKit
import Kingfisher

final class PayOrdercollectionViewCell: UICollectionViewCell {
    
    static let id = "PayOrdercollectionViewCell"
    
    func setSelected(_ selected: Bool) {
        containerView.layer.borderWidth = selected  ? 1.0  : 0.0
        containerView.layer.borderColor = selected ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
    
    func configure(with currency: Currency){
        
        if let imageURL = URL(string: currency.image) {
            currencyImage.kf.setImage(
                with: imageURL,
                placeholder: nil,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage,
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 108, height: 108)))
                ]
            )
        } else {
            //  ДОБАВЛЕНО: Обработка случая, когда URL невалиден
            currencyImage.image = UIImage(systemName: "photo") // placeholder изображение
        }
        
        fullName.text = currency.title
        shortName.text = currency.name
    }
    
    // MARK: - UI Elements
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP LightGrey")
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private lazy var pictureContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var currencyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // ✅ ИЗМЕНЕНО: scaleAspectFit вместо scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6 // ✅ ИЗМЕНЕНО: меньший radius для картинки 31.5x31.5
        imageView.backgroundColor = .clear
        imageView.tintColor = .white // ✅ ДОБАВЛЕНО: белый цвет для SF Symbols
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var fullName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var shortName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "Green Universal")
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(currencyImage)
        containerView.addSubview(pictureContainerView)
        pictureContainerView.addSubview(currencyImage)
        containerView.addSubview(labelsStackView)
        labelsStackView.addArrangedSubview(fullName)
        labelsStackView.addArrangedSubview(shortName)
        
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            // NFT Image
            pictureContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            pictureContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            pictureContainerView.widthAnchor.constraint(equalToConstant: 36),
            pictureContainerView.heightAnchor.constraint(equalToConstant: 36),
            
            // currency Image
            currencyImage.centerXAnchor.constraint(equalTo: pictureContainerView.centerXAnchor),
            currencyImage.centerYAnchor.constraint(equalTo: pictureContainerView.centerYAnchor),
            currencyImage.widthAnchor.constraint(equalToConstant: 31.5),
            currencyImage.heightAnchor.constraint(equalToConstant: 31.5),
            
            
            //  stack view
            labelsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            labelsStackView.leadingAnchor.constraint(equalTo: pictureContainerView.trailingAnchor, constant: 4),
            
            fullName.topAnchor.constraint(equalTo: labelsStackView.topAnchor),
            fullName.leadingAnchor.constraint(equalTo: labelsStackView.leadingAnchor),
            
            shortName.topAnchor.constraint(equalTo: fullName.bottomAnchor, constant: 2),
            shortName.leadingAnchor.constraint(equalTo: labelsStackView.leadingAnchor),
 
        ])
    }   
}
