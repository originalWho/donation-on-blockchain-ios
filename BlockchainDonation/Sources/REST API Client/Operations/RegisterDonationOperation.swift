import Foundation

private struct RegisterDonationResponse: Codable {
    let key: String
    let result: Int
}

final class RegisterDonationOperation: AsyncOperation {

    // MARK: - Internal properties

    var donationID: String?

    // MARK: - Private properties

    private let amount: Double
    private let donationDescription: String
    private let accountID: Int

    private let urlSession: URLSession
    private let baseURL: URL

    private var registerDonationMethodURL: URL? {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }

        urlComponents.path = "/registardonate"
        urlComponents.queryItems = [
            URLQueryItem(name: "amount", value: "\(amount)"),
            URLQueryItem(name: "description", value: donationDescription),
            URLQueryItem(name: "accountNumber", value: "\(accountID)")
        ]

        return urlComponents.url
    }

    // MARK: - Init

    init(amount: Double, donationDescription: String, accountID: Int, baseURL: URL, urlSession: URLSession = .shared) {
        self.amount = amount
        self.donationDescription = donationDescription
        self.accountID = accountID
        self.baseURL = baseURL
        self.urlSession = urlSession
        super.init()
    }

    // MARK: - Internal methods

    override func main() {
        guard let registerDonationMethodURL = registerDonationMethodURL else {
            assertionFailure("Could not get a valid URL for donations chain registration")
            state = .isFinished
            return
        }

        guard !isCancelled else { return }

        let registerDonationTask = urlSession.dataTask(with: registerDonationMethodURL) { [weak self] data, response, error in
            self?.handleTaskCompletion(data: data, response: response as? HTTPURLResponse, error: error)
        }

        guard !isCancelled else { return }

        registerDonationTask.resume()
    }

    // MARK: - Private methods

    private func handleTaskCompletion(data: Data?, response: HTTPURLResponse?, error: Error?) {
        guard !isCancelled else { return }

        defer {
            state = .isFinished
        }

        guard error == nil else {
            NSLog("Failed to register donation. Error: \(String(describing: error?.localizedDescription))")
            return
        }

        guard response?.isSuccessful ?? false else {
            NSLog("Failed to register donation. Status code: \(String(describing: response?.statusCode))")
            return
        }

        guard let data = data else {
            NSLog("Failed to register donation. Data is nil.")
            return
        }

        do {
            let jsonDecoder = JSONDecoder()
            let registerDonationResponse = try jsonDecoder.decode(RegisterDonationResponse.self, from: data)
            donationID = registerDonationResponse.key
        }
        catch {
            NSLog("Could not parse data and cast it to type:\(RegisterDonationResponse.self). Error: \(error.localizedDescription)")
        }
    }

}
