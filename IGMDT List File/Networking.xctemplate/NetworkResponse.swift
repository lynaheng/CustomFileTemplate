import Foundation

struct Response: Codable {
    let code: Int
    let message: String
}

struct ResponseModel: Codable {
    let response: Response
}
