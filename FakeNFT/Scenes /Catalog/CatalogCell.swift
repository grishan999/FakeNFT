//
//  CatalogCell.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 04.06.2025.
//

import UIKit

final class CatalogCell: UITableViewCell {
    static let reuseIdentifier = "CatalogCell"

    private let nameLabel = UILabel()
    private let nftImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with category: CatalogCategory) {
        nameLabel.text = "\(category.title) (\(category.count))"
        
        URLSession.shared.dataTask(with: category.imageUrl) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.nftImageView.image = UIImage(data: data)
            }
        }.resume()
    }

    private func setupUI() {
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        nftImageView.layer.cornerRadius = 12
        nftImageView.clipsToBounds = true
        nftImageView.contentMode = .scaleAspectFill

        nameLabel.font = .bodyBold
        nameLabel.numberOfLines = 1
        nameLabel.textColor = .label

        contentView.addSubview(nftImageView)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nftImageView.heightAnchor.constraint(equalToConstant: 140),

            nameLabel.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -21)
        ])
    }
}

