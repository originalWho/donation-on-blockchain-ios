import UIKit

final class DonationChainTableViewCell: UITableViewCell {

    enum State {
        case collapsed
        case expanded
    }

    @IBOutlet private weak var donationAmountLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var donationRemainingAmountLabel: UILabel!
    @IBOutlet private weak var transactionNumberContainerView: UIView!
    @IBOutlet private weak var transactionNumberLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!

    func configure(with donationChain: DonationChain, for state: State) {
        donationAmountLabel.text = "$\(donationChain.donation.amount)"
        descriptionLabel.text = donationChain.donation.description
        timestampLabel.text = donationChain.date
        timestampLabel.isHidden = (state == .collapsed)

        if let lastDonationItemBalance = donationChain.items.last?.balance {
            donationRemainingAmountLabel.text = (lastDonationItemBalance == 0)
            ? "(expended)"
            : "($\(lastDonationItemBalance) left)"
        }
        else {
            donationRemainingAmountLabel.text = nil
        }

        transactionNumberLabel.text = "\(donationChain.items.count)"
        // TODO: Configure containerView and transactionNumberContainerView
    }

}
