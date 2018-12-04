import Foundation

typealias DonationAmount = UInt64
typealias DonationChainID = String

struct Donation: Codable {

    let amount: DonationAmount
    let description: String

}

struct DonationChain: Codable {

    let donation: Donation
    let identifier: DonationChainID
    var date: TimeStamp?

    var items: [DonationChainItem] {
        didSet {
            guard let firstItem = items.first else {
                return
            }

            date = firstItem.date
        }
    }

    init(donation: Donation,
         identifier: DonationChainID,
         date: TimeStamp? = nil,
         items: [DonationChainItem] = []) {
        self.donation = donation
        self.identifier = identifier
        self.date = date
        self.items = items
    }

}
