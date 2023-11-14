import SwiftUI

public struct MemoryCardGame {
    public let mode: Mode
    public let style: Style
    
    public init(mode: MemoryCardGame.Mode, style: MemoryCardGame.Style) {
        self.mode = mode
        self.style = style
    }
}

public extension MemoryCardGame {
    enum Mode: Equatable, CaseIterable {
        case practice
        case timer
    }
    
    enum Style: Equatable, CaseIterable {
        case numbers
        case letters
    }
    
    enum Difficulty: Equatable, CaseIterable {
        case easy
        case medium
        case hard
    }
    
    enum CardStyle: Equatable, CustomStringConvertible {
        case number(_ value: String)
        case letter(_ value: String)
        case image(name: String, value: String)
        
        public var description: String {
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
        public let type: LevelType
        public let message: String
        
        public init(type: LevelType, message: String) {
            self.type = type
            self.message = message
        }
        
        public enum LevelType: Equatable {
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
    }
}

public struct PairMatch<Element: Equatable> {
    
    public typealias Pair = (firstElement: Element, secondElement: Element)
    
    public private(set) var firstElement: Element?
    public private(set) var secondElement: Element?

    let matching: (Element, Element) -> Bool
    public init(
        matching: @escaping (Element, Element) -> Bool
    ) {
        self.matching = matching
        self.firstElement = nil
        self.secondElement = nil
    }
    
    public mutating func add(_ element: Element) {
        if firstElement == nil {
            self.firstElement = element
        } else if secondElement == nil {
            self.secondElement = element
        }
    }
    
    public mutating func clear() {
        self.firstElement = nil
        self.secondElement = nil
    }
    
    public func currentPair() -> Pair? {
        guard let firstElement = self.firstElement, let secondElement = self.secondElement else {
            return nil
        }
        return (firstElement, secondElement)
    }
    
    public func pairMatch() -> Pair? {
        guard let firstElement = self.firstElement, let secondElement = self.secondElement else {
            return nil
        }
        return matching(firstElement, secondElement) ? (firstElement, secondElement) : nil
    }
}

extension PairMatch: Equatable {
    public static func == (lhs: PairMatch<Element>, rhs: PairMatch<Element>) -> Bool {
        lhs.firstElement == rhs.firstElement && lhs.secondElement == rhs.secondElement
    }
}
