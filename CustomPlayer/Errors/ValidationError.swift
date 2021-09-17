//
//  ValidationError.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 24.06.2021.
//

import Foundation

struct ValidationError: LocalizedError {
    var errorDescription: String? { return message }
    private var message: String?
    
    init(_ message: String?) {
        self.message = message
    }
    
    static let nameIsToShort = ValidationError("FirstName or LastName must contain more than two characters")
    static let passwordIsEmpty = ValidationError("Password is Required")
    static let nameIsTolong = ValidationError("Name shoudn't contain more than 18 characters")
    static let passwordIsToShort = ValidationError("Password must have at least 6 characters")
    static let passwordDidNotMatchRegulations = ValidationError("Password must be more than 6 characters, with at least one uppercased, one lowercased and a special character")
    static let emailIsNotSupported = ValidationError("Only @axon.dev email domain supported")
}
