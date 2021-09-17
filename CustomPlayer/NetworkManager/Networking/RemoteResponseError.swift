//
//  AuthorizationError.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 24.06.2021.
//

import Foundation

// MARK: - AuthorizationError
struct RemoteResponseError: Error, Decodable {
    let message, code: String
}
