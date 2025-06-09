import Foundation
import UIKit

final class NFTmockModel {
    static let shared = NFTmockModel()
    private init(){}
    
    let getMockData = [nftCartModel(images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Luna/3.png"], name: "Archie", price: 2.3, rating: 3),
                       nftCartModel(images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Luna/3.png"], name: "Perchy", price: 4.4, rating: 4),
                       nftCartModel(images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Luna/3.png"], name: "Ivoro", price: 2.9, rating: 4)
    ]
}
