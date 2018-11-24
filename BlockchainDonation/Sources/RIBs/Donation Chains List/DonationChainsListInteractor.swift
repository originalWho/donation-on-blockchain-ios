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
        client.cancelRequests()
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
        let identifiers = storage.chainsIdentifiers
        identifiers.forEach { client.requestDonationChain(with: $0) }
    }
    
}

extension DonationChainsListInteractorImpl: ClientDelegate {

    func client(_ client: Client, onRegisterDonationDidCompleteWith donationChainID: DonationChainID) {
        guard let pendingDonation = pendingDonation else {
            assertionFailure("Pending donation is nil, yet a donation has been registered.")
            return
        }

        let donationChain = DonationChain(donation: pendingDonation,
                                          identifier: donationChainID,
                                          items: [])
        storage.saveDonationChain(donationChain)
        self.pendingDonation = nil
    }

    func client(_ client: Client, onRegisterDonationDidFinishWithError error: Error?) {
        // TODO: Schedule another attempt or present user a feedback
    }

    func client(_ client: Client, onRequestDonationChainWithID donationChainID: DonationChainID,
                didCompleteWith donationChainItems: [DonationChainItem]) {
        guard var donationChain = storage.chain(with: donationChainID) else {
            assertionFailure("Donation chain items request completed for an unknown id.")
            return
        }

        donationChain.items = donationChainItems
        storage.saveDonationChain(donationChain)
    }

    func client(_ client: Client, onRequestDonationChainWithID donationChainID: DonationChainID,
                didFinishWithError error: Error?) {
        // TODO: Schedule another attempt or present user a feedback
    }

}