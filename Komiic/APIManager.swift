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

extension ApolloClient {

    @discardableResult
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .default,
        contextIdentifier: UUID? = nil,
        queue: DispatchQueue = .main
    ) async throws -> GraphQLResult<Query.Data> {
        return try await withTaskCancellationContinuation { continuation in
            return self.fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: contextIdentifier,
                queue: queue
            ) { result in
                continuation.resume(returning: result)
            }
        }
    }

    @discardableResult
    public func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        publishResultToStore: Bool = true,
        queue: DispatchQueue = .main
    ) async throws -> GraphQLResult<Mutation.Data> {
        return try await withTaskCancellationContinuation { continuation in
            return self.perform(
                mutation: mutation,
                publishResultToStore: publishResultToStore,
                queue: queue
            ) { result in
                continuation.resume(returning: result)
            }
        }
    }

}

extension ApolloClient {

    private func withTaskCancellationContinuation<T>(
        _ body: (CheckedContinuation<(Result<GraphQLResult<T>, Error>), Never>) -> Apollo.Cancellable
    ) async throws -> GraphQLResult<T> {
        let cancelState = makeState()
        let result: (Result<GraphQLResult<T>, Error>) = await withTaskCancellationHandler {
            return await withCheckedContinuation { continuation in
                let task = body(continuation)
                activate(state: cancelState, task: task)
            }
        } onCancel: {
            cancel(state: cancelState)
        }
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }

    private func makeState() -> Swift.ManagedBuffer<(isCancelled: Swift.Bool, task: Apollo.Cancellable?), Darwin.os_unfair_lock> {
        ManagedBuffer<(isCancelled: Bool, task: Apollo.Cancellable?), os_unfair_lock>.create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointerToElements { $0.initialize(to: os_unfair_lock()) }
            return (isCancelled: false, task: nil)
        }
    }

    private func cancel(state: Swift.ManagedBuffer<(isCancelled: Swift.Bool, task: Apollo.Cancellable?), Darwin.os_unfair_lock>) {
        state.withUnsafeMutablePointers { state, lock in
            os_unfair_lock_lock(lock)
            let task = state.pointee.task
            state.pointee = (isCancelled: true, task: nil)
            os_unfair_lock_unlock(lock)
            task?.cancel()
        }
    }

    private func activate(state: Swift.ManagedBuffer<(isCancelled: Swift.Bool, task: Apollo.Cancellable?), Darwin.os_unfair_lock>, task: Apollo.Cancellable) {
        state.withUnsafeMutablePointers { state, lock in
            os_unfair_lock_lock(lock)
            if state.pointee.task != nil {
                fatalError("Cannot activate twice")
            }
            if state.pointee.isCancelled {
                os_unfair_lock_unlock(lock)
                task.cancel()
            } else {
                state.pointee = (isCancelled: false, task: task)
                os_unfair_lock_unlock(lock)
            }
        }
    }

}
