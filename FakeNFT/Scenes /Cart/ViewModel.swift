import Foundation

//  Протокол ViewModel - четко определенный интерфейс
protocol CartViewModelProtocol: AnyObject {
    var onStateChanged: ((CartViewState) -> Void)? { get set }
    var onStateChangedWithIndex: ((CartViewState, Int) -> Void)? { get set }
    var onFooterUpdated: ((CartViewState) -> Void)? { get set }  //  Отдельный callback для footer
    var onError: ((String) -> Void)? { get set }
    var onShowDeleteConfirmation: ((String, URL?) -> Void)? { get set }
    var onGetSortedNfts: (([NFTCellState]) -> Void)? { get set }
    
    func viewDidLoad()
    func removeItemRequested(nftID: String)
    func confirmRemoveItem(nftID: String)
    func sortBy(_ type: SortType)
}

// MARK: - ViewModel

final class CartViewModel: CartViewModelProtocol {
   
    func sortBy(_ type: SortType) {
        switch type {
            
        case .price:
            nftCellStates.sort { cell1, cell2 in
                let price1 = cell1.nft?.price ?? 0.0
                let price2 = cell2.nft?.price ?? 0.0
                return price1 > price2
            }
            print(" Отсортировано по цене")
            
        case .rating:
            nftCellStates.sort { cell1, cell2 in
                let rat1 = cell1.nft?.rating ?? 0
                let rat2 = cell2.nft?.rating ?? 0
                return rat1 > rat2
            }
            print("Отсортировано по рейтингу")
            
        case .name:
            nftCellStates.sort { cell1, cell2 in
                let nam1 = cell1.nft?.name ?? ""
                let nam2 = cell2.nft?.name ?? ""
                //  Правильная сортировка по алфавиту
                return nam1.localizedCaseInsensitiveCompare(nam2) == .orderedAscending
            }
            print("Отсортировано по названию")
        }
        
        self.onGetSortedNfts?(nftCellStates)
    }
    
    
    // MARK: - Bindings (связи с View)
    
    //  Реактивные связи через closures - View подписывается на изменения
    var onStateChanged: ((CartViewState) -> Void)?
    var onStateChangedWithIndex: ((CartViewState, Int) -> Void)?
    var onFooterUpdated: ((CartViewState) -> Void)?  //  Отдельный callback для footer
    var onError: ((String) -> Void)?
    var onShowDeleteConfirmation: ((String, URL?) -> Void)?
    var onGetSortedNfts: (([NFTCellState]) -> Void)?
    
    // MARK: - Properties
    
    private let servicesAssembly: ServicesAssembly
    
    //  состояние только здесь
    private var nftCellStates: [NFTCellState] = []
    
    //  Флаг загрузки только во ViewModel
    private var doneLoading = false
    
    // MARK: - Init
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Methods (интерфейс для View)
    
    func viewDidLoad() {
        loadOrder()
    }
    
    // MARK: - Private Methods (внутренняя логика)
    
    // центральный метод обновления состояния
    private func updateViewState(changedIndex: Int? = nil) {
        let footerInfo = createFooterInfo()
        
        let state = CartViewState(
            cellStates: nftCellStates,
            doneLoading: doneLoading,
            footerInfo: footerInfo
        )
        
        DispatchQueue.main.async { [weak self] in
            if let changedIndex = changedIndex {
                //  ТОЧЕЧНОЕ ОБНОВЛЕНИЕ: вызываем только onStateChangedWithIndex
                print("🎯 Оптимизация: изменилась ячейка с индексом \(changedIndex)")
                self?.onStateChangedWithIndex?(state, changedIndex)
            } else {
                //  ПОЛНОЕ ОБНОВЛЕНИЕ: вызываем только onStateChanged
                print("🔄 Полное обновление: reloadData()")
                self?.onStateChanged?(state)
            }
        }
    }
    
    // Обновляем весь массив ячеек - ПОЛНОЕ ОБНОВЛЕНИЕ (reloadData)
    private func updateAllCellStates(_ newStates: [NFTCellState]) {
        nftCellStates = newStates
        updateViewState()  // changedIndex = nil → полное обновление
    }
    
    //  Вычисляем информацию для footer на основе текущего состояния
    private func createFooterInfo() -> CartViewState.FooterInfo? {
        guard doneLoading == true else { return nil }
        
        let loadedNFTs = nftCellStates.compactMap { $0.nft }
        let count = nftCellStates.count
        let totalPrice = loadedNFTs.reduce(0) { $0 + $1.price }
        let isPayButtonEnabled = !loadedNFTs.isEmpty
        
        return CartViewState.FooterInfo(
            count: count,
            totalPrice: totalPrice,
            isPayButtonEnabled: isPayButtonEnabled
        )
    }
    
