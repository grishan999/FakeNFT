//
//  NFTCollection.swift
//  FakeNFT
//
//  Created by Ilya Grishanov on 08.06.2025.
//

import Foundation

struct NFTCollection: Decodable {
    let id: String
    let name: String
    let cover: URL
    let nfts: [String] 
    let description: String
    let author: String
}
