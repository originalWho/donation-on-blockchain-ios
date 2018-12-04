import Foundation

protocol DonationChainStorage: AnyObject {

    var isEmpty: Bool { get }
    var chains: [DonationChain] { get }
    var chainsIdentifiers: [DonationChainID] { get }

    func chain(with identifier: DonationChainID) -> DonationChain?
    func saveDonationChain(_ donationChain: DonationChain)

}

final class DonationChainStorageImpl: DonationChainStorage {

    private typealias InternalStorage = [DonationChainID: DonationChain]

    var isEmpty: Bool {
        var isInternalStorageEmpty: Bool = false
        syncQueue.sync { [unowned self] in
            isInternalStorageEmpty = self.internalStorage.isEmpty
        }
        return isInternalStorageEmpty
    }

    var chains: [DonationChain] {
        var chains: [DonationChain] = []
        syncQueue.sync { [unowned self] in
            chains = Array(self.internalStorage.values)
        }
        return chains
    }

    var chainsIdentifiers: [DonationChainID] {
        var identifiers: [DonationChainID] = []
        syncQueue.sync { [unowned self] in
            identifiers = Array(self.internalStorage.keys)
        }
        return identifiers
    }

    private var internalStorage: InternalStorage = [:]

    private lazy var syncQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "DonationChainStorageImplDispatchQueue.\(UUID().uuidString)",
            attributes: .concurrent)
        return queue
    }()

    init() {
        guard let internalStorage = restorePersistentInternalStorage() else {
            return
        }

        self.internalStorage = internalStorage
    }

    func chain(with identifier: DonationChainID) -> DonationChain? {
        var donationChain: DonationChain?
        syncQueue.sync { [unowned self] in
            donationChain = self.internalStorage[identifier]
        }
        return donationChain
    }

    func saveDonationChain(_ donationChain: DonationChain) {
        syncQueue.async(flags: .barrier) { [unowned self] in
            self.internalStorage[donationChain.identifier] = donationChain
            self.saveInternalStoragePersistently()
        }
    }

    private func restorePersistentInternalStorage() -> InternalStorage? {
        guard let data = UserDefaults.standard.data(forKey: .internalStorageKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        let decodedStorage = try? decoder.decode(InternalStorage.self, from: data)
        return decodedStorage
    }

    private func saveInternalStoragePersistently() {
        let encoder = JSONEncoder()
        let encodedStorage = try? encoder.encode(internalStorage)
        UserDefaults.standard.set(encodedStorage, forKey: .internalStorageKey)
    }

}

private extension String {

    static var internalStorageKey: String {
        return "internalStorageKey"
    }

}
