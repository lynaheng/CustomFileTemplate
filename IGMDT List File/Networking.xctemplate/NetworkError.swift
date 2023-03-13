
import Foundation

enum NetworkError: Error, CustomStringConvertible {
    
    case unexpectedError
    case connectionError
    case invalidData
    case invalidResponse
    
    var description: String {
        switch self {
            case .unexpectedError:
                return "An unexpected error has occurred. Please try again."
            case .connectionError:
                return "Unable to complete your request. Please check your internet connection."
            case .invalidData:
                return "The data received from the server is invalid. Please try again."
            case .invalidResponse:
                return "Invalid response from the server. Please try again."
        }
    }
    
}
