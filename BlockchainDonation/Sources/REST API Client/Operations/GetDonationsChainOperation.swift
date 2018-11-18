import Foundation

struct Donation: Codable {

    let balance: Int
    let date: Date
    let description: String
    let stepID: Int
    let amount: Int
    let transitionDate: Date
    let purpose: String
    let accountNumber: Int
    let taxID: String
    let organizationName: String

    private enum DonationCodingKey: String, CodingKey {
        case balance
        case date = "timeStamp"
        case description
        case stepID = "stepId"
        case amount
        case transitionDate
        case purpose
        case accountNumber
        case taxID = "taxId"
        case organizationName
    }

}

private struct GetDonationChainResponse: Codable {

    let result: Int
    let output: [Donation]

}

final class GetDonationsChainOperation: AsyncOperation {

    // MARK: - Internal properties

    let donationID: String
    var donations: [Donation]?

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
            let getDonationChainResponse = try jsonDecoder.decode(GetDonationChainResponse.self, from: data)
            donations = getDonationChainResponse.output
        }
        catch {
            NSLog("Could not parse data and cast it to type:\(GetDonationChainResponse.self). Error: \(error.localizedDescription)")
        }
    }

}

extension HTTPURLResponse {

    var isSuccessful: Bool {
        return statusCode >= 200 && statusCode <= 299
    }

}
