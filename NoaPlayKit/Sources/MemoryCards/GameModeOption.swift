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

public struct GameModeSection: Reducer {
    public struct State: Equatable {
        let title: String
        let height: CGFloat
        let availableModes: [MemoryCardGame.Mode]
        var selectedMode: MemoryCardGame.Mode
        
        public init(
            title: String,
            height: CGFloat = 140.0,
            availableModes: [MemoryCardGame.Mode],
            selectedMode: MemoryCardGame.Mode
        ) {
            self.title = title
            self.height = height
            self.availableModes = availableModes
            self.selectedMode = selectedMode
        }
    }
    
    public enum Action: Equatable {
        case selectModeTapped(MemoryCardGame.Mode)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .selectModeTapped(mode):
                if mode != state.selectedMode {
                    state.selectedMode = mode
                }
                return .none
            }
        }
    }
}

public struct GameModeSectionView: View {
    let store: StoreOf<GameModeSection>
    public init(store: StoreOf<GameModeSection>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            GameOptionSection(
                title: viewStore.title,
                options: viewStore.availableModes,
                isSelected: { $0 == viewStore.selectedMode },
                action: {
                    viewStore.send(.selectModeTapped($0), animation: .bouncy)
                }
            ) { mode in
                VStack(spacing: 10) {
                    Image(systemName: mode.iconName)
                        .font(.system(.largeTitle))
                    
                    Text(mode.title)
                        .font(.largeTitle.bold())
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                }
                .foregroundStyle(mode == viewStore.selectedMode ? Color.actionPrimary  : .white)
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ScrollView {
            Section {
                GameModeSectionView(store: .init(
                    initialState: GameModeSection.State.init(
                        title: "Game mode",
                        availableModes: MemoryCardGame.Mode.allCases,
                        selectedMode: .practice
                    ),
                    reducer: {
                        GameModeSection()
                    })
                )
                .padding()
            }
        }
    }
}
