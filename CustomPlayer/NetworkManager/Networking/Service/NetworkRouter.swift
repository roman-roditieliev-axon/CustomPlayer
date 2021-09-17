//
//  NetworkRouter.swift
//  RXMVVMC
//
//  Created by Vitalii Shkliar on 06.11.2019.
//  Copyright © 2019 Vitalii Shkliar. All rights reserved.
//

import Foundation

protocol NetworkRouter: AnyObject {
    associatedtype EndPoint: EndPointType

    @discardableResult
    func request<T: Decodable>(_ route: EndPoint, model: T.Type, responseHandler: RemoteAPIResponseHandler?, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask?

    @discardableResult
    func request(_ route: EndPoint, responseHandler: RemoteAPIResponseHandler?, completion: @escaping (Result<StatusCode, Error>) -> Void) -> URLSessionTask?

    func cancel()
}
