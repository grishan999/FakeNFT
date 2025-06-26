import UIKit

class MyNFTViewController: UIViewController {
    
    // MARK: - View Model
    private var nfts: [Nft] = []
    
    private let viewModel: MyNFTViewModel
    private var newProfileViewModel: ProfileViewModel
    
    init(
        viewModel: MyNFTViewModel,
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
    
    //MARK: - UI Elements
    private lazy var backButton: UIButton = {
            let button = UIButton()
            if let imageButton = UIImage(named:"back_button")?.withRenderingMode(.alwaysTemplate) {
                // Создаем четкое перевернутое изображение
                let rotatedImage = imageButton.withHorizontallyFlippedOrientation()
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
            button.setImage(
                imageButton,
                for: .normal
            )
            button.tintColor = .buttonColor
            button.addTarget(
                self,
                action: #selector(sortingButtonTapped),
                for: .touchUpInside
            )
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
        tableView.register(
            MyNFTTableViewCell.self,
            forCellReuseIdentifier: MyNFTTableViewCell.identifier
        )
        return tableView
    }()
    
    //MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.configure(with: newProfileViewModel)
        view.backgroundColor = .backgroudColor
        setupView()
        setupBindings()
        loadNFTs()
        
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
    private func sortingButtonTapped(
        _ sender: UIButton
    ) {
        showSortingAlert()
    }
    
    private func showSortingAlert() {
        let alertController = UIAlertController(
            title: NSLocalizedString("sorting.title", value: "Сортировка", comment: "Sorting alert title"),
            message: nil,
            preferredStyle: .actionSheet
        )
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("sorting.byPrice", value: "По цене", comment: "Sort by price action"),
            style: .default
        ) { _ in
            self.viewModel.sortByPrice()
            self.tableView.reloadData()
        })
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("sorting.byRating", value: "По рейтингу", comment: "Sort by rating action"),
            style: .default
        ) { _ in
            self.viewModel.sortByRating()
            self.tableView.reloadData()
        })
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("sorting.byName", value: "По названию", comment: "Sort by name action"),
            style: .default
        ) { _ in
            self.viewModel.sortByName()
            self.tableView.reloadData()
        })
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("general.close", value: "Закрыть", comment: "Close button"),
            style: .cancel,
            handler: nil
        ))
        present(alertController, animated: true, completion: nil)
    }
    
    private func showPlaceHolder() {
        let backgroundView = PlaceHolderView(
            frame: view.frame
        )
        backgroundView.setupNoNFTState()
        view.addSubview(backgroundView)
    }
    
    private func checkIfTableIsEmpty() {
        if viewModel.myNFT?.isEmpty == true {
            showPlaceHolder()
        }
    }
    
    private func loadNFTs() {
        viewModel.loadNFTs(mynft: viewModel.myNFT ?? [""])
    }
    
    private func setupBindings() {
        checkIfTableIsEmpty()
        updateAfterDownloadData()
        updateCellLoadingNFT()
    }
    
    private func updateAfterDownloadData() {
        viewModel.nftsUpdated = { [weak self] in
            self?.nfts = self?.viewModel.nfts ?? []
            self?.tableView.reloadData()
        }
    }
    
    private func updateCellLoadingNFT() {
        viewModel.nftsImageUpdate = { [weak self] nftId, image in
            guard let self = self else { return }
            
            if let index = self.nfts.firstIndex(where: { $0.id == nftId }) {
                let indexPath = IndexPath(row: index, section: 0)
                
                if let cell = self.tableView.cellForRow(at: indexPath) as? MyNFTTableViewCell {
                    cell.nftImageView.image = image ?? UIImage(named: "placeholder")
                }
            }
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
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return nfts.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MyNFTTableViewCell.identifier,
            for: indexPath
        ) as? MyNFTTableViewCell else {
            return UITableViewCell()
        }
        
        let nft = viewModel.nfts[indexPath.item]
        let image = viewModel.nftImages[nft.id] ?? UIImage(named: "placeholder")
        let ratingImage = viewModel.ratingImage(for: nft)
        cell.configure(
            with: nft,
            image: image,
            ratingImage: ratingImage
        )
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyNFTViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 140
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
    }
}

