//
//  CardBoard.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//

import SwiftUI
import ComposableArchitecture

struct MemoryCardBoard: Reducer {
    struct State: Equatable {
        var cards: IdentifiedArrayOf<MemoryCard.State>

        var flippedPairCards: PairMatch<FlippedCard> = PairMatch<FlippedCard>(
            matching: { $0.number == $1.number}
        )
        
        var unPairedCards: IdentifiedArrayOf<MemoryCard.State> {
            cards.filter(\.isPaired)
        }
    }
    
    struct FlippedCard: Equatable {
        let id: UUID
        let number: String
    }
    
    enum Action: Equatable {
        case card(id: MemoryCard.State.ID, action: MemoryCard.Action)
        case flipCard(id: MemoryCard.State.ID, number: String)
        case unflippedPair(id1: MemoryCard.State.ID, id2: MemoryCard.State.ID)
        case showMatch(id1: MemoryCard.State.ID, id2: MemoryCard.State.ID)
    }
    
    @Dependency(\.continuousClock) var clock

    private enum CancelID {
        case showPairMatch
        case selectCardAfterPairUnflipped
        case unflipPairAfterUnmatch
    }
        
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case let .card(_, .delegate(delegateAction)):
                return self.reduceDelegateAction(state: &state, action: delegateAction)
            case .card:
                return .none
            case let .flipCard(id, number):
                state.flippedPairCards.add(.init(id: id, number: number))
                state.cards[id: id]?.isFlipped = true
                return .none
            case let .showMatch(id1, id2):
                state.cards[id: id1]?.isPaired = true
                state.cards[id: id2]?.isPaired = true
                
                if state.unPairedCards.isEmpty {
                    // TODO. Complete game
                }
                
                return .none
            case let .unflippedPair(id1, id2):
                state.flippedPairCards.clear()
                state.cards[id: id1]?.isFlipped = false
                state.cards[id: id2]?.isFlipped = false
                return .none
            }
        }
        .forEach(\.cards, action: /MemoryCardBoard.Action.card) {
            MemoryCard()
        }
        ._printChanges()
    }
    
    // MARK: - Utils
    private func reduceDelegateAction(
        state: inout State,
        action: MemoryCard.Action.Delegate
    ) -> Effect<Action> {
        switch action {
        case let .attemptToFlipCard(id):
            guard let card = state.cards[id: id], !card.isFlipped, !card.isPaired else {
                return .none
            }
           
            if let currentPair = state.flippedPairCards.currentPair() {
                state.flippedPairCards.clear()
                
                if let firstCard = state.cards[id: currentPair.firstElement.id], !firstCard.isPaired {
                    state.cards[id: currentPair.firstElement.id]?.isFlipped = false
                }
                if let secondCard = state.cards[id: currentPair.secondElement.id], !secondCard.isPaired {
                    state.cards[id: currentPair.secondElement.id]?.isFlipped = false
                }
                
                let selectCardAfterPairUnflippedEffect = Effect<Action>.run { [selectedCard = card] send in
                    try await self.clock.sleep(for: .seconds(0.3))
                    
                    await send(
                        .flipCard(id: selectedCard.id, number: selectedCard.number),
                        animation: .easeInOut
                    )
                }
                .cancellable(id: CancelID.selectCardAfterPairUnflipped, cancelInFlight: true)
                
                return .merge(
                    selectCardAfterPairUnflippedEffect,
                    .cancel(id: CancelID.unflipPairAfterUnmatch)
                )
            }
            
            state.cards[id: id]?.isFlipped = true
            
            state.flippedPairCards.add(
                .init(id: card.id, number: card.number)
            )
            
            if let pairMatch = state.flippedPairCards.pairMatch() {
                state.flippedPairCards.clear()
                return .run { send in
                    try await self.clock.sleep(for: .seconds(0.5))
                    await send(
                        .showMatch(
                            id1: pairMatch.firstElement.id,
                            id2: pairMatch.secondElement.id
                        ),
                        animation: .easeInOut
                    )
                }
                .cancellable(id: CancelID.showPairMatch, cancelInFlight: true)
            } else if let currentPair = state.flippedPairCards.currentPair() {
                return .run { send in
                    try await self.clock.sleep(for: .seconds(2))
                    
                    await send(
                        .unflippedPair(
                            id1: currentPair.firstElement.id,
                            id2: currentPair.secondElement.id
                        ),
                        animation: .easeInOut
                    )
                }
                .cancellable(id: CancelID.unflipPairAfterUnmatch, cancelInFlight: true)
            } else {
                return .none
            }
        }
    }
}

struct CardBoard: View {
    let store: StoreOf<MemoryCardBoard>
    
    var body: some View {
        WithViewStore(self.store, observe: \.cards) { viewStore in
            ScrollView {
                LazyVGrid(
                    columns: [
                        .init(.fixed(150), spacing: 20),
                        .init(.fixed(150), spacing: 20)
                    ],
                    spacing: 20
                ) {
                    ForEachStore(
                        store.scope(
                            state: \.cards,
                            action: MemoryCardBoard.Action.card
                        )
                    ) { store in
                        MemoryCardView(store: store)
                            .frame(height: 200)
                    }
                }
            }
        }

    }
}

#Preview {
    CardBoard(
        store: .init(
            initialState: MemoryCardBoard.State(
                cards: .mock
            )
        ) {
            MemoryCardBoard()
        }
    )
}
