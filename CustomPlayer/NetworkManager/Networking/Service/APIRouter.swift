//
//  Router.swift
//  RXMVVMC
//
//  Created by Vitalii Shkliar on 06.11.2019.
//  Copyright © 2019 Vitalii Shkliar. All rights reserved.
//

import Foundation

struct IncompletedRequest {
    let request: URLRequest
    let completion: (Result<(data: Data?, response: URLResponse?), Error>) -> Void
}

typealias StatusCode = Int
/**
 Network API router.
 - Builds requests
 - Sends request
 - Retrieves the response from the remote server.
 */
class APIRouter<EndPoint: EndPointType>: NetworkRouter {
    private var isRefreshing = false
    private var unauthorizedRequests: [IncompletedRequest] = []
    private var task: URLSessionTask?
    
    private let session: URLSession  = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 30
        config.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: config)
        return session
    }()
    
    /**
     Performs the request and retrieves the response data from the remote server
     - Parameters:
     - route: info for building the URLrequest
     - responseHandler: an objject which validates the response.
     - completion: Completion handler
     - Returns: fired URLSession task
     */
    @discardableResult
    func request<T: Decodable>(_ route: EndPoint, model: T.Type, responseHandler: RemoteAPIResponseHandler?, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask? {
        createTask(route, responseHandler: responseHandler) { result in
            switch result {
            case .success(let responseTuple):
                do {
                    guard let data = responseTuple.data else {
                        completion(.failure(ResponseError.noData))
                        return
                    }
                    NetworkLogger.log(response: responseTuple.response, data: data)
                    let model = try data.decodeTo(type: T.self)
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
//    @discardableResult
//    func requestWithPagination<T: Decodable>(_ route: EndPoint, model: T.Type, responseHandler: RemoteAPIResponseHandler?, completion: @escaping (Result<PaginatedResponse<T>, Error>) -> Void) -> URLSessionTask? {
//        createTask(route, responseHandler: responseHandler) { result in
//            switch result {
//            case .success(let responseTuple):
//                do {
//                    guard let data = responseTuple.data,
//                          let httpResponse = responseTuple.response as? HTTPURLResponse
//                    else {
//                        completion(.failure(ResponseError.noData))
//                        return
//                    }
//                    NetworkLogger.log(response: httpResponse, data: data)
//                    let items = try data.decodeTo(type: [T].self)
//                    let paginatedModel = PaginatedResponse(items: items, response: httpResponse)
//                    completion(.success(paginatedModel))
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
    
    @discardableResult
    func request(_ route: EndPoint, responseHandler: RemoteAPIResponseHandler?, completion: @escaping (Result<StatusCode, Error>) -> Void) -> URLSessionTask? {
        createTask(route, responseHandler: responseHandler) { result in
            switch result {
            case .success(let responseTuple):
                let successResponseCodesRange = 200...299
                let responseStatusCode = (responseTuple.response as? HTTPURLResponse)?.statusCode ?? 400
                if successResponseCodesRange ~= responseStatusCode {
                    completion(.success(responseStatusCode))
                } else {
                    completion(.failure(ResponseError.requestFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    func requestDownload(_ route: EndPoint, responseHandler: RemoteAPIResponseHandler?, completion: @escaping (Result<(localUrl: URL?, response: URLResponse?), Error>) -> Void) -> URLSessionDownloadTask? {
        createDownloadTask(route, responseHandler: responseHandler) { result in
            switch result {
            case .success(let responseTuple):
                let successResponseCodesRange = 200...299
                let responseStatusCode = (responseTuple.response as? HTTPURLResponse)?.statusCode ?? 400
                if successResponseCodesRange ~= responseStatusCode {
                    completion(.success(responseTuple))
                } else {
                    completion(.failure(ResponseError.requestFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func createTask(_ route: EndPoint, responseHandler: RemoteAPIResponseHandler?, completion: @escaping (Result<(data: Data?, response: URLResponse?), Error>) -> Void) -> URLSessionTask? {
        do {
            let request = try self.buildRequest(from: route)
            NetworkLogger.log(request: request)
            let task = createURLTask(request: request, responseHandler: responseHandler, completion: completion)
            self.task = task
            task.resume()
            return task
        } catch let error {
            completion(.failure(error))
        }
        return nil
    }
    
    private func createURLTask(request: URLRequest, responseHandler: RemoteAPIResponseHandler?, completion:  @escaping (Result<(data: Data?, response: URLResponse?), Error>) -> Void) -> URLSessionTask {
        session.dataTask(with: request, completionHandler: { [unowned self] data, response, error in
            if let error = error {
                completion(.failure(ConnectionError(error)))
                return
            }
            var handlerResult: Result<Void, Error> = .success(())
            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode != 401  else {
                let requestToRetry = IncompletedRequest(request: request, completion: completion)
                self.unauthorizedRequests.append(requestToRetry)
                if !self.isRefreshing {
                    self.isRefreshing = true
//                    self.refreshToken { result in
//                        switch result {
//                        case .success(let newToken):
//                            var modifiedRequests = self.unauthorizedRequests.map { incompleteRequest -> IncompletedRequest in
//                                var request = incompleteRequest.request
//                                request.allHTTPHeaderFields?["Authorization"] = "Bearer " + newToken
//                                return IncompletedRequest(request: request, completion: incompleteRequest.completion)
//                            }
//                            // Retrying old requests
//                            modifiedRequests.forEach { incompleteRequest in
//                                let task = createURLTask(request: incompleteRequest.request, responseHandler: responseHandler, completion: incompleteRequest.completion)
//                                task.resume()
//                            }
//                            modifiedRequests.removeAll()
//                            unauthorizedRequests.removeAll()
//                        case .failure(let error):
//                            completion(.failure(error))
//                        }
//                        self.isRefreshing = false
//                    }
                }
                return
            }
            
            if let handler = responseHandler {
                handlerResult = handler.handleNetworkResponse(response, data: data)
            }
            switch handlerResult {
            case .success:
                completion(.success((data, response)))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
//    private func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
//        UserAccountRepository.shared.refreshToken { result in
//            switch result {
//            case .success(let data):
//                completion(.success(data.accessToken))
//                UserDefaults.standard.setValue(data.accessToken, forKey: EndPointConstants.userDefaultsTokenKey)
//            case .failure(_):
//                UserAccountRepository.shared.delegate?.logout()
//            }
//        }
//    }
    
    /// Create download task
    private func createDownloadTask(_ route: EndPoint, responseHandler: RemoteAPIResponseHandler?, completion: @escaping (Result<(localUrl: URL?, response: URLResponse?), Error>) -> Void) -> URLSessionDownloadTask? {
        if task?.state == .running {
            cancel()
        }
        do {
            let request = try self.buildRequest(from: route)
            NetworkLogger.log(request: request)
            let task = URLSession.shared.downloadTask(with: request, completionHandler: { localUrl, response, error  in
                if let error = error {
                    completion(.failure(ConnectionError(error)))
                    return
                }
                var handlerResult: Result<Void, Error> = .success(())
                if let handler = responseHandler {
                    handlerResult = handler.handleNetworkResponse(response, data: nil)
                }
                switch handlerResult {
                case .success:
                    completion(.success((localUrl, response)))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
            self.task = task
            task.resume()
            return task
        } catch let error {
            completion(.failure(error))
        }
        return nil
    }
    /**
     Builds the URLrequest
     - Parameter route: endpoint which holds all the info for building request
     - Throws: encoding error
     - Returns: ready to send URLRequest
     */
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var url = route.baseURL
        if route.path != "" {
            url.appendPathComponent(route.path)
        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        request.httpMethod = route.httpMethod.rawValue
        request.allHTTPHeaderFields = route.headers
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters, let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let urlParameters,
                                              let additionalHeaders):
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    /**
     Configures the URLrequest with parameters
     - Parameters:
     - bodyParameters: represents JSON's body params
     - urlParameters: represents URL Query params
     - request: urlRequest to configure
     - Throws: encoding error
     */
    fileprivate func configureParameters(bodyParameters: Parameters?, urlParameters: Parameters?, request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    /**
     Adds additional headers to the request if needed
     - Parameters:
     - additionalHeaders: HTTPHeaders  to add
     - request: urlRequest which needs additional headers
     */
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    ///Cancels the URLSessionTask
    func cancel() {
        self.task?.cancel()
    }
}
