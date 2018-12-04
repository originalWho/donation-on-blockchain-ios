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

    private let collapsedStateNumberOfLines = 2

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10.0
        transactionNumberContainerView.layer.cornerRadius = transactionNumberContainerView.bounds.width * 0.5
    }

    func configure(with donationChain: DonationChain, for state: State) {
        donationAmountLabel.text = "$\(donationChain.donation.amount)"
        descriptionLabel.text = donationChain.donation.description

        descriptionLabel.lineBreakMode = (state == .collapsed) ? .byClipping : .byWordWrapping
        descriptionLabel.numberOfLines = (state == .collapsed) ? collapsedStateNumberOfLines : 0

        timestampLabel.text = (state == .collapsed) ? nil : donationChain.date

        if let lastDonationItemBalance = donationChain.items.last?.balance {
            donationRemainingAmountLabel.text = (lastDonationItemBalance == 0)
            ? "(expended)"
            : "($\(lastDonationItemBalance) left)"
        }
        else {
            donationRemainingAmountLabel.text = nil
        }

        transactionNumberLabel.text = "\(donationChain.items.count)"

        transactionNumberLabel.textColor = (state == .collapsed)
            ? .white
            : containerView.backgroundColor
        transactionNumberContainerView.backgroundColor = (state == .collapsed)
            ? UIColor(white: 1.0, alpha: 0.3)
            : UIColor(white: 1.0, alpha: 1.0)
    }

}
