import UIKit

protocol PayOrderViewModelProtocol: AnyObject {
    func viewDidLoad()
    func payOrderButtonPressed(completion: @escaping (Result<String,Error>)-> Void)
}

enum PayOrderState {
    case initial
    case loading
    case didLoadData(Currency)
    case error(Error)
}

final class PayOrderViewModel: PayOrderViewModelProtocol {
    
    func payOrderButtonPressed(completion: @escaping (Result<String, any Error>) -> Void) {

        //  Отправляем запрос на сервер
        servicesAssembly.nftService.changeOrPatOrder(nftIds: []) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("NFT Успех Оплаты")
                    completion(.success("NFT Успех Оплаты"))
                case .failure(let error):
                    completion(.failure(error))
                    print(" Ошибка проведения оплаты \(error)")
                }
            }
        }
        print("Оплатить нажата")
    }
    
    
    weak var view: PayOrderViewControllerProtocol?
    private let servicesAssembly: ServicesAssembly
    private let state: PayOrderState
    private var nfts: [NFTCellState]
    
    init(servicesAssembly: ServicesAssembly, nfts: [NFTCellState]) {
        self.servicesAssembly = servicesAssembly
        self.nfts = nfts
        state = .initial
    }
    
    func viewDidLoad() {
        loadCurrencies()
    }
    
    func loadCurrencies(){
        servicesAssembly.nftService.loadCurrencies { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.view?.didLoadCurrencies(with: currencies)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}


