//
//  TimeFormatted.swift
//  CustomPlayer
//
//  Created by User on 17.09.2021.
//

import Foundation

enum TimeFormatter {
    static func format(duration: TimeInterval, currentTime: TimeInterval) -> (timePlayed: String, timeLeft: String) {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]

        let remainingTime = floor(duration) - currentTime
        let playedTime = floor(duration) - remainingTime

        let timeLeft = formatter.string(from: remainingTime) ?? "00:00"
        let timePlayed = formatter.string(from: playedTime) ?? "00:00"

        return (timePlayed, timeLeft)
    }

    static func format(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [ .hour, .minute ]
        formatter.zeroFormattingBehavior = [ .pad ]

        let time = formatter.string(from: duration) ?? "00:00"

        return time
    }

    static func formatDate(date: String?) -> String? {
        guard let date = date else { return "" }

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        let newDate: Date? = dateFormatterGet.date(from: date)

        guard let newDateStr = newDate else { return nil }

        return dateFormatter.string(from: newDateStr)
    }
}
