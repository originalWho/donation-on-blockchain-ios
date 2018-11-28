import Foundation

protocol DonationChainsListInteractor: Interactor {

    func registerDonation(_ donation: Donation)
    func requestDonationChains()

}

final class DonationChainsListInteractorImpl: Interactor {

    var canRegisterDonation: Bool {
        return pendingDonation == nil
    }

    var canRequestDonationChains: Bool {
        return requestedDonationChainsIDs.isEmpty
    }

    private let client: Client
    private let storage: DonationChainStorage
    private let presenter: DonationChainsListPresenter

    private var pendingDonation: Donation?
    private var requestedDonationChainsIDs: Set<DonationChainID> = []

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
    
}

extension DonationChainsListInteractorImpl: DonationChainsListInteractor {

    func registerDonation(_ donation: Donation) {
        guard canRegisterDonation else {
            return
        }

        pendingDonation = donation
        client.registerDonation(donation)
    }

    func requestDonationChains() {
        guard canRequestDonationChains else {
            return
        }

        requestedDonationChainsIDs = Set(storage.chainsIdentifiers)
        requestedDonationChainsIDs.forEach { client.requestDonationChain(with: $0) }
    }

}

extension DonationChainsListInteractorImpl: ClientDelegate {

    func client(_ client: Client, onRegisterDonationDidCompleteWith donationChainID: DonationChainID) {
        guard let pendingDonation = pendingDonation else {
            assertionFailure("Pending donation is nil, yet a donation has been registered.")
            return
        }

        let donationChain = DonationChain(donation: pendingDonation,
                                          identifier: donationChainID)
        storage.saveDonationChain(donationChain)
        self.pendingDonation = nil

        presenter.onRegisterDonationDidComplete()
    }

    func client(_ client: Client, onRegisterDonationDidFinishWithError error: Error?) {
        // TODO: Schedule another attempt or present user a feedback
        presenter.onRegisterDonationDidFinish(with: error)
    }

    func client(_ client: Client, onRequestDonationChainWithID donationChainID: DonationChainID,
                didCompleteWith donationChainItems: [DonationChainItem]) {
        guard var donationChain = storage.chain(with: donationChainID) else {
            assertionFailure("Donation chain items request completed for an unknown id.")
            return
        }

        donationChain.items = donationChainItems
        storage.saveDonationChain(donationChain)
        requestedDonationChainsIDs.remove(donationChainID)

        if requestedDonationChainsIDs.isEmpty {
            presenter.onRequestDonationChainsDidComplete(with: storage.chains)
        }
    }

    func client(_ client: Client, onRequestDonationChainWithID donationChainID: DonationChainID,
                didFinishWithError error: Error?) {
        // TODO: Schedule another attempt or present user a feedback
        presenter.onRequestDonationChainsDidFinish(with: error)
    }

}
