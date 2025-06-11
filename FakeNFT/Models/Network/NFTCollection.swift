//
//  NFTCollection.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 08.06.2025.
//

import Foundation

struct NFTCollection: Decodable {
    let name: String
    let cover: String
    let nfts: [String]
    let id: String
    let description: String
    let author: String
    let createdAt: Date
}
