//
//  File.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-01.
//

import Dependencies

public extension MemoryCardsGenerator {
    
    static let live: MemoryCardsGenerator = .init(
        availableCards: { level, style in
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
        },
        initialLevel: { difficulty in
            switch difficulty {
            case .easy:
                return .one
            case .medium:
                return .three
            case .hard:
                return .four
            }
        },
        nextLevel: { level, difficulty in
            switch level.type {
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
    )

    
    static let mock: MemoryCardsGenerator = .init(
        availableCards: { level, style in
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
        },
        initialLevel: { difficulty in
            switch difficulty {
            case .easy:
                return .one
            case .medium:
                return .three
            case .hard:
                return .four
            }
        },
        nextLevel: { level, difficulty in
            switch level.type {
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
    )
}

private enum MemoryCardsGeneratorKey: DependencyKey {
    static let liveValue = MemoryCardsGenerator.live
}

extension DependencyValues {
    public var dataGenerator: MemoryCardsGenerator {
        get { self[MemoryCardsGeneratorKey.self] }
        set { self[MemoryCardsGeneratorKey.self] = newValue }
    }
}
