//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 03.06.2025.
//

import UIKit
import ProgressHUD

final class CatalogViewController: UIViewController {
    private lazy var tableView = UITableView()
    private let viewModel: CatalogViewModel
    private let servicesAssembly: ServicesAssembly
    
    init(viewModel: CatalogViewModel, servicesAssembly: ServicesAssembly) {
        self.viewModel = viewModel
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupViewModelBindings()
        viewModel.loadCategories()
    }
    
    private func setupNavigationBar() {
        title = nil
        
        let image = UIImage(named: "SortCatalog")?.withRenderingMode(.alwaysOriginal)
        let filterButton = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        navigationItem.rightBarButtonItem = filterButton
    }
    
    private func setupViewModelBindings() {
        viewModel.onCategoriesUpdate = { [weak self] categories in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onLoadingUpdate = { isLoading in
            DispatchQueue.main.async {
                isLoading ? ProgressHUD.show() : ProgressHUD.dismiss()
            }
        }
        
        viewModel.onErrorUpdate = { errorMessage in
            DispatchQueue.main.async {
                if let message = errorMessage {
                    ProgressHUD.showError(message, delay: 2.0)
                }
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(CatalogCell.self, forCellReuseIdentifier: CatalogCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func filterTapped() {
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "По названию", style: .default) { [weak self] _ in
            self?.viewModel.sortByName()
        })
        
        alert.addAction(UIAlertAction(title: "По количеству NFT", style: .default) { [weak self] _ in
            self?.viewModel.sortByCount()
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CatalogCell.reuseIdentifier, for: indexPath) as! CatalogCell
        
        guard indexPath.row < viewModel.categories.count else {
            return cell
        }
        
        let category = viewModel.categories[indexPath.row]
        cell.configure(with: category)
        return cell
    }
}

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        188
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = viewModel.categories[indexPath.row]
        
        let nftCollectionViewModel = servicesAssembly.nftCollectionViewModel(collectionId: category.id)
        let nftCollectionVC = NFTCollectionViewController(viewModel: nftCollectionViewModel)
        navigationController?.pushViewController(nftCollectionVC, animated: true)
    }
}
