import Foundation

protocol DonationChainsListInteractor: AnyObject {

    func start()
    func stop()

}

final class DonationChainsListInteractorImpl: DonationChainsListInteractor {

    private let client: Client
    private let presenter: DonationChainsListPresenter

    init(presenter: DonationChainsListPresenter, client: Client) {
        self.presenter = presenter
        self.client = client
    }

    func start() {

    }

    func stop() {

    }
    
}
