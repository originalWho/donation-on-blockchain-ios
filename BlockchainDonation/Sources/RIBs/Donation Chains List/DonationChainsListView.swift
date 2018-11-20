import UIKit

protocol DonationChainsListView: AnyObject {
    
}

protocol DonationChainsListViewEventHandler: AnyObject {

}

final class DonationChainsListViewImpl: UIViewController, DonationChainsListView {

    static func makeView() -> DonationChainsListViewImpl {
        // TODO: Instantiate from Storyboard
        return DonationChainsListViewImpl()
    }

    weak var eventHandler: DonationChainsListViewEventHandler?
    
}
