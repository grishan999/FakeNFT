import UIKit

final class PlaceHolderView: UIView {
    
    // MARK: - Private Properties
    private lazy var lable: UILabel = {
        let lable = UILabel()
        lable.textAlignment = .center
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setupNoNFTState() {
        lable.text = localizedString(key: "don'tHaveNFT")
        lable.font = .bodyBold
        lable.textColor = .buttonColor
        lable.textAlignment = .center
    }
    
    func setupNoFavoriteNFTState() {
        lable.text = localizedString(key: "don'tHaveFavoriteNFT")
        lable.font = .bodyBold
        lable.textColor = .buttonColor
        lable.textAlignment = .center
    }
    
    // MARK: - Private Methods
   
}

// MARK: - ViewConfigurable
extension PlaceHolderView: ViewConfigurable {
    func addSubviews() {
        addSubview(lable)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            lable.centerYAnchor.constraint(equalTo: centerYAnchor),
            lable.centerXAnchor.constraint(equalTo: centerXAnchor),
            lable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            lable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func configureView() {
        addSubviews()
        addConstraints()
    }
}


