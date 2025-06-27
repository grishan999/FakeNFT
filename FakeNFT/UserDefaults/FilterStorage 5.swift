import Foundation

public protocol StorageProtocol: AnyObject {
    var chosenFilter: String? { get set }
}

final class FilterStorage: StorageProtocol {
    
    static let shared = FilterStorage()
    private init(){}
    
    enum Keys: String {
        case chosenFilter = "chosenFilter"
    }
    
    var chosenFilter: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.chosenFilter.rawValue)
        }
        set {
            guard let newValue = newValue else {
                return
            }
            
            UserDefaults.standard.set(newValue, forKey: Keys.chosenFilter.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    func store(with chosenFilter: String?) {
        self.chosenFilter = chosenFilter
    }
}
