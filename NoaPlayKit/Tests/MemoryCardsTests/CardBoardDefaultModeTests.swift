//
//  CardBoardDefaultModeTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-02.
//

import XCTest
@testable import MemoryCards
import ComposableArchitecture

@MainActor
final class CardBoardDefaultModeTests: XCTestCase {

    func testCompleteLevel() async {
        let clock = TestClock()
        let store = TestStore<CardBoard.State, CardBoard.Action>(
            initialState: CardBoard.State(
                mode: .default,
                difficulty: .easy,
                style: .numbers,
                level: .one
            )
        ) {
            CardBoard()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.cardsGenerator = .mock
            $0.continuousClock = clock
            $0.gameDurationFormatter = .mock
        }
        
        await store.send(.card(id: UUID(0), action: .delegate(.attemptToFlipCard(id: UUID(0))))) {
            $0.cards[id: UUID(0)]?.isFlipped = true
            $0.didStartGame = true
            $0.flippedPairCards.add(.init(id: UUID(0), value: "1"))
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.gameDuration = .seconds(1)
        }
        
        await store.send(.card(id: UUID(1), action: .delegate(.attemptToFlipCard(id: UUID(1))))) {
            $0.cards[id: UUID(1)]?.isFlipped = true
            $0.flippedPairCards.clear()
        }
        
        await clock.advance(by: .seconds(0.5))
        await store.receive(.showMatch(id1: UUID(0), id2: UUID(1))) {
            $0.cards[id: UUID(0)]?.isPaired = true
            $0.cards[id: UUID(1)]?.isPaired = true
        }
        
        await store.send(.card(id: UUID(2), action: .delegate(.attemptToFlipCard(id: UUID(2))))) {
            $0.cards[id: UUID(2)]?.isFlipped = true
            $0.flippedPairCards.add(.init(id: UUID(2), value: "2"))
        }
        
        await store.send(.card(id: UUID(3), action: .delegate(.attemptToFlipCard(id: UUID(3))))) {
            $0.cards[id: UUID(3)]?.isFlipped = true
            $0.flippedPairCards.clear()
        }
    
        await clock.advance(by: .seconds(0.5))
        await store.receive(.timerTicked) {
            $0.gameDuration = .seconds(2)
        }
        await store.receive(.showMatch(id1: UUID(2), id2: UUID(3))) {
            $0.cards[id: UUID(2)]?.isPaired = true
            $0.cards[id: UUID(3)]?.isPaired = true
        }
        
        await clock.advance(by: .seconds(0.4))
        await store.receive(.completeLevel(.one)) {
            $0.showLevelDetails = .init(completedLevel: .one, difficulty: .easy, gameDuration: .seconds(2))
        }
    }
    
    func testCompleteLevelFailureSteps() async {
        let clock = TestClock()
        let store = TestStore<CardBoard.State, CardBoard.Action>(
            initialState: CardBoard.State(
                mode: .default,
                difficulty: .easy,
                style: .numbers,
                level: .one
            )
        ) {
            CardBoard()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.cardsGenerator = .mock
            $0.continuousClock = clock
            $0.gameDurationFormatter = .mock
        }
        
        await store.send(.card(id: UUID(0), action: .delegate(.attemptToFlipCard(id: UUID(0))))) {
            $0.cards[id: UUID(0)]?.isFlipped = true
            $0.didStartGame = true
            $0.flippedPairCards.add(.init(id: UUID(0), value: "1"))
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTicked) {
            $0.gameDuration = .seconds(1)
        }
        
        await store.send(.card(id: UUID(2), action: .delegate(.attemptToFlipCard(id: UUID(2))))) {
            $0.cards[id: UUID(2)]?.isFlipped = true
            $0.flippedPairCards.add(.init(id: UUID(2), value: "2"))
        }
        
        await clock.advance(by: .seconds(2))
        await store.receive(.timerTicked) {
            $0.gameDuration = .seconds(2)
        }
        
        await store.receive(.unflippedPair(id1: UUID(0), id2: UUID(2))) {
            $0.cards[id: UUID(0)]?.isFlipped = false
            $0.cards[id: UUID(2)]?.isFlipped = false
            $0.flippedPairCards.clear()
        }
        
        await store.receive(.timerTicked) {
            $0.gameDuration = .seconds(3)
        }
        
        await store.send(.card(id: UUID(0), action: .delegate(.attemptToFlipCard(id: UUID(0))))) {
            $0.cards[id: UUID(0)]?.isFlipped = true
            $0.flippedPairCards.add(.init(id: UUID(0), value: "1"))
        }
        
        await store.send(.card(id: UUID(3), action: .delegate(.attemptToFlipCard(id: UUID(3))))) {
            $0.cards[id: UUID(3)]?.isFlipped = true
            $0.flippedPairCards.add(.init(id: UUID(3), value: "2"))
        }
        
        await store.send(.card(id: UUID(1), action: .delegate(.attemptToFlipCard(id: UUID(1))))) {
            $0.cards[id: UUID(0)]?.isFlipped = false
            $0.cards[id: UUID(3)]?.isFlipped = false
            $0.flippedPairCards.clear()
        }
        
        await clock.advance(by: .seconds(0.3))
        
        await store.receive(.flipCard(id: UUID(1), value: "1")) {
            $0.flippedPairCards.add(.init(id: UUID(1), value: "1"))
            $0.cards[id: UUID(1)]?.isFlipped = true
        }
        
        await store.send(.card(id: UUID(0), action: .delegate(.attemptToFlipCard(id: UUID(0))))) {
            $0.cards[id: UUID(0)]?.isFlipped = true
            $0.flippedPairCards.clear()
        }
        
        await clock.advance(by: .seconds(0.5))
        await store.receive(.showMatch(id1: UUID(1), id2: UUID(0))) {
            $0.cards[id: UUID(0)]?.isPaired = true
            $0.cards[id: UUID(1)]?.isPaired = true
        }
        
        await store.send(.card(id: UUID(2), action: .delegate(.attemptToFlipCard(id: UUID(2))))) {
            $0.cards[id: UUID(2)]?.isFlipped = true
            $0.flippedPairCards.add(.init(id: UUID(2), value: "2"))
        }
        
        await store.send(.card(id: UUID(3), action: .delegate(.attemptToFlipCard(id: UUID(3))))) {
            $0.cards[id: UUID(3)]?.isFlipped = true
            $0.flippedPairCards.clear()
        }
    
        await clock.advance(by: .seconds(0.5))
        await store.receive(.timerTicked) {
            $0.gameDuration = .seconds(4)
        }
        await store.receive(.showMatch(id1: UUID(2), id2: UUID(3))) {
            $0.cards[id: UUID(2)]?.isPaired = true
            $0.cards[id: UUID(3)]?.isPaired = true
        }
        
        await clock.advance(by: .seconds(0.4))
        await store.receive(.completeLevel(.one)) {
            $0.showLevelDetails = .init(completedLevel: .one, difficulty: .easy, gameDuration: .seconds(4))
        }
    }

}
