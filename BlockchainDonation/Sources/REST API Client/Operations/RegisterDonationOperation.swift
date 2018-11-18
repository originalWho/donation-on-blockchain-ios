import Foundation

struct RegisterDonationResponse: Codable {

    let requestResponse: RequestResponse
    let donationID: String

    private enum CodingKeys: String, CodingKey {
        case requestResponse = "result"
        case donationID = "key"
    }

}

final class RegisterDonationOperation: AsyncOperation {

    // MARK: - Internal properties

    var result: RegisterDonationResponse?

    // MARK: - Private properties

    private let amount: DonationAmount
    private let donationDescription: String
    private let accountID: AccountID

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

    init(amount: DonationAmount, donationDescription: String, accountID: AccountID, baseURL: URL, urlSession: URLSession = .shared) {
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
            result = try jsonDecoder.decode(RegisterDonationResponse.self, from: data)
        }
        catch {
            NSLog("Could not parse data and cast it to type:\(RegisterDonationResponse.self). Error: \(error)")
        }
    }

}
