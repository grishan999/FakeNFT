import UIKit
import SwiftUI

// MARK: - Preview
struct MyNFTViewControllerPreview: PreviewProvider {
    static var previews: some View {
        MyNFTViewController().showPreview()
    }
}

extension UIImage {
    enum RotationQuality {
        case fast
        case high
    }
    
    func rotate(radians: CGFloat, quality: RotationQuality = .high) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = quality == .high ? self.scale : 1.0
        format.opaque = false
        format.preferredRange = .extended
        
        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: self.size)
            context.cgContext.translateBy(x: rect.midX, y: rect.midY)
            context.cgContext.rotate(by: radians)
            context.cgContext.translateBy(x: -rect.midX, y: -rect.midY)
            self.draw(in: rect)
        }.withRenderingMode(self.renderingMode)
    }
}

class MyNFTViewController: UIViewController {
    //MARK: - ViewModel
    var viewModel: ProfileViewModel?
    
    //MARK: - UI Elements
    private lazy var backButton: UIButton = {
        let button = UIButton()
        if let imageButton = UIImage(named: "back_button")?.withRenderingMode(.alwaysTemplate) {
            // Создаем четкое перевернутое изображение
            let rotatedImage = imageButton.rotate(radians: .pi, quality: .high)
            button.setImage(rotatedImage, for: .normal)
            button.tintColor = .buttonColor
            button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        }
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var sortingButton: UIButton = {
        let button = UIButton()
        if let imageButton = UIImage(named: "filter_button")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(imageButton, for: .normal)
            button.tintColor = .buttonColor
            button.addTarget(self, action: #selector(sortingButtonTapped), for: .touchUpInside)
        }
        button.widthAnchor.constraint(equalToConstant: 42).isActive = true
        button.heightAnchor.constraint(equalToConstant: 42).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .backgroudColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyNFTTableViewCell.self, forCellReuseIdentifier: MyNFTTableViewCell.identifier)
        return tableView
    }()
    
    //MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroudColor
        setupView()
        update()
    }
    
    //MARK: - Private Methods
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortingButton)
        navigationItem.title = localizedString(key: "myNFT")
        let customFont = UIFont.bodyBold
        let attributes: [NSAttributedString.Key: Any] = [
            .font: customFont,
            .foregroundColor: UIColor.buttonColor
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    @objc
    private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func sortingButtonTapped(_ sender: UIButton) {
        showSortingAlert()
    }
    
    private func update() {
        if viewModel != nil {
            tableView.reloadData()
            checkIfTableIsEmpty()
        } else {
            print("viewModel is nil")
        }
    }
    
    private func showSortingAlert() {
        let alertController = UIAlertController(
            title: localizedString(key: "sorting"),
            message: nil,
            preferredStyle: .actionSheet
        )
        alertController.addAction(UIAlertAction(
            title: localizedString(key: "sortingByPrice"),
            style: .default
        ) { _ in
            print("Сортировка по цене выбрана")
        })
        alertController.addAction(UIAlertAction(
            title: localizedString(key: "sortingByRating"),
            style: .default
        ) { _ in
            print("Сортировка по рейтингу выбрана")
        })
        alertController.addAction(UIAlertAction(
            title: localizedString(key: "sortingByName"),
            style: .default
        ) { _ in
            self.viewModel?.sortByName()
            self.tableView.reloadData()
        })
        alertController.addAction(UIAlertAction(
            title: localizedString(key: "close"),
            style: .cancel, handler: nil
        ))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showPlaceHolder() {
        let backgroundView = PlaceHolderView(frame: view.frame)
        backgroundView.setupNoNFTState()
        view.addSubview(backgroundView)
    }
    
    private func checkIfTableIsEmpty() {
        if viewModel?.myNFTNames.isEmpty == true {
            showPlaceHolder()
        }
    }
}

// MARK: - ViewConfigurable
extension MyNFTViewController: ViewConfigurable {
    func addSubviews() {
        view.addSubview(tableView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func setupView() {
        setupNavBar()
        configureView()
    }
}

// MARK: - UITableViewDataSource
extension MyNFTViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.myNFTNames.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyNFTTableViewCell.identifier, for: indexPath) as? MyNFTTableViewCell else {
            return UITableViewCell()
        }
        
        if let nftData = viewModel?.configureNFT(for: indexPath.item, from: .myNFT) {
            
            cell.nftImageView.image = nftData.image
            cell.nameLabel.text = nftData.name
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension MyNFTViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

