import UIKit
import SwiftUI

// MARK: - Preview
struct CatalogViewControllerPreview: PreviewProvider {
    static var previews: some View {
        CatalogViewController().showPreview()
    }
}

final class CatalogViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}


