import UIKit

protocol DonationChainsListRouter: ViewableRouter {

}

final class DonationChainsListRouterImpl: DonationChainsListRouter {

    let viewController: UIViewController
    private let interactor: Interactor

    init(interactor: Interactor, viewController: UIViewController) {
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
