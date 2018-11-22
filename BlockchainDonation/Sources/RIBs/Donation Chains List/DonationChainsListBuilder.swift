import Foundation

struct DonationChainsListBuilder: Builder {

    struct Component {
        let client: Client
        let storage: DonationChainStorage
    }

    private let componentFactory: DonationChainsListComponentFactory

    init(componentFactory: DonationChainsListComponentFactory) {
        self.componentFactory = componentFactory
    }

    func build() -> Router {
        let component = componentFactory.makeComponent()

        let view = DonationChainsListViewImpl.makeView()
        let presenter = DonationChainsListPresenterImpl()
        let interactor = DonationChainsListInteractorImpl(presenter: presenter,
                                                          client: component.client,
                                                          storage: component.storage)
        let router = DonationChainsListRouterImpl(interactor: interactor, viewController: view)

        view.eventHandler = presenter
        presenter.view = view
        presenter.interactor = interactor

        return router
    }

}

protocol DonationChainsListComponentFactory: AnyObject {

    func makeComponent() -> DonationChainsListBuilder.Component

}
