import UIKit
import SwiftUI

// MARK: - Preview
struct CartViewControllerPreview: PreviewProvider {
    static var previews: some View {
        CartViewController().showPreview()
    }
}

final class CartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}


