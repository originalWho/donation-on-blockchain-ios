import Foundation

protocol ServicesContainer {

    var client: Client { get }
    var storage: DonationChainStorage { get }

}

final class ServicesContainerImpl: ServicesContainer {

    let client: Client
    let storage: DonationChainStorage

    init(client: Client, storage: DonationChainStorage) {
        self.client = client
        self.storage = storage
    }

}

final class ServicesProvider {

    private let container: ServicesContainer

    init(container: ServicesContainer) {
        self.container = container
    }

}

extension ServicesProvider: DonationChainsListComponentFactory {

    func makeComponent() -> DonationChainsListBuilder.Component {
        return DonationChainsListBuilder.Component(client: container.client,
                                                   storage: container.storage)
    }

}
