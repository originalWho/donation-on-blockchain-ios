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

    func onViewDidLoad()

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

    private let containerStackViewBottomConstraintConstant: CGFloat = 30.0

    private var isEditingDescription: Bool = false

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

    @IBOutlet private weak var containerStackViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Internal methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        setInitialViewConfiguration()
        setDefaultViewConfiguration()

        tableView.sectionHeaderHeight = .leastNormalMagnitude
        tableView.estimatedSectionHeaderHeight = .leastNormalMagnitude
        tableView.sectionFooterHeight  = .leastNormalMagnitude
        tableView.estimatedSectionFooterHeight = .leastNormalMagnitude

        donationDescriptionTextView.delegate = self
        eventHandler?.onViewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureLayers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeForNotifications()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeForNotifications()
    }

    // MARK: - Private methods

    private func configureLayers() {
        registerFormContainerView.layer.cornerRadius = 16.0
        registerFormContainerView.layer.shadowOpacity = 0.3
        registerFormContainerView.layer.shadowRadius = 12.0
        registerFormContainerView.layer.shadowOffset = CGSize(width: 6.0, height: 6.0)
        registerFormContainerView.layer.shadowColor = UIColor.black.cgColor

        donateButtonContainerView.layer.cornerRadius = 8.0
        donateButtonContainerView.layer.shadowOpacity = 0.3
        donateButtonContainerView.layer.shadowRadius = 8.0
        donateButtonContainerView.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        donateButtonContainerView.layer.shadowColor = UIColor.black.cgColor
    }

    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(onRefreshControlValueChanged(_:)),
                                 for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setInitialViewConfiguration() {
        donationAmountTextField.placeholder = "How much?"
    }

    private func setDefaultViewConfiguration() {
        dimmerView.alpha = 0.0
        donationAmountTextField.text = nil
        donationAmountTextField.isEnabled = true
        donationAmountTextField.resignFirstResponder()
        donationDescriptionTextView.text = "Why?"
        donationDescriptionTextView.textColor = .lightGray
        donationDescriptionTextView.isEditable = true
        donationDescriptionTextView.resignFirstResponder()
        registerFormContainerView.isHidden = true
        donationAmountTextField.isHidden = false
        donationDescriptionTextView.isHidden = false
        registerDoneTitleLabel.isHidden = true
        registerDoneDescriptionLabel.isHidden = true
        activityIndicator.isHidden = true
        cancelButton.isHidden = true
        donateButton.isEnabled = true
        donateButton.setTitle("Donate", for: .normal)
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        isEditingDescription = false
    }

    private func handleStateTransition(from oldState: State, to newState: State) {
        switch (oldState, newState) {
        case (.default, .donationFormVisible):
            dimmerView.alpha = 1.0
            registerFormContainerView.isHidden = false
            cancelButton.isHidden = false
//            donateButton.isEnabled = false
            donateButton.setTitle("Send", for: .normal)

        case (.donationFormVisible, .default):
            setDefaultViewConfiguration()

        case (.donationFormVisible, .donationFormProcessing):
            donationAmountTextField.isEnabled = false
            donationDescriptionTextView.isEditable = false
            activityIndicator.isHidden = false
            cancelButton.isHidden = true
            donateButton.isEnabled = false
            donationAmountTextField.resignFirstResponder()
            donationDescriptionTextView.resignFirstResponder()
            donateButton.setTitle("Sending...", for: .normal)
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false

        case (.donationFormProcessing, .donationFormDone):
            donationAmountTextField.isHidden = true
            donationDescriptionTextView.isHidden = true
            registerDoneTitleLabel.isHidden = false
            registerDoneDescriptionLabel.isHidden = false
            activityIndicator.isHidden = true
            donateButton.isEnabled = true
            donateButton.setTitle("Done", for: .normal)
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true

        case (.donationFormDone, .default):
            setDefaultViewConfiguration()

        default:
            assertionFailure("Invalid state transition from \(oldState) to \(newState)")
            return
        }

        registerFormContainerStackView.layoutIfNeeded()
    }

    private func subscribeForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillShow(with:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillHide(with:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyboardWillChangeFrame(with:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    private func unsubscribeForNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    private func adjustContainerStackViewPosition(with notification: Notification, for keyboardWillShow: Bool) {
        guard
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else {
            return
        }

        let multiplier: CGFloat = keyboardWillShow ? 1.0 : 0.0
        let keyboardHeight = multiplier * keyboardFrame.height
        let constraintConstant = containerStackViewBottomConstraintConstant + keyboardHeight

        UIView.animate(withDuration: animationDuration) { [unowned self] in
            self.containerStackViewBottomConstraint.constant = constraintConstant
            self.view.layoutIfNeeded()
        }
    }

    private func updateDonationChain(with identifier: DonationChainID, shouldExpand: Bool) {
        guard let index = donationChains.firstIndex(where: { $0.identifier == identifier }) else {
            return
        }

        let batchUpdates: () -> Void = { [unowned self] in
            let itemsCount = self.donationChains[index].items.count
            let indexPaths: [IndexPath] = (1...itemsCount).map { IndexPath(row: $0, section: index) }

            self.tableView.reloadRows(at: [IndexPath(row: 0, section: index)], with: .fade)
            if shouldExpand {
                self.tableView.insertRows(at: indexPaths, with: .middle)
            }
            else {
                self.tableView.deleteRows(at: indexPaths, with: .middle)
            }
        }

        tableView.performBatchUpdates(batchUpdates)
    }

    // MARK: - Actions

    @objc private func onKeyboardWillShow(with notification: Notification) {
        adjustContainerStackViewPosition(with: notification, for: true)
    }

    @objc private func onKeyboardWillHide(with notification: Notification) {
        adjustContainerStackViewPosition(with: notification, for: false)
    }

    @objc private func onKeyboardWillChangeFrame(with notification: Notification) {
        adjustContainerStackViewPosition(with: notification, for: false)
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
        updateDonationChain(with: identifier, shouldExpand: true)
    }

    func hideDonationChainFullInfo(for identifier: DonationChainID) {
        expandedDonationChainsIDs.remove(identifier)
        updateDonationChain(with: identifier, shouldExpand: false)
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

        let donationChain = donationChains[indexPath.section]
        let state: DonationChainTableViewCell.State = expandedDonationChainsIDs.contains(donationChain.identifier) ? .expanded : .collapsed
        cell.configure(with: donationChain, for: state)

        return cell
    }

    private func donationChainItemTableViewCell(at indexPath: IndexPath, in tableView: UITableView) -> DonationChainItemTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DonationChainItemTableViewCell.identifier, for: indexPath) as! DonationChainItemTableViewCell

        let donationChainItem = donationChains[indexPath.section].items[indexPath.row - 1]
        cell.configure(with: donationChainItem)

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

extension DonationChainsListViewImpl: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard !isEditingDescription else {
            return
        }

        textView.text = nil
        textView.textColor = .black
        isEditingDescription = true
    }

}
