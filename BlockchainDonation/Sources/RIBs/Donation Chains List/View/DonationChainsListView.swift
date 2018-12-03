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
        let storyboard = UIStoryboard(name: "DonationChainsList", bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: DonationChainsListViewImpl.identifier) as! DonationChainsListViewImpl
    }

    // MARK: - Internal properties

    weak var eventHandler: DonationChainsListViewEventHandler?

    // MARK: - Private properties

    private var donationChains: [DonationChain] = []
    private var expandedDonationChainsIDs: Set<DonationChainID> = []

    private var state: State = .default {
        didSet {
            guard oldValue != state else {
                return
            }

            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.handleStateTransition(from: oldValue, to: self.state)
            }
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
        configureRefreshControl()
        setInitialViewConfiguration()
        setDefaultViewConfiguration()
    }

    // MARK: - Private methods

    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(onRefreshControlValueChanged(_:)),
                                 for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setInitialViewConfiguration() {
        donationAmountTextField.placeholder = "How much?"
//        donationDescriptionTextView.place
    }

    private func setDefaultViewConfiguration() {
        dimmerView.alpha = 0.0
        donationAmountTextField.isEnabled = true
        donationDescriptionTextView.isEditable = true
        registerFormContainerView.isHidden = true
        donationAmountTextField.isHidden = false
        donationDescriptionTextView.isHidden = false
        registerDoneTitleLabel.isHidden = true
        registerDoneDescriptionLabel.isHidden = true
        activityIndicator.isHidden = true
        cancelButton.isHidden = true

        donateButton.setTitle("Donate", for: .normal)
    }

    private func handleStateTransition(from oldState: State, to newState: State) {
        switch (oldState, newState) {
        case (.default, .donationFormVisible):
            dimmerView.alpha = 1.0
            registerFormContainerView.isHidden = false
            cancelButton.isHidden = false
            donateButton.isEnabled = false
            donateButton.setTitle("Send", for: .normal)

        case (.donationFormVisible, .default):
            setDefaultViewConfiguration()

        case (.donationFormVisible, .donationFormProcessing):
            donationAmountTextField.isEnabled = false
            donationDescriptionTextView.isEditable = false
            activityIndicator.isHidden = false
            cancelButton.isHidden = true
            donateButton.isEnabled = false

        case (.donationFormProcessing, .donationFormDone):
            donationAmountTextField.isHidden = true
            donationDescriptionTextView.isHidden = true
            registerDoneTitleLabel.isHidden = false
            registerDoneDescriptionLabel.isHidden = false
            activityIndicator.isHidden = true
            donateButton.isEnabled = true
            donateButton.setTitle("Done", for: .normal)

        case (.donationFormDone, .default):
            setDefaultViewConfiguration()

        default:
            assertionFailure("Invalid state transition from \(oldState) to \(newState)")
            return
        }

        registerFormContainerStackView.layoutIfNeeded()
    }

    @objc private func onRefreshControlValueChanged(_ sender: UIRefreshControl) {
        eventHandler?.onDonationChainsUpdateRequested()
    }

    @IBAction private func onDonateButtonPressed(_ sender: UIButton) {
        switch state {
        case .default:
            eventHandler?.onShowRegisterDonationFormButtonPressed()

        case .donationFormVisible:
            guard 
                let amount = donationAmountTextField.text, !amount.isEmpty,
                let description = donationDescriptionTextView.text, !description.isEmpty
            else {
                return
            }

            eventHandler?.onRegisterDonationButtonPressed(amount: amount, description: description)

        case .donationFormProcessing:
            assertionFailure("Button should not be enabled in this state")

        case .donationFormDone:
            eventHandler?.onHideRegisterDonationFormButtonPressed()
        }
    }

    @IBAction private func onCancelButtonPressed(_ sender: UIButton) {
        switch state {
        case .default, .donationFormProcessing, .donationFormDone:
            assertionFailure("Button should not be available in this state")

        case .donationFormVisible:
            eventHandler?.onHideRegisterDonationFormButtonPressed()
        }
    }

}

// MARK: - DonationChainsListView protocol

extension DonationChainsListViewImpl: DonationChainsListView {

    func update(with donationChains: [DonationChain]) {
        self.donationChains = donationChains
        tableView.reloadData() // TODO: Switch to animated updates
        tableView.refreshControl?.endRefreshing()
    }

    func showDonationChainFullInfo(for identifier: DonationChainID) {
        expandedDonationChainsIDs.insert(identifier)
        tableView.reloadData() // TODO: Switch to animated updates
    }

    func hideDonationChainFullInfo(for identifier: DonationChainID) {
        expandedDonationChainsIDs.remove(identifier)
        tableView.reloadData() // TODO: Switch to animated updates
    }

    func showRegisterDonationForm() {
        state = .donationFormVisible
    }

    func hideRegisterDonationForm() {
        state = .default
    }

    func showDonationRegistrationProcessing() {
        state = .donationFormProcessing
    }

    func showDonationRegistrationProcessingDone() {
        state = .donationFormDone
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
            eventHandler?.onDonationChainHideFullInfoRequested(for: donationChainID)
        }
        else {
            eventHandler?.onDonationChainShowFullInfoRequested(for: donationChainID)
        }
    }

}
