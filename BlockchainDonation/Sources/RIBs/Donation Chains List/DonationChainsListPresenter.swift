import Foundation

protocol DonationChainsListPresenter: AnyObject {

    func onRegisterDonationDidComplete()
    func onRegisterDonationDidFinish(with error: Error?)
    func onRequestDonationChainsDidComplete()
    func onRequestDonationChainsDidFinish(with error: Error?)

}

final class DonationChainsListPresenterImpl {

    weak var interactor: DonationChainsListInteractor?
    weak var view: DonationChainsListView?

}

extension DonationChainsListPresenterImpl: DonationChainsListPresenter {

    func onRegisterDonationDidComplete() {

    }

    func onRegisterDonationDidFinish(with error: Error?) {

    }

    func onRequestDonationChainsDidComplete() {

    }

    func onRequestDonationChainsDidFinish(with error: Error?) {

    }

}

extension DonationChainsListPresenterImpl: DonationChainsListViewEventHandler {

    func onDonationChainShowFullInfoRequested(for identifier: DonationChainID) {
        
    }

    func onDonationChainHideFullInfoRequested(for identifier: DonationChainID) {

    }

    func onShowRegisterDonationFormButtonPressed() {

    }

    func onRegisterDonationButtonPressed() {

    }

    func onHideRegisterDonationFormButtonPressed() {

    }
    
}
