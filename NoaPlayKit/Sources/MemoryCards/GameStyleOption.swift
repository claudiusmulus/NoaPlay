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

public struct GameStyleSection: Reducer {
    public struct State: Equatable {
        let title: String
        let height: CGFloat
        let availableStyles: [MemoryCardGame.Style]
        var selectedStyle: MemoryCardGame.Style
        
        public init(
            title: String,
            height: CGFloat = 140.0,
            availableStyles: [MemoryCardGame.Style],
            selectedStyle: MemoryCardGame.Style
        ) {
            self.title = title
            self.height = height
            self.availableStyles = availableStyles
            self.selectedStyle = selectedStyle
        }
    }
    
    public enum Action: Equatable {
        case selectStyleTapped(MemoryCardGame.Style)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .selectStyleTapped(style):
                if style != state.selectedStyle {
                    state.selectedStyle = style
                }
                return .none
            }
        }
    }
}


struct GameStyleOptionView: View {
    let store: StoreOf<GameStyleSection>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            GameOptionSection(
                title: viewStore.title,
                options: viewStore.availableStyles,
                isSelected: { $0 == viewStore.selectedStyle },
                action: {
                    viewStore.send(.selectStyleTapped($0), animation: .bouncy)
                }
            ) { style in
                VStack(spacing: 10) {
                    Text(style.title)
                        .font(.system(.largeTitle).bold())
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .fontWeight(.heavy)
                        .foregroundStyle(style == viewStore.selectedStyle ? Color.actionPrimary  : .white)
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
                GameStyleOptionView(store: .init(
                    initialState: GameStyleSection.State.init(
                        title: "Game style",
                        availableStyles: MemoryCardGame.Style.allCases,
                        selectedStyle: .numbers
                    ),
                    reducer: {
                        GameStyleSection()
                    })
                )
                .padding()
            }
        }
    }
}
