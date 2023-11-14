//
//  CardView.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//

import SwiftUI
import Models
import ComposableArchitecture
import VisualComponents

public struct Card: Reducer {
    public struct State: Equatable, Identifiable {
        public let id: UUID
        let style: MemoryCardGame.CardStyle
        var isFlipped: Bool
        var isPaired: Bool
        
        public init(
            style: MemoryCardGame.CardStyle,
            isFlipped: Bool = false,
            isPaired: Bool = false
        ) {
            @Dependency(\.uuid) var uuid
            self.id = uuid()
            self.style = style
            self.isFlipped = isFlipped
            self.isPaired = isPaired
        }
        
        #if DEBUG
        public init(
            id: UUID,
            style: MemoryCardGame.CardStyle,
            isFlipped: Bool = false,
            isPaired: Bool = false
        ) {
            self.id = id
            self.style = style
            self.isFlipped = isFlipped
            self.isPaired = isPaired
        }
        #endif
    }
    public enum Action: Equatable {
        case delegate(Delegate)
        case flippedCardTapped
        public enum Delegate: Equatable {
            case attemptToFlipCard(id: Card.State.ID)
        }
    }
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .flippedCardTapped:
                return .run { [cardId = state.id] send in
                    await send(.delegate(.attemptToFlipCard(id: cardId)), animation: .easeInOut(duration: 0.5))
                }
            }
        }
    }
}

struct CardView: View {
    let store: StoreOf<Card>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.cardFront)
                    .overlay {
                        ZStack {
                            LinearGradient(colors: [Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)), Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5086403146)).opacity(0.5), Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .cornerRadius(20)
                            .opacity(viewStore.isPaired ? 1 : 0)
                        }
                    }
                    .shadow(radius: 5)

                if case .image(_, _) = viewStore.style {
                    // Implement card with images
                    EmptyView()
                } else {
                    Text(viewStore.style.description)
                        .font(.system(size: 90).bold())
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .opacity(viewStore.isFlipped ? 1.0 : 0.0)
                }
            }
            .cardFlipEffect(
                isFaceUp: viewStore.isFlipped,
                backgroundColor: .onBackgroundPrimary,
                borderColor: .actionPrimary
            )
            .scaleBounceEffect(1.15, trigger: viewStore.isPaired)
            .onTapGesture {
                viewStore.send(.flippedCardTapped)
            }
        }
        
    }
}

#Preview {
    CardView(
        store: .init(
            initialState: Card.State(
                style: .number("2"), 
                isFlipped: true,
                isPaired: true
            )
        ) {
            Card()
        }
    )
}
