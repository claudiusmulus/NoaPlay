//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-01.
//

import SwiftUI
import Models

public extension Color {
    static func background(level: String) -> Color {
        Color("background_Level" + level, bundle: .module)
    }
    static func backCard(level: String) -> Color {
        Color("card_Level" + level, bundle: .module)
    }
    static func frontCard(level: String) -> Color {
        Color("details_Level" + level, bundle: .module)
    }
    static func details(level: String) -> Color {
        Color("details_Level" + level, bundle: .module)
    }
    
    static let gameBackground: Color = Color("background_game", bundle: .module)
    static let gameOption: Color = Color("option_game", bundle: .module)
    static let gameAction: Color = Color("action_game", bundle: .module)
}

