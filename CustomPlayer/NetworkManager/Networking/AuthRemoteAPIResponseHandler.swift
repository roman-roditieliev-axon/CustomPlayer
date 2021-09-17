//
//  AuthRemoteAPIResponseHandler.swift
//  RXMVVMC
//
//  Created by Vitalii Shkliar on 06.11.2019.
//  Copyright © 2019 Vitalii Shkliar. All rights reserved.
//

import Foundation

class AuthRemoteAPIResponseHandler: RemoteAPIResponseHandler {
    typealias EndPoint = Auth
    func handleNetworkResponse(_ response: URLResponse?, data: Data?) -> Result<Void, Error> {
        guard let response = response as? HTTPURLResponse else { return .failure(URLRequestError.unknown) }
        switch response.statusCode {
        case 200...299: return .success(())
        case 400...499: return .failure(AuthRemoteAPIError(statusCode: response.statusCode, data: data))
        case 500...599: return .failure(NetworkingError(statusCode: response.statusCode, data: data))
        case 600: return .failure(URLRequestError.outdated)
        default: return .failure(URLRequestError.unknown)
        }
    }
}
