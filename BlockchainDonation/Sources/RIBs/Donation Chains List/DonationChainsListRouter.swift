import UIKit

protocol DonationChainsListRouter: AnyObject {

    func start()
    func stop()

}

final class DonationChainsListRouterImpl: DonationChainsListRouter {

    let viewController: UIViewController
    private let interactor: DonationChainsListInteractor

    init(interactor: DonationChainsListInteractor, viewController: UIViewController) {
        self.interactor = interactor
        self.viewController = viewController
    }

    func start() {
        interactor.start()
    }

    func stop() {
        interactor.stop()
    }

}
