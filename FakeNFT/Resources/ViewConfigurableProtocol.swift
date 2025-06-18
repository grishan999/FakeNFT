import UIKit

protocol ViewConfigurable {
    func addSubviews()
    func addConstraints()
    func configureView()
}


extension ViewConfigurable where Self: UIViewController {
    func configureView() {
        addSubviews()
        addConstraints()
    }
}

