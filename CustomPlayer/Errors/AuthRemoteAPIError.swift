//
//  APIError.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 24.06.2021.
//

import Foundation

// MARK: - Auth
struct AuthRemoteAPIError: LocalizedError {
    var errorDescription: String? { message }
    private let message: String
    init(statusCode: Int, data: Data?) {
        switch statusCode {
        case 401:
            message = AccountRepositoryError.noAccessToken.localizedDescription
        case 403:
            message = "Authorization failed"
        case 408:
            message = "Check you're internet connection and try again later"
        case 409:
            message = "Please confirm your email to use Axon Podcasts"
        default:
            guard let data = data else {
                message = "Something went wrong, please try again later"
                return
            }
            do {
                message = try data.decodeTo(type: RemoteResponseError.self).message
            } catch let error {
                message = error.localizedDescription
            }
        }
    }
}
