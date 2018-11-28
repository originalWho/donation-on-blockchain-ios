import UIKit

protocol DonationChainsListView: AnyObject {

    func update(with donationChains: [DonationChain])

    func showDonationChainFullInfo(for identifier: DonationChainID)
    func hideDonationChainFullInfo(for identifier: DonationChainID)

    func showRegisterDonationForm()
    func hideRegisterDonationForm()

    func showDonationRegistrationProcessing()
    func showDonationRegistrationProcessingDone()

}

protocol DonationChainsListViewEventHandler: AnyObject {

    func onDonationChainsUpdateRequested()

    func onDonationChainShowFullInfoRequested(for identifier: DonationChainID)
    func onDonationChainHideFullInfoRequested(for identifier: DonationChainID)

    func onShowRegisterDonationFormButtonPressed()
    func onRegisterDonationButtonPressed(amount: String, description: String)
    func onHideRegisterDonationFormButtonPressed()

}

final class DonationChainsListViewImpl: UIViewController {

    // MARK: - Private types

    private enum State {
        case `default`
        case donationFormVisible
        case donationFormProcessing
        case donationFormDone
    }

    // MARK: - Internal static properties

    static func makeView() -> DonationChainsListViewImpl {
        // TODO: Instantiate from Storyboard
        return DonationChainsListViewImpl()
    }

    // MARK: - Internal properties

    weak var eventHandler: DonationChainsListViewEventHandler?

    // MARK: - Private properties

    private var donationChains: [DonationChain] = []
    private var expandedDonationChainsIDs: Set<DonationChainID> = []

    private var state: State = .default {
        willSet {
            validateStateTransition(from: state, to: newValue)
        }
        didSet {
            handleStateTransition(from: oldValue, to: state)
        }
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var dimmerView: UIView!

    @IBOutlet private weak var registerFormContainerStackView: UIStackView!
    @IBOutlet private weak var registerFormContainerView: UIView!
    @IBOutlet private weak var registerDoneTitleLabel: UILabel!
    @IBOutlet private weak var registerDoneDescriptionLabel: UILabel!
    @IBOutlet private weak var donationAmountTextField: UITextField!
    @IBOutlet private weak var donationDescriptionTextView: UITextView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet private weak var donateButtonContainerView: UIView!
    @IBOutlet private weak var donateButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!

    // MARK: - Internal methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialViewConfiguration()
    }

    // MARK: - Private methods

    private func setInitialViewConfiguration() {
        dimmerView.alpha = 0.0
        registerFormContainerView.isHidden = true
        registerDoneTitleLabel.isHidden = true
        registerDoneDescriptionLabel.isHidden = true
        activityIndicator.isHidden = true
        cancelButton.isHidden = true
    }

    private func validateStateTransition(from oldState: State, to newState: State) {
        switch (oldState, newState) {
        case (.default, .donationFormVisible),
             (.donationFormVisible, .default),
             (.donationFormVisible, .donationFormProcessing),
             (.donationFormProcessing, .donationFormDone),
             (.donationFormDone, .default):
            return

        default:
            assertionFailure("Invalid state transition from \(oldState) to \(newState)")
        }
    }

    private func handleStateTransition(from oldState: State, to newState: State) {
        switch (oldState, newState) {
        case (.default, .donationFormVisible):
            return

        case (.donationFormVisible, .default):
            return

        case (.donationFormVisible, .donationFormProcessing):
            return

        case (.donationFormProcessing, .donationFormDone):
            return

        case (.donationFormDone, .default):
            return

        default:
            return
        }
    }

}

// MARK: - DonationChainsListView protocol

extension DonationChainsListViewImpl: DonationChainsListView {

    func showDonationChainFullInfo(for identifier: DonationChainID) {

    }

    func hideDonationChainFullInfo(for identifier: DonationChainID) {

    }

    func showRegisterDonationForm() {

    }

    func hideRegisterDonationForm() {

    }

    func showDonationRegistrationProcessing() {

    }

    func showDonationRegistrationProcessingDone() {

    }
    
}

// MARK: - UITableViewDataSource protocol

extension DonationChainsListViewImpl: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return donationChains.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let donationChain = donationChains[section]
        return expandedDonationChainsIDs.contains(donationChain.identifier)
            ? 1 + donationChain.items.count
            : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isDonationChainCell = (indexPath.item == 0)

        if isDonationChainCell {
            return donationChainTableViewCell(at: indexPath, in: tableView)
        }
        else {
            return donationChainItemTableViewCell(at: indexPath, in: tableView)
        }
    }

    private func donationChainTableViewCell(at indexPath: IndexPath, in tableView: UITableView) -> DonationChainTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DonationChainTableViewCell.identifier, for: indexPath) as! DonationChainTableViewCell
        return cell
    }

    private func donationChainItemTableViewCell(at indexPath: IndexPath, in tableView: UITableView) -> DonationChainItemTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DonationChainItemTableViewCell.identifier, for: indexPath) as! DonationChainItemTableViewCell
        return cell
    }

}

// MARK: - UITableViewDelegate protocol

extension DonationChainsListViewImpl: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isDonationChainCell = (indexPath.item == 0)
        guard isDonationChainCell else {
            return
        }

        let donationChainID = donationChains[indexPath.section].identifier
        if expandedDonationChainsIDs.contains(donationChainID) {
            expandedDonationChainsIDs.remove(donationChainID)
        }
        else {
            expandedDonationChainsIDs.insert(donationChainID)
        }
    }

}
