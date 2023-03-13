import Foundation
import Combine

class NetworkRequest: NSObject, URLSessionDelegate {

    static var shared = NetworkRequest()
    /**
     Call this method to request to server without headers

     - Parameters:
        - url: The URL for the request.
        - body: The data sent as the message body of a request, such as for an HTTP POST request.
        - timeoutInterval: The timeout interval for the request. The default is 60.0. See the commentary for the timeoutInterval for more information on timeout intervals.
        - completion: The callback result.

     */
    func request<T:Codable>(_ url: Endpoint, timeoutInterval: TimeInterval = 60.0, completion: @escaping (Result<T, NetworkError>) -> Void){
//        guard InternetManager.shared.isConnectedToNetwork() else { return }

        consoleLog(prefix: "Endpoint [\(url.method.description)]:", url.url)
        var request = URLRequest(url: url.url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = url.method.description
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !UserDefaults.standard.isNil(forKey: .loggedInUser) {
            let userInfo = UserDefaults.standard.loggedInInfo
            request.setValue("\(userInfo.tokenType) \(userInfo.accessToken)", forHTTPHeaderField: "Authorization")
        }

        switch url.method {
            case .post(let body), .put(let body):
                if let body = body {
                    let jsonData = try? JSONSerialization.data(withJSONObject: body.body, options: [])
                    request.httpBody = jsonData
                }
            default: break
        }
        startRequesting(request, completion: completion)
    }

    func requestUpload<T:Codable>(_ url: IGEndpoint, data: Data, withName: String, fileName: String, timeoutInterval: TimeInterval = 60.0, completion: @escaping (Result<T,NetworkError>) -> Void){
//        guard InternetManager.shared.isConnectedToNetwork() else { return }

        consoleLog(prefix: "Endpoint [\(url.method.description) Upload] :", url.url)
        var request = URLRequest(url: url.url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = HTTPMethod.post(nil).description
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(parameters: [:],
                                      boundary: boundary,
                                      data: data,
                                      mimeType: "png",
                                      withName: withName,
                                      filename: fileName)

        startRequesting(request, completion: completion)
    }

    private func startRequesting<T:Codable>(_ request: URLRequest, completion: @escaping (Result<T,NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let res = response as? HTTPURLResponse, res.statusCode == 200 else {
                self.consoleLog(prefix: "HTTPURLResponse", response ?? "")
                completion(.failure(.invalidResponse))
                return
            }
            if let data = data {
                do{
                    self.consoleLog(prefix: "Data", String(data: data, encoding: .utf8)!)
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                }catch{
                    self.consoleLog(prefix: "Decode failed", error)
                    completion(.failure(.invalidData))
                }
            }else{
                self.consoleLog(prefix: "Unexpected error", error!)
                debugPrint(error!)
                completion(.failure(.unexpectedError))
            }
        }.resume()
    }

    private func createBody(parameters: [String: Any],
                            boundary: String,
                            data: Data,
                            mimeType: String,
                            withName: String,
                            filename: String) -> Data {
        let body = NSMutableData()

        let boundaryPrefix = "--\(boundary)\r\n"

        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(withName)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))

        return body as Data
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(
            .useCredential,
            URLCredential(trust: challenge.protectionSpace.serverTrust!)
        )
    }

}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
