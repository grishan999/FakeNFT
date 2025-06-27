import UIKit
import Kingfisher

// КАСТОМНЫЙ VIEWCONTROLLER ДЛЯ ПОДТВЕРЖДЕНИЯ УДАЛЕНИЯ С ID
class DeleteConfirmationViewController: UIViewController {
    
    // MARK: - Properties
    private let nftID: String
    private let nftImageURL: URL?
    
    // Замыкания для обратной связи с CartViewController
    var onDeleteConfirmed: ((String) -> Void)?
    var onCancel: ((String) -> Void)?
    
    // MARK: - UI Elements
    private let backgroundBlurView = UIVisualEffectView()
    private let nftImageView = UIImageView()
    private let titleLabel = UILabel()
    private let buttonsContainerView = UIView()
    private let deleteButton = UIButton()
    private let cancelButton = UIButton()
    
    // MARK: - Initialization
    init(nftID: String, nftImageURL: URL? = nil) {
        self.nftID = nftID
        self.nftImageURL = nftImageURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        
        print("🗑️ Создан DeleteConfirmationViewController для NFT: \(nftID)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateAppearance()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // 🎭 Blur фон чтобы видеть CartViewController с эффектом размытия
        view.backgroundColor = .clear
        
        setupBlurBackground()
        
        //  NFT изображение по центру
        setupNFTImageView()
        
        //  Текст подтверждения
        setupTitleLabel()
        
        //  Контейнер для кнопок
        setupButtonsContainer()
        
        //  Кнопка "Удалить" (черная)
        setupDeleteButton()
        
        //  Кнопка "Вернуться" (черная)
        setupCancelButton()
        
        //  Добавляем элементы в иерархию
        view.addSubview(backgroundBlurView)
        view.addSubview(nftImageView)
        view.addSubview(titleLabel)
        view.addSubview(buttonsContainerView)
        buttonsContainerView.addSubview(deleteButton)
        buttonsContainerView.addSubview(cancelButton)
    }
    
    private func setupBlurBackground() {
        //  Создаем blur эффект
        backgroundBlurView.effect = nil // Начинаем без эффекта для анимации
        backgroundBlurView.alpha = 0
    }
    
    private func setupNFTImageView() {
        nftImageView.contentMode = .scaleAspectFill
        nftImageView.clipsToBounds = true
        nftImageView.layer.cornerRadius = 12
        nftImageView.backgroundColor = .systemGray6
        
        // Загружаем изображение NFT или показываем placeholder
        if let imageURL = nftImageURL {
            nftImageView.kf.setImage(
                with: imageURL,
                placeholder: createNFTPlaceholder(),
                options: [
                    .transition(.fade(0.3)),
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 200, height: 200)))
                ]
            )
        } else {
            nftImageView.image = createNFTPlaceholder()
        }
        
        // Начальная анимация
        nftImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        nftImageView.alpha = 0
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Вы уверены что хотите\nудалить товар из корзины?"
        titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        // Начальная анимация
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        titleLabel.alpha = 0
    }
    
    private func setupButtonsContainer() {
        buttonsContainerView.backgroundColor = .clear
        buttonsContainerView.alpha = 0
        buttonsContainerView.transform = CGAffineTransform(translationX: 0, y: 30)
    }
    
    private func setupDeleteButton() {
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.backgroundColor = .black
        deleteButton.setTitleColor(UIColor(named: "YP Red"), for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        deleteButton.layer.cornerRadius = 12
                
        // Эффект нажатия
        deleteButton.addTarget(self, action: #selector(deleteButtonTouchDown), for: .touchDown)
        deleteButton.addTarget(self, action: #selector(deleteButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Вернуться", for: .normal)
        cancelButton.backgroundColor = .black
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        cancelButton.layer.cornerRadius = 12
        
        // Эффект нажатия
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchDown), for: .touchDown)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Helper Methods
    private func createNFTPlaceholder() -> UIImage? {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Градиентный фон
            let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // NFT иконка в центре
            let iconSize: CGFloat = 80
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            
            if let icon = UIImage(systemName: "photo.artframe")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
                icon.draw(in: iconRect)
            }
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        backgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Blur background заполняет весь экран
            backgroundBlurView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundBlurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // NFT изображение по центру экрана
            nftImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nftImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            // Текст под изображением
            titleLabel.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Контейнер кнопок под текстом
            buttonsContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            buttonsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsContainerView.heightAnchor.constraint(equalToConstant: 44),
            buttonsContainerView.widthAnchor.constraint(equalToConstant: 262), // 127 + 8 + 127
            
            // Кнопка "Удалить" слева (НА ОДНОМ УРОВНЕ)
            deleteButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 127),
            
            // Кнопка "Вернуться" справа (НА ОДНОМ УРОВНЕ)
            cancelButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 8),
            cancelButton.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor),
            
        ])
    }
    
    // MARK: - Actions
    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Тап по blur фону для закрытия
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundBlurView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func deleteButtonTapped() {
        print(" Пользователь подтвердил удаление NFT: \(nftID)")
        
        animateDisappearance {
            //  Уведомляем CartViewController о подтверждении удаления с ID
            self.onDeleteConfirmed?(self.nftID)
        }
    }
    
    @objc private func cancelButtonTapped() {
        print(" Пользователь отменил удаление NFT: \(nftID)")
        
        animateDisappearance {
            //  Уведомляем CartViewController об отмене с ID
            self.onCancel?(self.nftID)
        }
    }
    
    @objc private func backgroundTapped() {
        cancelButtonTapped()
    }
    
    // MARK: - Button Touch Effects
    @objc private func deleteButtonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.deleteButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func deleteButtonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.deleteButton.transform = .identity
        }
    }
    
    @objc private func cancelButtonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.cancelButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func cancelButtonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.cancelButton.transform = .identity
        }
    }
    
    // MARK: - Animations
    private func animateAppearance() {
        // Анимация blur фона
        UIView.animate(withDuration: 0.3) {
            self.backgroundBlurView.alpha = 1
        }
        
        // Добавляем blur эффект с анимацией
        UIView.animate(withDuration: 0.4, delay: 0.1) {
            self.backgroundBlurView.effect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        }
        
        // Анимация NFT изображения (масштаб)
        UIView.animate(
            withDuration: 0.5,
            delay: 0.1,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            self.nftImageView.transform = .identity
            self.nftImageView.alpha = 1
        }
        
        // Анимация текста (появление снизу)
        UIView.animate(
            withDuration: 0.4,
            delay: 0.3,
            options: [.curveEaseOut]
        ) {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
        }
        
        // Анимация кнопок (появление снизу)
        UIView.animate(
            withDuration: 0.4,
            delay: 0.5,
            options: [.curveEaseOut]
        ) {
            self.buttonsContainerView.transform = .identity
            self.buttonsContainerView.alpha = 1
        }
    }
    
    private func animateDisappearance(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.backgroundBlurView.alpha = 0
            self.backgroundBlurView.effect = nil
            self.nftImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.nftImageView.alpha = 0
            self.titleLabel.alpha = 0
            self.buttonsContainerView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false) {
                completion()
            }
        }
    }
}

// MARK: - Presentation Helper
extension DeleteConfirmationViewController {
    
    //  Статический метод для удобного показа
    static func present(from viewController: UIViewController,
                        nftID: String,
                        nftImageURL: URL? = nil,
                        onDelete: @escaping (String) -> Void,
                        onCancel: ((String) -> Void)? = nil) {
        
        let deleteVC = DeleteConfirmationViewController(nftID: nftID, nftImageURL: nftImageURL)
        deleteVC.modalPresentationStyle = .overFullScreen
        deleteVC.modalTransitionStyle = .crossDissolve
        
        deleteVC.onDeleteConfirmed = onDelete
        deleteVC.onCancel = onCancel
        
        viewController.present(deleteVC, animated: false)
    }
}

