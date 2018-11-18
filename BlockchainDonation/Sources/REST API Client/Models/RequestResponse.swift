import Foundation

enum RequestResponse: Int, Codable {
    case fail = 0
    case success
    case invalidBlockchainData
}
