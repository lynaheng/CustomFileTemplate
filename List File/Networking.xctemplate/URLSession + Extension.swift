

import Combine
import Foundation

extension URLSession {
    /**
     Call this method to request to server
     
     - Parameters:
        - url: The URL for the request.
        - body: The data sent as the message body of a request, such as for an HTTP POST request.
        - timeoutInterval: The timeout interval for the request. The default is 60.0. See the commentary for the timeoutInterval for more information on timeout intervals.
     
     */
    func request<T:Codable>(_ endpoint: IGEndpoint, headers: [String: String] = [:], cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 60.0) -> AnyPublisher<T, NetworkError> {
        consoleLog(prefix: "Endpoint(Combine) [\(endpoint.method.description)]", endpoint.url)
        
        var request = URLRequest(url: endpoint.url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = endpoint.method.description
        request.allHTTPHeaderFields = headers
        
        switch endpoint.method {
            case .post(let body), .put(let body):
                if let body = body {
                    let jsonData = try? JSONSerialization.data(withJSONObject: body.body, options: [])
                    request.httpBody = jsonData
                }
            default: break
            }
    
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.invalidResponse
                }
                do{
                    consoleLog(prefix: "Data", String(data: output.data, encoding: .utf8)!)
                    let result = try JSONDecoder().decode(T.self, from: output.data)
                    return result
                }catch{
                    consoleLog(prefix: "Decode failed", error)
                    print("Decode failed", error, separator: " ")
                    throw NetworkError.invalidData
                }
            }
            .mapError { $0 as? NetworkError ?? .unexpectedError }
            .eraseToAnyPublisher()
    }
}
