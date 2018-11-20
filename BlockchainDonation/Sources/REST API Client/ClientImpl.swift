import Foundation

final class ClientImpl: Client {

    // MARK: - Internal properties

    weak var delegate: ClientDelegate?

    // MARK: - Private properties

    private lazy var accountID: AccountID = {
        let possibleAccountIDs: [AccountID] = [
            "10000000000000000001",
            "10000000000000000002",
            "10000000000000000003",
            "10000000000000000004"
        ]

        return possibleAccountIDs.randomElement()!
    }()

    private lazy var apiBaseURL: URL = {
        guard let apiBaseURL = URL(string: "http://game.springtale.ru:3999") else {
            fatalError("Invalid URL string passed in.")
        }

        return apiBaseURL
    }()

    private let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "ClientImplOperationQueue.\(UUID().uuidString)"
        operationQueue.qualityOfService = .utility
        return operationQueue
    }()

    // MARK: - Internal methods

    func registerDonation(_ donation: Donation) {
        let registerDonationOperation = RegisterDonationOperation(amount: donation.amount,
                                                                  donationDescription: donation.description,
                                                                  accountID: accountID,
                                                                  baseURL: apiBaseURL)

        let registerDonationCompletionOperation = BlockOperation { [weak self] in
            guard let `self` = self else { return }

            guard let result = registerDonationOperation.result else {
                // TODO: Specify error
                self.delegate?.client(self, onRegisterDonationDidFinishWithError: nil)
                return
            }

            guard result.requestResponse == .success else {
                // TODO: Specify error
                self.delegate?.client(self, onRegisterDonationDidFinishWithError: nil)
                return
            }

            self.delegate?.client(self, onRegisterDonationDidCompleteWith: result.donationChainID)
        }

        registerDonationCompletionOperation.addDependency(registerDonationOperation)
        operationQueue.addOperations(registerDonationOperation, registerDonationCompletionOperation)
    }

    func requestDonationChain(with donationChainID: DonationChainID) {
        let getDonationsChainOperation = GetDonationsChainOperation(donationID: donationChainID,
                                                                    baseURL: apiBaseURL)

        let getDonationChainCompletionOperation = BlockOperation { [weak self] in
            guard let `self` = self else { return }

            guard let result = getDonationsChainOperation.result else {
                // TODO: Specify error
                self.delegate?.client(self,
                                      onRequestDonationChainWithID: donationChainID,
                                      didFinishWithError: nil)
                return
            }

            guard result.requestResponse == .success else {
                // TODO: Specify error
                self.delegate?.client(self,
                                      onRequestDonationChainWithID: donationChainID,
                                      didFinishWithError: nil)
                return
            }

            self.delegate?.client(self,
                                  onRequestDonationChainWithID: donationChainID,
                                  didCompleteWith: result.donationChainItems)
        }

        getDonationChainCompletionOperation.addDependency(getDonationsChainOperation)
        operationQueue.addOperations(getDonationsChainOperation, getDonationChainCompletionOperation)
    }

}

// MARK: - Helper methods

private extension OperationQueue {

    /// Returns control immediately to the caller
    func addOperations(_ operations: Operation...) {
        addOperations(operations, waitUntilFinished: false)
    }

}
