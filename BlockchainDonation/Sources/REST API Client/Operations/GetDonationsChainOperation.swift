import Foundation

struct GetDonationChainResponse: Codable {

    let requestResponse: RequestResponse
    let donations: [Donation]

    private enum CodingKeys: String, CodingKey {
        case requestResponse = "result"
        case donations = "output"
    }

}

final class GetDonationsChainOperation: AsyncOperation {

    // MARK: - Internal properties

    let donationID: String
    var result: GetDonationChainResponse?

    // MARK: - Private properties

    private let urlSession: URLSession
    private let baseURL: URL

    private var getDonationsChainMethodURL: URL? {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }

        urlComponents.path = "/getdonatechain"
        urlComponents.queryItems = [
            URLQueryItem(name: "donateId", value: donationID)
        ]

        return urlComponents.url
    }

    // MARK: - Init

    init(donationID: String, baseURL: URL, urlSession: URLSession = .shared) {
        self.donationID = donationID
        self.baseURL = baseURL
        self.urlSession = urlSession
        super.init()
    }

    // MARK: - Internal methods

    override func main() {
        guard let getDonationsChainMethodURL = getDonationsChainMethodURL else {
            assertionFailure("Could not get a valid URL for donations chain retrieval")
            state = .isFinished
            return
        }

        guard !isCancelled else { return }

        let getDonationsChainTask = urlSession.dataTask(with: getDonationsChainMethodURL) { [weak self] data, response, error in
            self?.handleTaskCompletion(data: data, response: response as? HTTPURLResponse, error: error)
        }

        guard !isCancelled else { return }

        getDonationsChainTask.resume()
    }

    // MARK: - Private methods

    private func handleTaskCompletion(data: Data?, response: HTTPURLResponse?, error: Error?) {
        guard !isCancelled else { return }

        defer {
            state = .isFinished
        }

        guard error == nil else {
            NSLog("Failed to get donations chain. Error: \(String(describing: error?.localizedDescription))")
            return
        }

        guard response?.isSuccessful ?? false else {
            NSLog("Failed to get donations chain. Status code: \(String(describing: response?.statusCode))")
            return
        }

        guard let data = data else {
            NSLog("Failed to get donations chain. Data is nil.")
            return
        }

        do {
            let jsonDecoder = JSONDecoder()
            result = try jsonDecoder.decode(GetDonationChainResponse.self, from: data)
        }
        catch {
            NSLog("Could not parse data and cast it to type:\(GetDonationChainResponse.self). Error: \(error)")
        }
    }

}

extension HTTPURLResponse {

    var isSuccessful: Bool {
        return statusCode >= 200 && statusCode <= 299
    }

}
