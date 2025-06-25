import UIKit

final class ProfileChangeViewController: UIViewController {
    // MARK: - ViewModel
    private var viewModel: ProfileChangeViewModel
    private var newProfileViewModel: ProfileViewModel
    
    init(
        viewModel: ProfileChangeViewModel,
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
    
    // MARK: - UIScrollView
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
    
    // MARK: - UI Elements
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        if let imageButton = UIImage(named: "close_button")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(
                imageButton,
                for: .normal
            )
            button.tintColor = .buttonColor
        }
        button.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let darkOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var changePfotoButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            localizedString(key: "changePhoto"),
            for: .normal
        )
        button.titleLabel?.font = .caption3
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.addTarget(
            self,
            action: #selector(didTapChangePhotoButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var downloadImageButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            localizedString(key: "uploadImage"),
            for: .normal
        )
        button.titleLabel?.font = .bodyRegular
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(
            .buttonColor,
            for: .normal
        )
        button.isHidden = true
        button.addTarget(
            self,
            action: #selector(didTapDownloadImageButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = localizedString(key: "name")
        label.font = .headline3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.text = viewModel.userName
        textField.font = .bodyRegular
        textField.textColor = .buttonColor
        textField.backgroundColor = .greyColor
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = localizedString(key: "description")
        label.font = .headline3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.text = viewModel.userDescription
        textView.font = .bodyRegular
        textView.textColor = .buttonColor
        textView.backgroundColor = .greyColor
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var websiteLabel: UILabel = {
        let label = UILabel()
        label.text = localizedString(key: "website")
        label.font = .headline3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var websiteTextField: UITextField = {
        let textField = UITextField()
        textField.text = viewModel.userWebsite
        textField.font = .bodyRegular
        textField.textColor = .buttonColor
        textField.backgroundColor = .greyColor
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.configure(with: newProfileViewModel)
        view.backgroundColor = .backgroudColor
        configureView()
        setupBindings()
        registerForKeyboardNotifications()
    }
    
    // MARK: - Private Methods
    @objc
    private func didTapCloseButton() {
        let newName = nameTextField.text ?? ""
        let newDescription = descriptionTextView.text ?? ""
        let newWebsite = websiteTextField.text ?? ""
        let newAvatarUrl = self.viewModel.profileImageUrl ?? ""
        
        viewModel.updateProfile(
            name: newName,
            avatar: newAvatarUrl,
            description: newDescription,
            website: newWebsite
        ) { [weak self] result in
            switch result {
            case .success:
                print("Профиль успешно обновлен")
            case .failure(let error):
                print("Ошибка обновления профиля: \(error)")
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    private func didTapChangePhotoButton() {
        print("qwertyuio")
        downloadImageButton.isHidden.toggle()
    }
    
    @objc
    private func didTapDownloadImageButton() {
        showAvatarAlert()
    }
    
    // MARK: - Setup Methods
    private func setupBindings() {
        updateScreenInformation()
        updateImage()
        viewModel.loadProfileImage()
    }
    
    private func updateScreenInformation() {
        viewModel.profileUpdated = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.nameTextField.text = self.viewModel.userName
                self.descriptionTextView.text = self.viewModel.userDescription
                self.websiteTextField.text = self.viewModel.userWebsite
            }
        }
    }
    
    private func updateImage() {
        viewModel.profileImageUpdated = { [weak self] (image: UIImage?) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.profileImage.image = image
            }
        }
    }
    
    private func showAvatarAlert() {
        let alertController = UIAlertController(
            title: "Введите URL аватарки",
            message: nil,
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "https://example.com/avatar/png"
            textField.keyboardType = .URL
            textField.autocorrectionType = .no
        }
        
        let closeAction = UIAlertAction(
            title: "Закрыть",
            style: .cancel,
            handler: nil
        )
        alertController.addAction(closeAction)
        
        let okAction = UIAlertAction(
            title: "Ок",
            style: .default
        ) { [weak self] _ in
            guard let self = self else {return}
            if let urlText = alertController.textFields?.first?.text, !urlText.isEmpty {
                self.viewModel.profileImageUrl = urlText
            } else {
                print("URL не введен или пуст")
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver (
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver (
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        setupHideKeyboardGesture()
    }
    
    @objc
    private func keyboardWillShow(
        _ notification: Notification
    ) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height
    }
    
    @objc
    private func keyboardWillHide(
        _ notification: Notification
    ) {
        scrollView.contentInset.bottom = .zero
    }
    
    private func setupHideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer (
            target: self,
            action: #selector(hideKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - ViewConfigurable Methods
extension ProfileChangeViewController: ViewConfigurable {
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        let subViews = [
            closeButton,
            profileImage,
            downloadImageButton,
            nameLabel,
            nameTextField,
            descriptionLabel,
            descriptionTextView,
            websiteLabel,
            websiteTextField
        ]
        subViews.forEach { contentView.addSubview($0) }
        [darkOverlay, changePfotoButton].forEach {
            profileImage.addSubview($0)
        }
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 42),
            closeButton.heightAnchor.constraint(equalToConstant: 42),
            
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 22),
            
            darkOverlay.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            darkOverlay.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            darkOverlay.topAnchor.constraint(equalTo: profileImage.topAnchor),
            darkOverlay.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor),
            
            changePfotoButton.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor),
            changePfotoButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            changePfotoButton.widthAnchor.constraint(equalToConstant: 45),
            changePfotoButton.heightAnchor.constraint(equalToConstant: 24),
            
            downloadImageButton.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 4),
            downloadImageButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            downloadImageButton.widthAnchor.constraint(equalToConstant: 250),
            downloadImageButton.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 174),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.heightAnchor.constraint(equalToConstant: 28),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 76),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 28),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 132),
            
            websiteLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 164),
            websiteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            websiteLabel.heightAnchor.constraint(equalToConstant: 28),
            
            websiteTextField.topAnchor.constraint(equalTo: websiteLabel.bottomAnchor, constant: 8),
            websiteTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            websiteTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            websiteTextField.heightAnchor.constraint(equalToConstant: 40),
            websiteTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}

