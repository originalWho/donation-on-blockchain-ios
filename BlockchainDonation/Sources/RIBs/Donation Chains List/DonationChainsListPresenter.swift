import Foundation

protocol DonationChainsListPresenter: AnyObject {
    
}

final class DonationChainsListPresenterImpl: DonationChainsListPresenter {

    weak var interactor: DonationChainsListInteractor?
    weak var view: DonationChainsListView?
    
}

extension DonationChainsListPresenterImpl: DonationChainsListViewEventHandler {
    
}
