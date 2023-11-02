//
//  CardBoard.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//

import SwiftUI
import ComposableArchitecture
import Models
import FormattersClient

public struct CardBoard: Reducer {
    
    public init() {        
    }
    
    public struct State: Equatable {
        
        let mode: MemoryCardGame.Mode
        let difficulty: MemoryCardGame.Difficulty
        let style: MemoryCardGame.Style
        var level: MemoryCardGame.Level
        
        var gameDuration: Duration = .seconds(0)
        var didStartGame = false
        
        let showTimer: Bool
        
        var cards: IdentifiedArrayOf<Card.State>
        
        public init(
            mode: MemoryCardGame.Mode,
            difficulty: MemoryCardGame.Difficulty,
            style: MemoryCardGame.Style,
            level: MemoryCardGame.Level
        ) {
            self.mode = mode
            self.difficulty = difficulty
            self.style = style
            
            self.showTimer = mode == .default
            self.level = level
            self.cards = level.availableCards(style: style)
        }
        
        var showLevelDetails: LevelDetails.State?
        
        var flippedPairCards: PairMatch<FlippedCard> = PairMatch<FlippedCard>(
            matching: { $0.value == $1.value}
        )
        
        var unPairedCards: IdentifiedArrayOf<Card.State> {
            cards.filter { !$0.isPaired }
        }
        
        mutating func reset(
            level: MemoryCardGame.Level
        ) {
            self.level = level
            self.cards = level.availableCards(style: self.style)
            self.flippedPairCards.clear()
        }
        
        func formattedGameDuration() -> String {
            @Dependency(\.gameDurationFormatter) var gameDurationFormatter
            
            return gameDurationFormatter.formatGameDuration(self.gameDuration, .timer)
        }
    }
    
    struct FlippedCard: Equatable {
        let id: UUID
        let value: String
    }
    
    public enum Action: Equatable {
        case card(id: Card.State.ID, action: Card.Action)
        case showLevelDetails(LevelDetails.Action)
        case flipCard(id: Card.State.ID, value: String)
        case unflippedPair(id1: Card.State.ID, id2: Card.State.ID)
        case showMatch(id1: Card.State.ID, id2: Card.State.ID)
        case completeLevel(MemoryCardGame.Level)
        case timerTicked
    }
    
    @Dependency(\.continuousClock) var clock
    
    private enum CancelID {
        case showPairMatch
        case selectCardAfterPairUnflipped
        case unflipPairAfterUnmatch
        case gameTimer
    }
        
