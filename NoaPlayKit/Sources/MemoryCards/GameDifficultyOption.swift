//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-16.
//

import ComposableArchitecture
import SwiftUI
import Models
import Foundation

public struct GameDifficultySection: Reducer {
    public struct State: Equatable {
        let title: String
        let height: CGFloat
        let availableOptions: [MemoryCardGame.Difficulty]
        var selectedOption: MemoryCardGame.Difficulty
        
        public init(
            title: String,
            height: CGFloat = 140.0,
            availableOptions: [MemoryCardGame.Difficulty],
            selectedOption: MemoryCardGame.Difficulty
        ) {
            self.title = title
            self.height = height
            self.availableOptions = availableOptions
            self.selectedOption = selectedOption
        }
    }
    
    public enum Action: Equatable {
        case selectDifficultyTapped(MemoryCardGame.Difficulty)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .selectDifficultyTapped(difficulty):
                if difficulty != state.selectedOption {
                    state.selectedOption = difficulty
                }
                return .none
            }
        }
    }
}


struct GameDifficultyOptionView: View {
    let store: StoreOf<GameDifficultySection>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            GameOptionSection(
                title: viewStore.title,
                options: viewStore.availableOptions,
                isSelected: { $0 == viewStore.selectedOption },
                action: {
                    viewStore.send(.selectDifficultyTapped($0), animation: .bouncy)
                }
            ) { difficultyLevel in
                VStack(spacing: 10) {
                    Text(difficultyLevel.title)
                        .font(.system(.largeTitle).bold())
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .fontWeight(.heavy)
                        .foregroundStyle(difficultyLevel == viewStore.selectedOption ? Color.actionPrimary  : .white)
                }
                .padding(.horizontal)
            }
        }
    }
}
#Preview {
    VStack(spacing: 0) {
        ScrollView {
            Section {
                GameDifficultyOptionView(store: .init(
                    initialState: GameDifficultySection.State.init(
                        title: "Difficulty",
                        availableOptions: MemoryCardGame.Difficulty.allCases,
                        selectedOption: .easy
                    ),
                    reducer: {
                        GameDifficultySection()
                    })
                )
                .padding()
            }
        }
    }
}
