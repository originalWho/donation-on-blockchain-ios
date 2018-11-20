import Foundation

typealias TransitionID = UInt32
typealias TaxID = String
typealias AccountID = String
typealias TimeStamp = String

struct DonationChainItem: Codable {

    let balance: DonationAmount
    let date: TimeStamp
    let description: String
    let transitionID: TransitionID
    let amount: DonationAmount
    let transitionDate: TimeStamp
    let purpose: String
    let accountID: AccountID
    let taxID: TaxID
    let organizationName: String

    private enum CodingKeys: String, CodingKey {
        case balance
        case date = "timeStamp"
        case description
        case transitionID = "stepId"
        case amount
        case transitionDate = "transitionTime"
        case purpose
        case accountID = "accountNumber"
        case taxID = "taxId"
        case organizationName
    }

}
