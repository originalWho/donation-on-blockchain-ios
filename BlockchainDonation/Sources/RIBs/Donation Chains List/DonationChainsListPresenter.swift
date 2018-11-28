import Foundation

protocol DonationChainsListPresenter: AnyObject {

    func onRegisterDonationDidComplete()
    func onRegisterDonationDidFinish(with error: Error?)
    func onRequestDonationChainsDidComplete(with donationChains: [DonationChain])
    func onRequestDonationChainsDidFinish(with error: Error?)

}

final class DonationChainsListPresenterImpl {

    weak var interactor: DonationChainsListInteractor?
    weak var view: DonationChainsListView?

}

// MARK: - DonationChainsListPresenter protocol

extension DonationChainsListPresenterImpl: DonationChainsListPresenter {

    func onRegisterDonationDidComplete() {
        view?.showDonationRegistrationProcessingDone()
    }

    func onRegisterDonationDidFinish(with error: Error?) {
        // TODO: Implement
    }

    func onRequestDonationChainsDidComplete(with donationChains: [DonationChain]) {
        view?.update(with: donationChains)
    }

    func onRequestDonationChainsDidFinish(with error: Error?) {
        // TODO: Implement
    }

}

// MARK: - DonationChainsListViewEventHandler protocol

extension DonationChainsListPresenterImpl: DonationChainsListViewEventHandler {

    func onDonationChainsUpdateRequested() {
        interactor?.requestDonationChains()
    }

    func onDonationChainShowFullInfoRequested(for identifier: DonationChainID) {
        view?.showDonationChainFullInfo(for: identifier)
    }

    func onDonationChainHideFullInfoRequested(for identifier: DonationChainID) {
        view?.hideDonationChainFullInfo(for: identifier)
    }

    func onShowRegisterDonationFormButtonPressed() {
        view?.showRegisterDonationForm()
    }

    func onRegisterDonationButtonPressed(amount: String, description: String) {
        guard let amount = UInt64(amount) else {
            return
        }

        view?.showDonationRegistrationProcessing()

        let donation = Donation(amount: amount, description: description)
        interactor?.registerDonation(donation)
    }

    func onHideRegisterDonationFormButtonPressed() {
        view?.hideRegisterDonationForm()
    }
    
}
