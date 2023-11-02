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
        @Dependency(\.cardsGenerator) var cardsGenerator
        let cardsArray: [Card.State] = cardsGenerator.availableCards(self, style).map {
            .init(style: $0, colors: self.colors)
        }
        return .init(uniqueElements: cardsArray)
    }
}
