import Foundation

struct Endpoint {
    
    private let path: String
    private let queryItems: [URLQueryItem]
    let method: HTTPMethod
    
    init(path: String, method: HTTPMethod) {
        self.path = path
        self.queryItems = []
        self.method = method
    }
    
    init(path: String, queryItems: [URLQueryItem], method: HTTPMethod) {
        self.path = path
        self.queryItems = queryItems
        self.method = method
    }
    
    private var localUrl: URLComponents {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "192.168.5.57"
        components.port = 8002
        components.path = "/api/v1/lw/" + path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components
    }
    
    /**
        Base url where app will connect to
     */
    var url: URL {
        return localUrl.url!
    }
}

extension Endpoint {
    // MARK: - Login
    static func login(_ body: HTTPBody) -> Self {
        Endpoint(path: "login", method: .post(body))
    }
    // MARK: - User list
    static func getUserList(page: Int) -> Self {
        Endpoint(path: "users", queryItems: [URLQueryItem(name: "page", value: page.description)], method: .get)
    }
    
}
