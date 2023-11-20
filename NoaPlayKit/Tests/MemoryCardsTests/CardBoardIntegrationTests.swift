//
//  CardBoardIntegrationTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-03.
//

import XCTest
@testable import MemoryCards
import ComposableArchitecture

@MainActor
final class CardBoardIntegrationTests: XCTestCase {

    func testGoToNextLevel() async {
        let store = TestStore<CardBoard.State, CardBoard.Action>(
            initialState: CardBoard.State(
                mode: .timer,
                difficulty: .easy,
                style: .numbers,
                level: .one
            )
        ) {
            CardBoard()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.dataGenerator = .mock
            $0.continuousClock = ImmediateClock()
            $0.gameDurationFormatter = .mock
        }
        
        store.exhaustivity = .off(showSkippedAssertions: false)
        
        await store.send(.cards(.element(id: UUID(0), action: .delegate(.attemptToFlipCard(id: UUID(0))))))
        await store.send(.cards(.element(id: UUID(1), action: .delegate(.attemptToFlipCard(id: UUID(1))))))
        await store.receive(.showMatch(id1: UUID(0), id2: UUID(1)))
        
        await store.send(.cards(.element(id: UUID(2), action: .delegate(.attemptToFlipCard(id: UUID(2))))))
        await store.send(.cards(.element(id: UUID(3), action: .delegate(.attemptToFlipCard(id: UUID(3))))))
        await store.receive(.showMatch(id1: UUID(2), id2: UUID(3)))
        
        await store.receive(.completeLevel(.one))
        
        await store.send(.showLevelDetails(.delegate(.loadGameLevel(.two)))) {
            $0.showLevelDetails = nil
            $0.gameDuration = .seconds(0)
            $0.didStartGame = false
            $0.level = .two
            $0.flippedPairCards = .init(matching: { $0.value == $1.value })
            $0.cards = [
                .init(id: UUID(4), style: .number("1")),
                .init(id: UUID(5), style: .number("1")),
                .init(id: UUID(6), style: .number("2")),
                .init(id: UUID(7), style: .number("2")),
                .init(id: UUID(8), style: .number("3")),
                .init(id: UUID(9), style: .number("3")),
                .init(id: UUID(10), style: .number("4")),
                .init(id: UUID(11), style: .number("4"))
            ]
        }
    }
    
    func testTrySameLevelAgain() async {
        let store = TestStore<CardBoard.State, CardBoard.Action>(
            initialState: CardBoard.State(
                mode: .timer,
                difficulty: .easy,
                style: .numbers,
                level: .one
            )
        ) {
            CardBoard()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.dataGenerator = .mock
            $0.continuousClock = ImmediateClock()
            $0.gameDurationFormatter = .mock
        }
        
        store.exhaustivity = .off(showSkippedAssertions: false)
        
        await store.send(.cards(.element(id: UUID(0), action: .delegate(.attemptToFlipCard(id: UUID(0))))))
        await store.send(.cards(.element(id: UUID(1), action: .delegate(.attemptToFlipCard(id: UUID(1))))))
        await store.receive(.showMatch(id1: UUID(0), id2: UUID(1)))
        
        await store.send(.cards(.element(id: UUID(2), action: .delegate(.attemptToFlipCard(id: UUID(2))))))
        await store.send(.cards(.element(id: UUID(3), action: .delegate(.attemptToFlipCard(id: UUID(3))))))
        await store.receive(.showMatch(id1: UUID(2), id2: UUID(3)))
        
        await store.receive(.completeLevel(.one))
        
        await store.send(.showLevelDetails(.delegate(.loadGameLevel(.one)))) {
            $0.showLevelDetails = nil
            $0.gameDuration = .seconds(0)
            $0.didStartGame = false
            $0.level = .one
            $0.flippedPairCards = .init(matching: { $0.value == $1.value })
            $0.cards = [
                .init(id: UUID(4), style: .number("1")),
                .init(id: UUID(5), style: .number("1")),
                .init(id: UUID(6), style: .number("2")),
                .init(id: UUID(7), style: .number("2"))
            ]
        }
    }
    
    func testFinishGame() async {
        let store = TestStore<CardBoard.State, CardBoard.Action>(
            initialState: CardBoard.State(
                mode: .timer,
                difficulty: .easy,
                style: .numbers,
                level: .one
            )
        ) {
            CardBoard()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.dataGenerator = .mock
            $0.continuousClock = ImmediateClock()
            $0.gameDurationFormatter = .mock
        }
        
        store.exhaustivity = .off(showSkippedAssertions: false)
        
        await store.send(.cards(.element(id: UUID(0), action: .delegate(.attemptToFlipCard(id: UUID(0))))))
        await store.send(.cards(.element(id: UUID(1), action: .delegate(.attemptToFlipCard(id: UUID(1))))))
        await store.receive(.showMatch(id1: UUID(0), id2: UUID(1)))
        
        await store.send(.cards(.element(id: UUID(2), action: .delegate(.attemptToFlipCard(id: UUID(2))))))
        await store.send(.cards(.element(id: UUID(3), action: .delegate(.attemptToFlipCard(id: UUID(3))))))
        await store.receive(.showMatch(id1: UUID(2), id2: UUID(3)))
        
        await store.receive(.completeLevel(.one))
        
        await store.send(.showLevelDetails(.delegate(.finishGame))) {
            $0.showLevelDetails = nil
            $0.gameDuration = .seconds(0)
            $0.didStartGame = false
        }
    }

}
