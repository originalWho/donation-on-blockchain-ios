import UIKit

final class DonationChainItemTableViewCell: UITableViewCell {

    @IBOutlet private weak var transactionAmountLabel: UILabel!
    @IBOutlet private weak var organizationNameLabel: UILabel!
    @IBOutlet private weak var taxIdLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!

    func configure(with donationChainItem: DonationChainItem) {
        transactionAmountLabel.text = "$\(donationChainItem.amount)"
        organizationNameLabel.text = donationChainItem.organizationName
        taxIdLabel.text = donationChainItem.taxID
        descriptionLabel.text = donationChainItem.purpose
        timestampLabel.text = donationChainItem.transitionDate
        // TODO: configure containerView
    }

}
