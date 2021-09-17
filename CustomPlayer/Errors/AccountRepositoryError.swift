//
//  NetworkError.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 24.06.2021.
//

import Foundation

struct AccountRepositoryError: LocalizedError {
    var errorDescription: String? { return message }
    private var message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    static let noAccessToken = AccountRepositoryError("You don't have permission to do so")
    static let failToCreateAccount = AccountRepositoryError("Couldn't create account now")
    static let failToLogout = AccountRepositoryError("Unable to logout now")
    static let failToRefreshToken = AccountRepositoryError("Unable to refresh token")
    static let failToGetProfile = AccountRepositoryError("Unable to get information about you're profile, try again later, please")
}
