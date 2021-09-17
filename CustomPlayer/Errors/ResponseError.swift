//
//  ResponseError.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 24.06.2021.
//

import Foundation

struct ResponseError: LocalizedError {
    var errorDescription: String? { message }
    private var message: String?
    
    init(_ message: String) {
        self.message = message
    }
    
    static let noData = ResponseError("There is no data on the server")
    static let responseIsNotValid = ResponseError("Response is not valid")
    static let sessionTaskFailed = ResponseError("Fail to create session")
    static let defaultError = ResponseError("Something went wrong")
    static let requestFailed = ResponseError("Fail to create request")
}
