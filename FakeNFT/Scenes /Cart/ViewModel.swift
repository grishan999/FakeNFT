import Foundation

//  Протокол ViewModel - четко определенный интерфейс
protocol CartViewModelProtocol: AnyObject {
    var onStateChanged: ((CartViewState) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onShowDeleteConfirmation: ((String, URL?) -> Void)? { get set }
    
    func viewDidLoad()
    func removeItemRequested(nftID: String)
    func confirmRemoveItem(nftID: String)
}

// MARK: - ViewModel

final class CartViewModel: CartViewModelProtocol {
    
    // MARK: - Bindings (связи с View)
    
    //  Реактивные связи через closures - View подписывается на изменения
    var onStateChanged: ((CartViewState) -> Void)?
    var onError: ((String) -> Void)?
    var onShowDeleteConfirmation: ((String, URL?) -> Void)?
    
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
    
    //  Центральный метод обновления состояния
    private func updateViewState(changedIndex: Int? = nil) {
        let footerInfo = createFooterInfo()
        
        let state = CartViewState(
            cellStates: nftCellStates,
            doneLoading: doneLoading,
            footerInfo: footerInfo
        )
        
        DispatchQueue.main.async { [weak self] in
            // 🎯 ОПЦИОНАЛЬНАЯ ОПТИМИЗАЦИЯ: можно передать индекс изменившейся ячейки
            if let changedIndex = changedIndex {
                // В будущем можно оптимизировать - обновлять только конкретную ячейку
                print("🎯 Оптимизация: изменилась ячейка с индексом \(changedIndex)")
            }
            
            self?.onStateChanged?(state)
        }
    }
    
    // Обновляем весь массив ячеек
    private func updateAllCellStates(_ newStates: [NFTCellState]) {
        nftCellStates = newStates
        updateViewState()  // ✅ Явно обновляем UI после изменения всего массива
    }
    
    //  Вычисляем информацию для footer на основе текущего состояния
    private func createFooterInfo() -> CartViewState.FooterInfo? {
        guard doneLoading == true else { return nil } // делаем футер если загружена дата иначе нил
        
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
    
    //  Создаем skeleton ячейки - промежуточное состояние
    private func createSkeletonCells(for nftIDs: [String]) {
        let skeletonStates = nftIDs.map { NFTCellState.loading(id: $0) }
        updateAllCellStates(skeletonStates)  // ✅ Явный вызов обновления
        print("🔄 Created \(nftCellStates.count) skeleton cells")
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
                    //  обновляем конкретную ячейку
                    self.updateCellState(at: index, to: .loaded(nft: nft))
                    print("✅ Loaded NFT at index \(index): \(nft.name)")
                    
                case .failure(let error):
                    // конкретную ячейку
                    self.updateCellState(at: index, to: .error(id: id, error: error))
                    print("❌ Failed to load NFT at index \(index): \(error)")
                }
                
                self.checkIfAllNFTsLoaded()
            }
        }
    }
    
    // Обновляем конкретную ячейку и перерисовываем UI
    private func updateCellState(at index: Int, to newState: NFTCellState) {
        guard index < nftCellStates.count else { return }
        
        nftCellStates[index] = newState
        updateViewState(changedIndex: index)  // Явно указываем какая ячейка изменилась
    }
    
    //  Проверяем все ли NFT загружены
    private func checkIfAllNFTsLoaded() {
        let loadedCount = nftCellStates.filter { $0.isLoading == false }.count
        let totalCount = nftCellStates.count
        
        if loadedCount == totalCount && totalCount > 0 {
            doneLoading = true
            updateViewState()  //  Явно обновляем UI после изменения флага
            print("🎉 All NFTs loaded!")
        }
    }
    
    // Обновляем флаг загрузки
    private func updateLoadingState(_ isLoading: Bool) {
        doneLoading = !isLoading
        updateViewState()  //  Явно обновляем UI после изменения флага
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
        servicesAssembly.nftService.changeOrder(nftIds: filteredNftIds) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ NFT \(nftID) успешно удален с сервера")
                    //  Обновляем локальное состояние после успешного ответа сервера
                    self?.removeItemFromState(nftID: nftID)
                    
                case .failure(let error):
                    print("❌ Ошибка удаления NFT \(nftID): \(error)")
                    self?.onError?("Ошибка удаления товара: \(error.localizedDescription)")
                }
            }
        }
    }
    
    //  Удаляем элемент из локального состояния
    private func removeItemFromState(nftID: String) {
        nftCellStates.removeAll { $0.id == nftID }
        updateViewState()
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
