import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var servicesProvider: ServicesProvider?
    private var donationChainsListRouter: ViewableRouter?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let servicesProvider = createServicesProvider()
        attachDonationChainsList(with: servicesProvider)

        self.servicesProvider = servicesProvider

        return true
    }

    private func createServicesProvider() -> ServicesProvider {
        let client = ClientImpl()
        let storage = DonationChainStorageImpl()
        let servicesContainer = ServicesContainerImpl(client: client, storage: storage)
        return ServicesProvider(container: servicesContainer)
    }

    private func attachDonationChainsList(with servicesProvider: ServicesProvider) {
        let router = DonationChainsListBuilder(componentFactory: servicesProvider).build()

        router.start()
        window?.rootViewController = router.viewController
        window?.makeKeyAndVisible()
        
        donationChainsListRouter = router
    }

}