    // Загрузка заказа - начальная точка
    private func loadOrder() {
        servicesAssembly.nftService.loadOrder(id: "1") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let order):
                    print("📦 Loaded order with \(order.nfts.count) NFTs")
                    self?.createSkeletonCells(for: order.nfts)
                    self?.loadNFTsData(ids: order.nfts)
                case .failure(let error):
                    self?.onError?("Ошибка загрузки корзины: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //  Создаем skeleton ячейки - ЕДИНСТВЕННЫЙ вызов reloadData()
    private func createSkeletonCells(for nftIDs: [String]) {
        let skeletonStates = nftIDs.map { NFTCellState.loading(id: $0) }
        updateAllCellStates(skeletonStates)  //  changedIndex = nil → reloadData()
        print("🔄 Created \(nftCellStates.count) skeleton cells - ЕДИНСТВЕННЫЙ reloadData()")
    }
    
    //  Загружаем данные для каждой NFT параллельно
    private func loadNFTsData(ids: [String]) {
        for (index, id) in ids.enumerated() {
            loadSingleNFT(id: id, at: index)
        }
    }
    
    //  Загружаем одну NFT и обновляем конкретную ячейку
    private func loadSingleNFT(id: String, at index: Int) {
        servicesAssembly.nftService.loadNftCartModel(id: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self, index < self.nftCellStates.count else { return }
                
                switch result {
                case .success(let nft):
                    // ТОЧЕЧНОЕ обновление конкретной ячейки
                    self.updateCellState(at: index, to: .loaded(nft: nft))
                    print(" Loaded NFT at index \(index): \(nft.name)")
                    
                case .failure(let error):
                    // ТОЧЕЧНОЕ обновление конкретной ячейки
                    self.updateCellState(at: index, to: .error(id: id, error: error))
                    print(" Failed to load NFT at index \(index): \(error)")
                }
                
                self.checkIfAllNFTsLoaded()
            }
        }
    }
    
    //  Обновляем конкретную ячейку - ТОЧЕЧНОЕ ОБНОВЛЕНИЕ (reloadRows)
    private func updateCellState(at index: Int, to newState: NFTCellState) {
        guard index < nftCellStates.count else { return }
        
        //  ДОПОЛНИТЕЛЬНОЕ ЛОГГИРОВАНИЕ для диагностики
        print("🔄 Обновляем ячейку \(index): \(newState.id)")
        if case .loaded(let nft) = newState {
            print("📸 NFT загружен: \(nft.name), imageURL: \(nft.imageURL?.absoluteString ?? "nil")")
        }
        
        nftCellStates[index] = newState
        updateViewState(changedIndex: index)  //  changedIndex = index → reloadRows
    }
    
    //  Проверяем все ли NFT загружены
    private func checkIfAllNFTsLoaded() {
        let loadedCount = nftCellStates.filter { $0.isLoading == false }.count
        let totalCount = nftCellStates.count
        
        if loadedCount == totalCount && totalCount > 0 {
            doneLoading = true
            
            //  отдельный callback только для обновления footer
            let footerInfo = createFooterInfo()
            
            let state = CartViewState(
                cellStates: nftCellStates,
                doneLoading: doneLoading,
                footerInfo: footerInfo
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.onFooterUpdated?(state)  //  Только footer, никаких reloadData()
            }
            
            print("🎉 All NFTs loaded! - только footer обновлен")
        }
    }
    
    // MARK: - Удаление nft
    
    //  View сообщает о намерении удалить, ViewModel решает что делать
    func removeItemRequested(nftID: String) {
        let imageURL = getNFTImageURL(for: nftID)
        onShowDeleteConfirmation?(nftID, imageURL)
    }
    
    //  View подтверждает удаление, ViewModel выполняет бизнес-логику
    func confirmRemoveItem(nftID: String) {
        removeItemByID(nftID: nftID)
    }
    
    //  Бизнес-логика удаления NFT
    private func removeItemByID(nftID: String) {
        let currentNftIds = nftCellStates.map { $0.id }
        let filteredNftIds = currentNftIds.filter { $0 != nftID }
        
        print("🗑️ Удаляем NFT \(nftID)")
        print("📋 Было NFT: \(currentNftIds)")
        print("📋 Стало NFT: \(filteredNftIds)")
        
        //  Отправляем запрос на сервер
        servicesAssembly.nftService.changeOrPaytOrder(nftIds: filteredNftIds) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print(" NFT \(nftID) успешно удален с сервера")
                    //  Обновляем локальное состояние после успешного ответа сервера
                    self?.removeItemFromState(nftID: nftID)
                    
                case .failure(let error):
                    print(" Ошибка удаления NFT \(nftID): \(error)")
                    self?.onError?("Ошибка удаления товара: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //  Удаляем элемент из локального состояния - ПОЛНОЕ ОБНОВЛЕНИЕ
    private func removeItemFromState(nftID: String) {
        nftCellStates.removeAll { $0.id == nftID }
        updateViewState()  //  changedIndex = nil → полное обновление при удалении
        print(" NFT удален из корзины")
    }
    
    //  Получаем URL изображения для конкретной NFT
    private func getNFTImageURL(for nftID: String) -> URL? {
        guard let cellState = nftCellStates.first(where: { $0.id == nftID }) else {
            return nil
        }
        
        switch cellState {
        case .loaded(let nft):
            return nft.imageURL
        default:
            return nil
        }
    }
}
