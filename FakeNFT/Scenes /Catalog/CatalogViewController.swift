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
    private lazy var filterButton = UIButton()
    private let viewModel: CatalogViewModel
    
    init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModelBindings()
        viewModel.loadCategories()
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
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.setImage(UIImage(named: "SortCatalog"), for: .normal)
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 44),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 20),
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
        cell.configure(with: viewModel.categories[indexPath.row])
        return cell
    }
}

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        188
    }
    
}
