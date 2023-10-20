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
        let number: String
        var isFlipped: Bool
        var isPaired: Bool
        
        init(
            number: String,
            isFlipped: Bool = false,
            isPaired: Bool = false
        ) {
            @Dependency(\.uuid) var uuid
            self.id = uuid()
            self.number = number
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
                    .fill(viewStore.isPaired ? Color("PairedCardColor") : .yellow)
//                    .borderOverlay(
//                        lineWidth: viewStore.isPaired ? 10 : 0,
//                        cornerRadius: 20,
//                        color: viewStore.isPaired ? .red : .yellow
//                    )
                    .shadow(radius: 5)

                Text(viewStore.number)
                    .font(.largeTitle.bold())
                    .opacity(viewStore.isFlipped ? 1.0 : 0.0)
            }
            .cardFlipEffect(isFaceUp: viewStore.isFlipped)
            .scaleBounceEffect(viewStore.isPaired ? 1.2 : 1)
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
                number: "2",
                isFlipped: true,
                isPaired: true
            )
        ) {
            MemoryCard()
        }
    )
}
