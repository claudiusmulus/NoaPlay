//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-01.
//

import Models

public struct MemoryCardsGenerator {
    public var availableCards: (_ level: MemoryCardGame.Level, _ style: MemoryCardGame.Style) -> [MemoryCardGame.CardStyle]
    public var nextLevel: (_ after: MemoryCardGame.Level, _ difficulty: MemoryCardGame.Difficulty) -> MemoryCardGame.Level?
}
