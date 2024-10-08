import Foundation
import UIKit

extension UITableView {
    func setupTable(identifier: String, vc: UIViewController) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        self.delegate = vc as? UITableViewDelegate
        self.dataSource = vc as? UITableViewDataSource
    }
}
