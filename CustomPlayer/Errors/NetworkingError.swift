//
//  NetworkResponseError.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 24.06.2021.
//

import Foundation

struct NetworkingError: LocalizedError {
    var errorDescription: String? { message }
    private let message: String
    
    init(statusCode: Int, data: Data?) {
        switch statusCode {
        case 500:
            message = "An internal server error has occurred"
        case 503:
            message = "Server might be on maintenance, try again later"
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
