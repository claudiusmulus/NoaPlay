//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-01.
//

import Models
import Theme

extension Array where Element == MemoryCardGame.CardStyle {
    static func level1(style: MemoryCardGame.Style) -> Self {
        switch style {
        case .numbers:
            return [
                .number("1"),
                .number("1"),
                .number("2"),
                .number("2")
            ]
        case .letters:
            return [
                .number("A"),
                .number("A"),
                .number("B"),
                .number("B")
            ]
        case .animals:
            return []
        }
    }
    
    static func level2(style: MemoryCardGame.Style) -> Self {
        switch style {
        case .numbers:
            return [
                .number("1"),
                .number("1"),
                .number("2"),
                .number("2"),
                .number("3"),
                .number("3"),
                .number("4"),
                .number("4")
            ]
        case .letters:
            return [
                .number("A"),
                .number("A"),
                .number("B"),
                .number("B"),
                .number("C"),
                .number("C"),
                .number("D"),
                .number("D")
            ]
        case .animals:
            return []
        }
    }
    
    static func level3(style: MemoryCardGame.Style) -> Self {
        switch style {
        case .numbers:
            return [
                .number("1"),
                .number("1"),
                .number("2"),
                .number("2"),
                .number("3"),
                .number("3"),
                .number("4"),
                .number("4"),
                .number("5"),
                .number("5"),
                .number("6"),
                .number("6")
            ]
        case .letters:
            return [
                .number("A"),
                .number("A"),
                .number("B"),
                .number("B"),
                .number("C"),
                .number("C"),
                .number("D"),
                .number("D"),
                .number("E"),
                .number("E"),
                .number("F"),
                .number("F")
            ]
        case .animals:
            return []
        }
    }
    
    static func level4(style: MemoryCardGame.Style) -> Self {
        switch style {
        case .numbers:
            return [
                .number("1"),
                .number("1"),
                .number("2"),
                .number("2"),
                .number("3"),
                .number("3"),
                .number("4"),
                .number("4"),
                .number("5"),
                .number("5"),
                .number("6"),
                .number("6"),
                .number("7"),
                .number("7"),
                .number("8"),
                .number("8")
            ]
        case .letters:
            return [
                .number("A"),
                .number("A"),
                .number("B"),
                .number("B"),
                .number("C"),
                .number("C"),
                .number("D"),
                .number("D"),
                .number("E"),
                .number("E"),
                .number("F"),
                .number("F"),
                .number("G"),
                .number("G"),
                .number("H"),
                .number("H")
            ]
        case .animals:
            return []
        }
    }
}

public extension MemoryCardGame.Level {
    static let one: Self = .init(type: .one, message: "Level 1", colors: .level("1"))
    static let two: Self = .init(type: .two, message: "Level 2", colors: .level("2"))
    static let three: Self = .init(type: .three, message: "Level 3", colors: .level("3"))
    static let four: Self = .init(type: .four, message: "Level 4", colors: .level("4"))
}

public extension MemoryCardGame.Level.Colors {
    static func level(_ level: String) -> Self {
        .init(
            background: .background(level: level),
            backCard: .backCard(level: level),
            frontCard: .frontCard(level: level),
            details: .details(level: level)
        )
    }
}
