import Foundation

typealias DonationAmount = UInt64
typealias DonationChainID = String

struct Donation {

    let amount: DonationAmount
    let description: String

}

struct DonationChain {

    let donation: Donation
    let identifier: DonationChainID
    let date: TimeStamp
    let items: [DonationChainItem]

}
