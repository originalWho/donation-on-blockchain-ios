import UIKit

protocol Identifiable {

    static var identifier: String { get }

}

extension Identifiable {

    static var identifier: String {
        return String(describing: Self.self)
    }

}

extension UIViewController: Identifiable { }
extension UITableViewCell: Identifiable { }
