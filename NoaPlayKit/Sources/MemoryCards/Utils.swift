//
//  Models.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//
import SwiftUI
import Models
import Theme
import ComposableArchitecture
import DataGenerator

extension MemoryCardGame.Level {
    func availableCards(style: MemoryCardGame.Style) -> IdentifiedArrayOf<Card.State> {
        @Dependency(\.dataGenerator.availableCards) var cardsGenerator
        let cardsArray: [Card.State] = cardsGenerator(self, style).map {
            .init(style: $0)
        }
        return .init(uniqueElements: cardsArray)
    }
}

extension MemoryCardGame.Difficulty {
    func initialLevel() -> MemoryCardGame.Level {
        @Dependency(\.dataGenerator.initialLevel) var initialLevelGenerator
        
        return initialLevelGenerator(self)
    }
}

extension MemoryCardGame.Mode {
    var title: String {
        switch self {
        case .practice:
            return "Practice"
        case .timer:
            return "Timer"
        }
    }
    
    var iconName: String {
        switch self {
        case .practice:
            return "house.fill"
        case .timer:
            return "clock.fill"
        }
    }
}

extension MemoryCardGame.Style {
    var title: String {
        switch self {
        case .numbers:
            return "123"
        case .letters:
            return "Abc"
        }
    }
}

extension MemoryCardGame.Difficulty {
    var title: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }
}
