//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-07.
//

import SwiftUI
import ComposableArchitecture
import Models
import VisualComponents

public struct Game: Reducer {
    public init() {}
    
    public struct State: Equatable {
        var gameOptions: GameOptions.State
        var path: StackState<Path.State>
        
        public init(
            gameOptions: GameOptions.State,
            path: StackState<Path.State> = StackState<Path.State>()
        ) {
            self.gameOptions = gameOptions
            self.path = path
        }
    }
    
    public enum Action: Equatable {
        case path(StackAction<Path.State, Path.Action>)
        case gameOptions(GameOptions.Action)
    }
    
    public struct Path: Reducer {
        public enum State: Equatable {
            case board(CardBoard.State)
        }
        public enum Action: Equatable {
            case board(CardBoard.Action)
        }
        public var body: some ReducerOf<Self> {
          Scope(state: /State.board, action: /Action.board) {
            CardBoard()
          }
        }
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.gameOptions, action: /Game.Action.gameOptions) {
            GameOptions()
        }
        Reduce { state, action in
            switch action {
            case let .gameOptions(.delegate(.startGame(mode, style, difficulty))):
                state.path.append(
                    .board(.init(mode: mode, difficulty: difficulty, style: style, level: difficulty.initialLevel()))
                )
                return .none
            case .path(.element(_, action: .board(.delegate(.finishGame)))):
                state.path.removeAll()
                return .none
            case .gameOptions:
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
          Path()
        }
    }
}

public struct GameView: View {
    public let store: StoreOf<Game>
    
    public init(store: StoreOf<Game>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            GameOptionsView(
                store: self.store.scope(state: \.gameOptions, action: { .gameOptions($0)})
            )
        } destination: { state in
            switch state {
            case .board:
                CaseLet(
                    /Game.Path.State.board,
                     action: Game.Path.Action.board
                ) { store in
                    CardBoardView(store: store)
                        .toolbar(.hidden)
                        .navigationBarBackButtonHidden()
                }
            }
        }
    }
}

#Preview {
    GameView(
        store: .init(
            initialState: Game.State(
                gameOptions: .init(
                    modeSection: .init(title: "Game mode", availableModes: MemoryCardGame.Mode.allCases, selectedMode: .practice),
                    styleSection: .init(title: "Game style", availableStyles: MemoryCardGame.Style.allCases, selectedStyle: .numbers),
                    difficultySection: .init(title: "Difficulty", availableOptions: MemoryCardGame.Difficulty.allCases, selectedOption: .easy)
                )
            )
        ) {
            Game()
        }
    )
}
