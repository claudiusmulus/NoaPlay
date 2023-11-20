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
import Theme

public struct GameOptions: Reducer {
    public init() {
    }
    public struct State: Equatable {
        var modeSection: GameModeSection.State
        var styleSection: GameStyleSection.State
        var difficultySection: GameDifficultySection.State
        
        public init(
            modeSection: GameModeSection.State,
            styleSection: GameStyleSection.State,
            difficultySection: GameDifficultySection.State
        ) {
            self.modeSection = modeSection
            self.styleSection = styleSection
            self.difficultySection = difficultySection
        }
    }
    public enum Action: Equatable {
        case delegate(Delegate)
        case modeSection(GameModeSection.Action)
        case styleSection(GameStyleSection.Action)
        case difficultySection(GameDifficultySection.Action)
        case startGameButtonTapped
        
        public enum Delegate: Equatable {
            case startGame(
                mode: MemoryCardGame.Mode,
                style: MemoryCardGame.Style,
                difficulty: MemoryCardGame.Difficulty
            )
        }
    }
    
    public var body: some Reducer<State, Action> {
        
        Scope(state: \.modeSection, action: /Action.modeSection) {
            GameModeSection()
        }
        
        Scope(state: \.styleSection, action: /Action.styleSection) {
            GameStyleSection()
        }
        
        Scope(state: \.difficultySection, action: /Action.difficultySection) {
            GameDifficultySection()
        }
        
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .difficultySection:
                return .none
            case .startGameButtonTapped:
                return .run { 
                    [mode = state.modeSection.selectedMode,
                     style = state.styleSection.selectedStyle,
                     difficulty = state.difficultySection.selectedOption
                    ] send in
                    await send(.delegate(.startGame(mode: mode, style: style, difficulty: difficulty)))
                }
            case .modeSection:
                return .none
            case .styleSection:
                return .none
            }
        }
    }
}

public struct GameOptionsView: View {
    let store: StoreOf<GameOptions>
    
    public init(store: StoreOf<GameOptions>) {
        self.store = store
    }
    
    struct ViewStore: Equatable {
        init(state: GameOptions.State) {
        }
    }
    
    public var body: some View {
        
        WithViewStore(self.store, observe: ViewStore.init) { viewStore in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        Section {
                            GameModeSectionView(
                                store: self.store.scope(
                                    state: \.modeSection,
                                    action: { .modeSection($0)}
                                )
                            )
                            .padding(.leading, 40)
                            .padding(.top, 20)
                        }
                        
                        Section {
                            GameStyleOptionView(
                                store: self.store.scope(
                                    state: \.styleSection,
                                    action: { .styleSection($0)}
                                )
                            )
                            .padding(.leading, 40)
                        }

                        Section {
                            GameDifficultyOptionView(
                                store: self.store.scope(
                                    state: \.difficultySection,
                                    action: { .difficultySection($0)}
                                )
                            )
                            .padding([.leading, .bottom], 40)
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    
                    HStack {
                        ScaledButton(
                            color: .actionPrimary,
                            shadowColor: .white,
                            action: {
                                viewStore.send(.startGameButtonTapped)
                            }
                        ) {
                            HStack(spacing: 10) {
                                Image(systemName: "gamecontroller")
                                Text("Play")
                            }
                            .padding(.vertical, 10)
                            .font(.system(size: 40).bold())
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .background(Color.backgroundSecondary)
                    .background(ignoresSafeAreaEdges: .bottom)
                }
            }
        }
    }
}

#Preview {
    GameOptionsView(
        store: .init(
            initialState: GameOptions.State(
                modeSection: .init(title: "Game mode", availableModes: MemoryCardGame.Mode.allCases, selectedMode: .practice),
                styleSection: .init(title: "Game style", availableStyles: MemoryCardGame.Style.allCases, selectedStyle: .numbers),
                difficultySection: .init(title: "Difficulty", availableOptions: MemoryCardGame.Difficulty.allCases, selectedOption: .easy)
            )) {
                GameOptions()
            }
    )
}

#Preview("Landscape", traits: .landscapeLeft) {
    GameOptionsView(
        store: .init(
            initialState: GameOptions.State(
                modeSection: .init(title: "Game mode", availableModes: MemoryCardGame.Mode.allCases, selectedMode: .practice),
                styleSection: .init(title: "Game style", availableStyles: MemoryCardGame.Style.allCases, selectedStyle: .numbers),
                difficultySection: .init(title: "Difficulty", availableOptions: MemoryCardGame.Difficulty.allCases, selectedOption: .easy)
            )) {
                GameOptions()
            }
    )
}
