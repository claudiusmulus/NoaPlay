//
//  LevelDetailsTests.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-02.
//

import XCTest
@testable import MemoryCards
import ComposableArchitecture

@MainActor
final class LevelDetailsTests: XCTestCase {

    func testMoveToNextLevel() async {
        let store = TestStore<LevelDetails.State, LevelDetails.Action>(
            initialState: LevelDetails.State(
                completedLevel: .one,
                difficulty: .easy,
                gameDuration: .seconds(5)
            )
        ) {
            LevelDetails()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.gameDurationFormatter = .mock
            $0.dataGenerator = .mock
        }
        
        await store.send(.goToNextLevelButtonTapped)
        
        await store.receive(.delegate(.loadGameLevel(.two)))
    }
    
    func testRetrySameLevel() async {
        let store = TestStore<LevelDetails.State, LevelDetails.Action>(
            initialState: LevelDetails.State(
                completedLevel: .one,
                difficulty: .easy,
                gameDuration: .seconds(5)
            )
        ) {
            LevelDetails()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.gameDurationFormatter = .mock
            $0.dataGenerator = .mock
        }
        
        await store.send(.tryCurrentLevelButtonTapped)
        
        await store.receive(.delegate(.loadGameLevel(.one)))
    }
    
    func testFinishGame() async {
        let store = TestStore<LevelDetails.State, LevelDetails.Action>(
            initialState: LevelDetails.State(
                completedLevel: .one,
                difficulty: .easy,
                gameDuration: .seconds(5)
            )
        ) {
            LevelDetails()
        } withDependencies: {
            $0.uuid = .incrementing
            $0.gameDurationFormatter = .mock
            $0.dataGenerator = .mock
        }
        
        await store.send(.finishGameButtonTapped)
        
        await store.receive(.delegate(.finishGame))
    }

}
