//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-01.
//

import SwiftUI
import Models

public struct GameDurationFormatter {
    public enum Format {
        case timer
        case details
    }
    public var formatGameDuration: (_ duration: Duration, _ format: Format) -> String
}
