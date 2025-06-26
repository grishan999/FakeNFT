import UIKit
import SwiftUI

// MARK: - Preview
struct StatisticsViewControllerPreview: PreviewProvider {
    static var previews: some View {
        StatisticsViewController().showPreview()
    }
}

final class StatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}


