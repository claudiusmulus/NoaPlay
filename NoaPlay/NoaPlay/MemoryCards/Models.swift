//
//  Models.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//
import Foundation
import ComposableArchitecture

extension IdentifiedArray where ID == MemoryCard.State.ID, Element == MemoryCard.State {
    static let mock: Self = [
        .init(number: "1"),
        .init(number: "2"),
        .init(number: "3"),
        .init(number: "2"),
        .init(number: "1"),
        .init(number: "4"),
        .init(number: "3"),
        .init(number: "4")
    ]
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
