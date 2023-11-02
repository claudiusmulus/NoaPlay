//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-01.
//

import Dependencies

private enum GameDurationFormatterKey: DependencyKey {
    static let liveValue = GameDurationFormatter.live
}

public extension DependencyValues {
    var gameDurationFormatter: GameDurationFormatter {
        get { self[GameDurationFormatterKey.self] }
        set { self[GameDurationFormatterKey.self] = newValue }
    }
}

public extension GameDurationFormatter {
    static let live: GameDurationFormatter = .init { duration, format in
        switch format {
        case .timer:
            if duration <= .seconds(3600) {
                return duration.formatted(.time(pattern: .minuteSecond))
            } else {
                return duration.formatted(.time(pattern: .hourMinuteSecond))
            }
        case .details:
            if duration < .seconds(60) {
                return String(describing: duration)
            } else if duration < .seconds(3600) {
                return duration.formatted(.time(pattern: .minuteSecond))
            } else {
                return duration.formatted(.time(pattern: .hourMinuteSecond))
            }
        }
    }
    
    static let mock: GameDurationFormatter = .init { duration, format in
        return String(describing: duration)
    }
}
