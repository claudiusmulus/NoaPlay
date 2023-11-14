//
//  CardTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-01.
//

import XCTest
@testable import MemoryCards
import ComposableArchitecture

@MainActor
final class CardTests: XCTestCase {

    func testFlipCard() async {
        let store = TestStore<Card.State, Card.Action>(
            initialState: Card.State(style: .number("1"))
        ) {
            Card()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        await store.send(.flippedCardTapped)
        await store.receive(.delegate(.attemptToFlipCard(id: UUID(0))))
    }

}
