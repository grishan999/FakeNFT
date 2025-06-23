import UIKit
import ProgressHUD

protocol PayOrderViewControllerProtocol: AnyObject {
    func didLoadCurrencies(with currencies: [Currency])
}

final class PayOrderViewController: UIViewController, PayOrderViewControllerProtocol {
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
    
    @objc func payButtonTapped() {
        if selectedIndexPath == nil {
            let alertPresenter = UIAlertController(title: "Пожалуйста, выберите валюту для оплаты", message: nil, preferredStyle: .alert)
            self.present(alertPresenter, animated: true)
            let ok = UIAlertAction(title: "Ясно!", style: .default) { action in
                alertPresenter.dismiss(animated: true)
            }
            alertPresenter.addAction(ok)
            return
        }
        ProgressHUD.show()
        viewModel.payOrderButtonPressed { result in
            switch result{
            case .success(_):
                ProgressHUD.dismiss()
                let successPaymentViewController = SuccessPaymentViewController()
                successPaymentViewController.modalPresentationStyle = .fullScreen
                self.present(successPaymentViewController, animated: true)
                print("!")
            case .failure(_):
                ProgressHUD.dismiss()
                let alertPresenter = UIAlertController(title: "Не удалось произвести оплату", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Отмена", style: .default) { action in
                    alertPresenter.dismiss(animated: true)
                }
                let reTry = UIAlertAction(title: "Повторить", style: .default) { action in
                    self.payButtonTapped()
                }
                alertPresenter.addAction(cancelAction)
                alertPresenter.addAction(reTry)
                self.present(alertPresenter, animated: true)
            }
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 7
        layout.minimumInteritemSpacing = 7
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PayOrdercollectionViewCell.self, forCellWithReuseIdentifier: PayOrdercollectionViewCell.id)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    //  FOOTER ЭЛЕМЕНТЫ
    private lazy var footerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP LightGrey")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .left
        
        let text = "Совершая покупку, вы соглашаетесь с условиями\nПользовательского соглашения"
        let attributedString = NSMutableAttributedString(string: text)
        
        //  Настройка параграфа для line height (18px)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5  // 18px - 13px = 5px line spacing
        paragraphStyle.alignment = .left
        
        //  Основные атрибуты текста
        let fullRange = NSRange(location: 0, length: text.count)
        
        // Font: SF Pro Text Regular 13px
        attributedString.addAttribute(.font,
                                      value: UIFont.systemFont(ofSize: 13, weight: .regular),
                                      range: fullRange)
        
        // Color: серый
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.black,
                                      range: fullRange)
        
        // Letter spacing: -0.08px
        attributedString.addAttribute(.kern,
                                      value: -0.08,
                                      range: fullRange)
        
