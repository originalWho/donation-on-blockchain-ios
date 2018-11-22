import UIKit

protocol Router: AnyObject {

    func start()
    func stop()

}

protocol ViewableRouter: Router {

    var viewController: UIViewController { get }

}
