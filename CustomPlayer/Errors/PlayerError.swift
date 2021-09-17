//
//  PlayerError.swift
//  AxonPodcasts
//
//  Created by Evhen Petrovskyi on 11.07.2021.
//

import Foundation

struct PlayerError: LocalizedError {
    var errorDescription: String? { message }
    private var message: String?
    
    init(_ message: String) {
        self.message = message
    }
    
    static let noData = PlayerError("No available audio for you're request")
    static let cantPlayFile = PlayerError("Unable to play selected podcast now, try again later")
    static let wrongParameters = PlayerError("Fail to read podcast details")
    static let noLastPodcastSaved = PlayerError("No data for last podcast")
}
