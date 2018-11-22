import Foundation

protocol DonationChainsListInteractor: Interactor {

    func registerDonation(_ donation: Donation)
    func requestDonationChains()

}

final class DonationChainsListInteractorImpl: DonationChainsListInteractor {

    var canRegisterDonation: Bool {
        return pendingDonation == nil
    }

    private let client: Client
    private let storage: DonationChainStorage
    private let presenter: DonationChainsListPresenter

    private var pendingDonation: Donation?

    init(presenter: DonationChainsListPresenter, client: Client, storage: DonationChainStorage) {
        self.presenter = presenter
        self.client = client
        self.storage = storage
    }

    func start() {
        client.delegate = self
    }

    func stop() {
        client.delegate = nil
    }

    func registerDonation(_ donation: Donation) {
        guard canRegisterDonation else {
            return
        }

        pendingDonation = donation
        client.registerDonation(donation)
    }

    func requestDonationChains() {

    }
    
}

extension DonationChainsListInteractorImpl: ClientDelegate {

    func client(_ client: Client, onRegisterDonationDidCompleteWith donationChainID: DonationChainID) {
        
    }

    func client(_ client: Client, onRegisterDonationDidFinishWithError error: Error?) {
        // TODO: Schedule another attempt or present user a feedback
    }

    func client(_ client: Client, onRequestDonationChainWithID: DonationChainID,
                didCompleteWith donationChainItems: [DonationChainItem]) {
        
    }

    func client(_ client: Client, onRequestDonationChainWithID: DonationChainID,
                didFinishWithError error: Error?) {

    }

}