    public var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case let .card(_, .delegate(delegateAction)):
                let delegateEffect = self.reduceDelegateAction(state: &state, action: delegateAction)
                guard !state.didStartGame else {
                    return delegateEffect
                }
                state.didStartGame = true
                guard state.mode == .default else {
                    return delegateEffect
                }
                return .merge(
                    delegateEffect,
                    .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.timerTicked)
                        }
                    }
                    .cancellable(id: CancelID.gameTimer, cancelInFlight: true)
                )
                
            case .card:
                return .none
            case let .flipCard(id, value):
                state.flippedPairCards.add(.init(id: id, value: value))
                state.cards[id: id]?.isFlipped = true
                
                return .none

            case let .showMatch(id1, id2):
                state.cards[id: id1]?.isPaired = true
                state.cards[id: id2]?.isPaired = true
                
                if state.unPairedCards.isEmpty {
                    return .run { [currentLevel = state.level] send in
                        try await self.clock.sleep(for: .seconds(0.4))
                        await send(.completeLevel(currentLevel))
                    }
                }
                
                return .none
            case let .unflippedPair(id1, id2):
                state.flippedPairCards.clear()
                state.cards[id: id1]?.isFlipped = false
                state.cards[id: id2]?.isFlipped = false
                return .none
                
            case let .showLevelDetails(.delegate(.loadGameLevel(newGameLevel))):
                state.showLevelDetails = nil
                state.gameDuration = .seconds(0)
                state.didStartGame = false

                state.reset(level: newGameLevel)
                return .none
                                
            case .showLevelDetails(.delegate(.finishGame)):
                // TODO.
                state.showLevelDetails = nil
                return .none
            case .showLevelDetails(_):
                return .none
                
            case let .completeLevel(level):
                state.showLevelDetails = .init(
                    completedLevel: level,
                    difficulty: state.difficulty,
                    gameDuration: state.mode == .default ? state.gameDuration : nil
                )
                return .cancel(id: CancelID.gameTimer)
                
            case .timerTicked:
                guard state.showLevelDetails == nil && state.didStartGame else {
                    return .none
                }
                state.gameDuration = state.gameDuration + .seconds(1)
                
                return .none
            }
        }
        .forEach(\.cards, action: /CardBoard.Action.card) {
            Card()
        }
        .ifLet(\.showLevelDetails, action: /Action.showLevelDetails) {
            LevelDetails()
        }
        ._printChanges()
    }
    
    // MARK: - Utils
    private func reduceDelegateAction(
        state: inout State,
        action: Card.Action.Delegate
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
                        .flipCard(id: selectedCard.id, value: selectedCard.style.description),
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
                .init(id: card.id, value: card.style.description)
            )
            
            if let pairMatch = state.flippedPairCards.pairMatch() {
                state.flippedPairCards.clear()
                return .run { send in
                    try await self.clock.sleep(for: .seconds(0.5))
                    await send(
                        .showMatch(
                            id1: pairMatch.firstElement.id,
                            id2: pairMatch.secondElement.id
                        )
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

public struct CardBoardView: View {
    let store: StoreOf<CardBoard>
    
    public init(store: StoreOf<CardBoard>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        let cards: IdentifiedArrayOf<Card.State>
        let level: MemoryCardGame.Level
        let showTimer: Bool
        let gameDuration: String
        let didStartGame: Bool
        
        init(state: CardBoard.State) {
            self.cards = state.cards
            self.level = state.level
            self.showTimer = state.showTimer
            self.didStartGame = state.didStartGame
            self.gameDuration = state.formattedGameDuration()
        }
    }
    
    public var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: ViewState.init) { viewStore in
                ScrollView {
                    LazyVGrid(
                        columns: [
                            .init(.adaptive(minimum: 150, maximum: 220), spacing: 30),
                        ],
                        spacing: 30
                    ) {
                        ForEachStore(
                            store.scope(
                                state: \.cards,
                                action: CardBoard.Action.card
                            )
                        ) { store in
                            CardView(store: store)
                                .frame(height: 200)
                        }
                    }
                    .padding(30)
                }
                .safeAreaInset(edge: .top, content: {
                    if viewStore.showTimer {
                        HStack(spacing: 10) {
                            Image(systemName: viewStore.didStartGame ? "clock.fill" : "clock")
                                .contentTransition(.symbolEffect(.replace))
                            
                            Text(viewStore.gameDuration)
                            
                        }
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(viewStore.level.colors.details)
                        .background(ignoresSafeAreaEdges: .top)
                    }
                })
                .background(
                    viewStore.level.colors.background
                )
                .showDetails(
                    store: self.store.scope(state: \.showLevelDetails, action: { .showLevelDetails($0)})
                ) { store in
                    LevelDetailsView(store: store)
                }
            }
        }
    }
}

extension View {

    func showDetails<State, Action, Content: View>(
        store: Store<State?, Action>,
        @ViewBuilder content: @escaping (_ store: Store<State, Action>) -> Content
    ) -> some View {
        ZStack {
            self
            IfLetStore(store) { store in
                content(store)
            }
            .zIndex(1.0)
        }
    }
    func customModal<EnumState, EnumAction, CaseState, CaseAction, Content: View>(
      store: Store<EnumState?, EnumAction>,
      state toCaseState: @escaping (EnumState) -> CaseState?,
      action fromCaseAction: @escaping (CaseAction) -> EnumAction,
      @ViewBuilder content: @escaping (_ store: Store<CaseState, CaseAction>) -> Content
    ) -> some View {
        ZStack {
            self
            IfLetStore(store) { store in
                SwitchStore(store) { state in
                    CaseLet(
                        toCaseState,
                        action: fromCaseAction) { store in
                            content(store)
                        }
                }
            }
            .zIndex(1.0)
        }
    }
}

#Preview("Portrait", traits: .portrait) {
    CardBoardView(
        store: .init(
            initialState: CardBoard.State(
                mode: .default,
                difficulty: .easy,
                style: .numbers,
                level: .one
            )
        ) {
            CardBoard()
        }
    )
}

#Preview("Landscape", traits: .landscapeLeft) {
    CardBoardView(
        store: .init(
            initialState: CardBoard.State(
                mode: .practice,
                difficulty: .easy,
                style: .letters,
                level: .one
            )
        ) {
            CardBoard()
        }
    )
}

