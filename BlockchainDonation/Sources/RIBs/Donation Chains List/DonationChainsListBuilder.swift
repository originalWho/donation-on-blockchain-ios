import Foundation

struct DonationChainsListBuilder {

    struct Component {
        let client: Client
    }

    private let componentFactory: DonationChainsListComponentFactory

    init(componentFactory: DonationChainsListComponentFactory) {
        self.componentFactory = componentFactory
    }

    func build() -> DonationChainsListRouter {
        let component = componentFactory.makeComponent()

        let view = DonationChainsListViewImpl.makeView()
        let presenter = DonationChainsListPresenterImpl()
        let interactor = DonationChainsListInteractorImpl(presenter: presenter,
                                                          client: component.client)
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
