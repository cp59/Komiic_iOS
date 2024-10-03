//
//  APIManager.swift
//  Komiic
//
//  Created by 梁承樸 on 2024/7/28.
//

import Apollo
import ApolloAPI
import Foundation
import KeychainSwift
import KomiicAPI

class APIManager {
    static let shared: APIManager = .init()

    func login(email: String, password: String, completion: @escaping (LoginResponse) -> Void) {
        let parameters = "{\"email\":\"\(email)\",\"password\":\"\(password)\"}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://komiic.com/api/login")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion(LoginResponse(expire: "", token: ""))
                return
            }
            if data.isEmpty {
                completion(LoginResponse(expire: "", token: ""))
                return
            } else {
                do {
                    try completion(JSONDecoder().decode(LoginResponse.self, from: data))
                    return
                } catch {
                    completion(LoginResponse(expire: "", token: ""))
                    return
                }
            }
        }

        task.resume()
    }

    private(set) lazy var apolloClient: ApolloClient = {
        let client = URLSessionClient()
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let provider = NetworkInterceptorProvider(client: client, store: store)
        let url = URL(string: "https://komiic.com/api/query")!
        let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                     endpointURL: url)
        return ApolloClient(networkTransport: transport,store: store)
    }()
}

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(AuthorizationInterceptor(), at: 0)
        return interceptors
    }
}

class AuthorizationInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString
    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation : GraphQLOperation {
        let keychain = KeychainSwift()
        if let token = keychain.get("token") {
            request.addHeader(name: "Authorization", value: token)
        }

        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion)
    }
    
}

struct LoginResponse: Codable {
    let expire: String
    let token: String
}
