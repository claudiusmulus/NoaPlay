//
//  Models.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//
import SwiftUI
import ComposableArchitecture

struct GameDurationFormatter {
    enum Format {
        case timer
        case details
    }
    var formatGameDuration: (_ duration: Duration, _ format: Format) -> String
}

extension GameDurationFormatter {
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

private enum GameDurationFormatterKey: DependencyKey {
    static let liveValue = GameDurationFormatter.live
}

extension DependencyValues {
    var gameDurationFormatter: GameDurationFormatter {
        get { self[GameDurationFormatterKey.self] }
        set { self[GameDurationFormatterKey.self] = newValue }
    }
}

struct MemoryCardsGenerator {
    var getAvailableCards: (_ level: MemoryCardGame.Level, _ style: MemoryCardGame.Style) -> [MemoryCardGame.CardStyle]
}

extension MemoryCardsGenerator {
    
    static let live: MemoryCardsGenerator = .init { level, style in
        switch level.type {
        case .one:
            return .level1(style: style).shuffled()
        case .two:
            return .level2(style: style).shuffled()
        case .three:
            return .level3(style: style).shuffled()
        case .four:
            return .level4(style: style).shuffled()
        case .five:
            return []
        case .six:
            return []
        case .seven:
            return []
        case .eight:
            return []
        case .nine:
            return []
        case .ten:
            return []
        }
    }
    
    static let mock: MemoryCardsGenerator = .init { level, style in
        switch level.type {
        case .one:
            return .level1(style: style)
        case .two:
            return .level2(style: style)
        case .three:
            return .level3(style: style)
        case .four:
            return .level4(style: style)
        case .five:
            return []
        case .six:
            return []
        case .seven:
            return []
        case .eight:
            return []
        case .nine:
            return []
        case .ten:
            return []
        }
    }
}

private enum MemoryCardsGeneratorKey: DependencyKey {
    static let liveValue = MemoryCardsGenerator.live
}

extension DependencyValues {
    var cardsGenerator: MemoryCardsGenerator {
        get { self[MemoryCardsGeneratorKey.self] }
        set { self[MemoryCardsGeneratorKey.self] = newValue }
    }
}

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

struct MemoryCardGame {
    let mode: Mode
    let style: Style
}

extension MemoryCardGame {
    enum Mode: Equatable {
        case practice
        case `default`
    }
    
    enum Style: Equatable {
        case numbers
        case letters
        case animals
    }
    
    enum Difficulty: Equatable {
        case easy
        case medium
    }
    
    enum CardStyle: Equatable, CustomStringConvertible {
        case number(_ value: String)
        case letter(_ value: String)
        case image(name: String, value: String)
        
        var description: String {
            switch self {
            case let .number(value):
                return value
            case let .letter(value):
                return value
            case let .image(_, value):
                return value
            }
        }
    }
    
    struct Level: Equatable {
        let type: LevelType
        let message: String
        let colors: Colors
        
        init(type: LevelType, message: String, colors: Colors) {
            self.type = type
            self.message = message
            self.colors = colors
        }
        
        enum LevelType: Equatable {
            case one
            case two
            case three
            case four
            case five
            case six
            case seven
            case eight
            case nine
            case ten
        }
        
        struct Colors: Equatable {
            let background: Color
            let backCard: Color
            let frontCard: Color
            let details: Color
        }
    }
}

extension MemoryCardGame.Level.Colors {
    static func level(_ level: String) -> Self {
        .init(
            background: Color("background_Level" + level),
            backCard: Color("card_Level" + level),
            frontCard: Color("details_Level" + level),
            details: Color("details_Level" + level)
        )
    }
}

extension MemoryCardGame.Level {
    
    func availableCards(style: MemoryCardGame.Style) -> IdentifiedArrayOf<MemoryCard.State> {
        @Dependency(\.cardsGenerator) var cardsGenerator
        let cardsArray: [MemoryCard.State] = cardsGenerator.getAvailableCards(self, style).map {
            .init(style: $0, colors: self.colors)
        }
        return .init(uniqueElements: cardsArray)
    }
    
    func nextLevel(difficulty: MemoryCardGame.Difficulty) -> Self? {
        switch self.type {
        case .one:
            return .two
        case .two:
            return .three
        case .three:
            return .four
        case .four:
            return .init(type: .five, message: "Level 5", colors: .level("1"))
        case .five:
            return difficulty == .easy ? nil : .init(type: .six, message: "Level 6", colors: .level("1"))
        case .six:
            return difficulty == .easy ? nil : .init(type: .seven, message: "Level 7", colors: .level("1"))
        case .seven:
            return difficulty == .easy ? nil : .init(type: .eight, message: "Level 8", colors: .level("1"))
        case .eight:
            return difficulty == .easy ? nil : .init(type: .nine, message: "Level 9", colors: .level("1"))
        case .nine:
            return difficulty == .easy ? nil : .init(type: .ten, message: "Level 10", colors: .level("1"))
        case .ten:
            return nil
        }
    }
    
    static let one: Self = .init(type: .one, message: "Level 1", colors: .level("1"))
    static let two: Self = .init(type: .two, message: "Level 2", colors: .level("2"))
    static let three: Self = .init(type: .three, message: "Level 3", colors: .level("3"))
    static let four: Self = .init(type: .four, message: "Level 4", colors: .level("4"))
}

struct PairMatch<Element: Equatable> {
    
    typealias Pair = (firstElement: Element, secondElement: Element)
    
    private(set) var firstElement: Element?
    private(set) var secondElement: Element?

    let matching: (Element, Element) -> Bool
    init(
        matching: @escaping (Element, Element) -> Bool
    ) {
        self.matching = matching
        self.firstElement = nil
        self.secondElement = nil
    }
    
    mutating func add(_ element: Element) {
        if firstElement == nil {
            self.firstElement = element
        } else if secondElement == nil {
            self.secondElement = element
        }
    }
    
    mutating func clear() {
        self.firstElement = nil
        self.secondElement = nil
    }
    
    func currentPair() -> Pair? {
        guard let firstElement = self.firstElement, let secondElement = self.secondElement else {
            return nil
        }
        return (firstElement, secondElement)
    }
    
    func pairMatch() -> Pair? {
        guard let firstElement = self.firstElement, let secondElement = self.secondElement else {
            return nil
        }
        return matching(firstElement, secondElement) ? (firstElement, secondElement) : nil
    }
}

extension PairMatch: Equatable {
    static func == (lhs: PairMatch<Element>, rhs: PairMatch<Element>) -> Bool {
        lhs.firstElement == rhs.firstElement && lhs.secondElement == rhs.secondElement
    }
}
