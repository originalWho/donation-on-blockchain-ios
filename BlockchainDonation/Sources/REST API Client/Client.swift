import Foundation

protocol Client: AnyObject {

    var delegate: ClientDelegate? { get set }

    func registerDonation(_ donation: Donation)
    func requestDonationChain(with donationChainID: DonationChainID)

}

protocol ClientDelegate: AnyObject {

    func client(_ client: Client,
                onRegisterDonationDidCompleteWith donationChainID: DonationChainID)
    func client(_ client: Client,
                onRegisterDonationDidFinishWithError error: Error?)
    func client(_ client: Client,
                onRequestDonationChainWithID: DonationChainID,
                didCompleteWith donationChainItems: [DonationChainItem])
    func client(_ client: Client,
                onRequestDonationChainWithID: DonationChainID,
                didFinishWithError error: Error?)

}
