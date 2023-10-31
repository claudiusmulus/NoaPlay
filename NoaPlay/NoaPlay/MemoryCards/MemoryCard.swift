//
//  CardView.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//

import SwiftUI
import ComposableArchitecture

struct MemoryCard: Reducer {
    
    struct State: Equatable, Identifiable {
        let id: UUID
        let style: MemoryCardGame.CardStyle
        let colors: MemoryCardGame.Level.Colors
        //let number: String
        var isFlipped: Bool
        var isPaired: Bool
        
        init(
            style: MemoryCardGame.CardStyle,
            colors: MemoryCardGame.Level.Colors,
            isFlipped: Bool = false,
            isPaired: Bool = false
        ) {
            @Dependency(\.uuid) var uuid
            self.id = uuid()
            self.style = style
            self.colors = colors
            self.isFlipped = isFlipped
            self.isPaired = isPaired
        }
        
    }
    enum Action: Equatable {
        case delegate(Delegate)
        case flippedCardTapped
        enum Delegate: Equatable {
            case attemptToFlipCard(id: MemoryCard.State.ID)
        }
    }
    var body: some Reducer<State, Action> {
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

struct MemoryCardView: View {
    let store: StoreOf<MemoryCard>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(viewStore.colors.frontCard)
                    .overlay {
                        ZStack {
                            LinearGradient(colors: [Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)), Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5086403146)).opacity(0.5), Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .cornerRadius(20)
                            .opacity(viewStore.isPaired ? 1 : 0)
                        }
                    }
                    //.fill(viewStore.isPaired ? Color("PairedCardColor") : .yellow)
//                    .borderOverlay(
//                        lineWidth: viewStore.isPaired ? 10 : 0,
//                        cornerRadius: 20,
//                        color: viewStore.isPaired ? .red : .yellow
//                    )
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
                backgroundColor: viewStore.colors.backCard,
                borderColor: viewStore.colors.details
            )
            //.scaleBounceEffect(viewStore.isPaired ? 1.2 : 1)
            .scaleBounceEffect_1(1.15, trigger: viewStore.isPaired)
            .onTapGesture {
                viewStore.send(.flippedCardTapped)
            }
        }
        
    }
}

#Preview {
    MemoryCardView(
        store: .init(
            initialState: MemoryCard.State(
                style: .number("2"), 
                colors: .level("1"),
                isFlipped: true,
                isPaired: true
            )
        ) {
            MemoryCard()
        }
    )
}