        //  Line height через paragraphStyle
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: fullRange)
        
        //  Синяя ссылка для "Пользовательского соглашения"
        if let range = text.range(of: "Пользовательского соглашения") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.foregroundColor,
                                          value: UIColor.systemBlue,
                                          range: nsRange)
            // Letter spacing и для синей части
            attributedString.addAttribute(.kern,
                                          value: -0.08,
                                          range: nsRange)
        }
        
        label.attributedText = attributedString
        return label
    }()
    
    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Оплатить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var currencies: [Currency] = []
    private var selectedIndexPath: IndexPath?
    
    
    func didLoadCurrencies(with currencies: [Currency]) {
        self.currencies = currencies
        collectionView.reloadData()
    }
    
    private let viewModel: PayOrderViewModelProtocol
    
    init(viewModel: PayOrderViewModelProtocol){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupProgressHUD()
        viewModel.viewDidLoad()
        setupUI()
        setupNavigation()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы на экран
        view.addSubview(collectionView)
        view.addSubview(footerContainerView)
        
        //  Добавляем элементы в footer
        footerContainerView.addSubview(agreementLabel)
        footerContainerView.addSubview(payButton)
        
        // Настраиваем констрейнты
        NSLayoutConstraint.activate([
            //  Collection view теперь не доходит до низа
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: footerContainerView.topAnchor),
            
            //  Footer container
            footerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerContainerView.heightAnchor.constraint(equalToConstant: 186),
            
            //  Agreement label
            agreementLabel.topAnchor.constraint(equalTo: footerContainerView.topAnchor, constant: 16),
            agreementLabel.leadingAnchor.constraint(equalTo: footerContainerView.leadingAnchor, constant: 16),
            agreementLabel.trailingAnchor.constraint(equalTo: footerContainerView.trailingAnchor, constant: -16),
            
            //  Pay button
            payButton.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor, constant: 16),
            payButton.leadingAnchor.constraint(equalTo: footerContainerView.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: footerContainerView.trailingAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 60),
            
        ])
        
        setupAgreementTapGesture()
    }
    
    private func setupAgreementTapGesture() {
        //  Включаем взаимодействие с пользователем
        agreementLabel.isUserInteractionEnabled = true
        
        //  Добавляем gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(agreementLabelTapped(_:)))
        agreementLabel.addGestureRecognizer(tapGesture)
    }
    
    //:
    
    @objc private func agreementLabelTapped(_ gesture: UITapGestureRecognizer) {
        guard let text = agreementLabel.attributedText?.string else { return }
        
        let termsRange = (text as NSString).range(of: "Пользовательского соглашения")
        
        if termsRange.location != NSNotFound {
            //  Получаем позицию клика
            let location = gesture.location(in: agreementLabel)
            
            //  Проверяем, попал ли клик в область текста "Пользовательского соглашения"
            if didTapOnText(location: location, textRange: termsRange, in: agreementLabel) {
                print("🔗 Клик по 'Пользовательского соглашения'")
                openTermsOfUse()
            } else {
                print("ℹ️ Клик вне ссылки")
            }
        }
    }
    
    private func didTapOnText(location: CGPoint, textRange: NSRange, in label: UILabel) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        
        //  Создаем NSTextContainer
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        //  Создаем NSLayoutManager
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        //  Создаем NSTextStorage
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)
        
        //  Получаем индекс символа по координатам клика
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        //  Проверяем, попадает ли индекс в диапазон ссылки
        return NSLocationInRange(characterIndex, textRange)
    }
    
    //  ДОБАВЬ ЭТОТ МЕТОД для открытия WebView:
    
    private func openTermsOfUse() {
        print("Открываем Пользовательское соглашение")
        
        //  Используем статический метод WebViewController
        WebViewController.presentTermsOfUse(from: self)
    }
    
    private func setupNavigation() {
        title = "Выберите способ оплаты"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Back Icon"),
            style: .plain,
            target: self,
            action: #selector(dismissViewController)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        //  Дополнительные настройки навбара (опционально)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}

extension PayOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PayOrdercollectionViewCell.id,
            for: indexPath
        ) as? PayOrdercollectionViewCell else {
            return UICollectionViewCell()
        }
        let currency = currencies[indexPath.item]
        cell.configure(with: currency)
        
        return cell
    }
    
    //  обработка выбора ячейки
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Убираем выделение с предыдущей ячейки
        if let previousSelectedIndexPath = selectedIndexPath,
           let previousCell = collectionView.cellForItem(at: previousSelectedIndexPath) as? PayOrdercollectionViewCell {
            previousCell.setSelected(false)
        }
        
        // Устанавливаем новую выбранную ячейку
        selectedIndexPath = indexPath
        
        if let currentCell = collectionView.cellForItem(at: indexPath) as? PayOrdercollectionViewCell {
            currentCell.setSelected(true)
        }
        
        // Логика для выбранной валюты
        let selectedCurrency = currencies[indexPath.item]
        print("Выбрана валюта: \(selectedCurrency.name)")
    }
}

extension PayOrderViewController: UICollectionViewDelegateFlowLayout {
    
    //  Размер ячеек с учетом отступов
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let horizontalInsets: CGFloat = 16 + 16    // 16 слева + 16 справа = 32
        let spacingBetweenItems: CGFloat = 7       // 7 между ячейками
        let numberOfItemsPerRow: CGFloat = 2       // 2 ячейки в ряду
        
        // Вычисляем ширину ячейки
        let totalHorizontalSpacing = horizontalInsets + spacingBetweenItems * (numberOfItemsPerRow - 1)
        let itemWidth = (collectionView.frame.width - totalHorizontalSpacing) / numberOfItemsPerRow
        
        // Высоту можешь настроить под свой дизайн
        let itemHeight: CGFloat = 46
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    //  Отступы от краев коллекции (16 пунктов по горизонтали)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    // MARK: - ProgressHUD Configuration
    private func setupProgressHUD() {
        //  Размер 82x82 пикселя
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .systemGray
        ProgressHUD.colorBackground = .clear
        ProgressHUD.colorHUD = .systemBackground
        ProgressHUD.colorStatus = .label
        ProgressHUD.fontStatus = UIFont.systemFont(ofSize: 16)
        
        
        
        //  Настройка прозрачности фона
        ProgressHUD.colorBackground = UIColor.black.withAlphaComponent(0.3)
        
    }
}
