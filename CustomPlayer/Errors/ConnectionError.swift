//
//  NetworkError.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 25.06.2021.
//

import Foundation

struct ConnectionError: LocalizedError {
    var errorDescription: String? { message }
    private let message: String
    
    init(_ error: Error) {
        self.message = "Check you're internet connection"
    }
}
