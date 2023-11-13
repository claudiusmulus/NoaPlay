//
//  MemoryCardLevelDetails.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-25.
//

import SwiftUI
import Models
import VisualComponents
import ComposableArchitecture

public struct LevelDetails: Reducer {
    
    public struct State: Equatable {
        let completedLevel: MemoryCardGame.Level
        let difficulty: MemoryCardGame.Difficulty
        let gameDuration: String?
        
        public init(
            completedLevel: MemoryCardGame.Level,
            difficulty: MemoryCardGame.Difficulty,
            gameDuration: Duration?
        ) {
            @Dependency(\.gameDurationFormatter) var gameDurationFormatter
            
            self.completedLevel = completedLevel
            self.difficulty = difficulty
            if let gameDuration {
                self.gameDuration = gameDurationFormatter.formatGameDuration(gameDuration, .details)
            } else {
                self.gameDuration = nil
            }
        }
    }
    
    public enum Action: Equatable {
        
        case delegate(Delegate)
        
        case goToNextLevelButtonTapped
        case tryCurrentLevelButtonTapped
        case finishGameButtonTapped
        
        public enum Delegate: Equatable {
            case loadGameLevel(MemoryCardGame.Level)
            case finishGame
        }
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.dataGenerator) var cardsGenerator
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case .goToNextLevelButtonTapped:
                if let nextLevel = cardsGenerator.nextLevel(state.completedLevel, state.difficulty) {
                    return .run { send in
                        await send(
                            .delegate(.loadGameLevel(nextLevel)),
                            animation: .easeInOut(duration: 0.4)
                        )
                    }
                } else {
                    // TODO. Handle no more levels. Shouldn't happen
                    return .none
                }
            case .tryCurrentLevelButtonTapped:
                return .run { [currentLevel = state.completedLevel] send in
                    await send(
                        .delegate(.loadGameLevel(currentLevel)),
                        animation: .easeInOut(duration: 0.4)
                    )
                }
            case .finishGameButtonTapped:
                return .run { send in
                    await send(.delegate(.finishGame), animation: .easeInOut(duration: 0.4))
                }
            }
        }
    }
}

struct LevelDetailsView: View {
    let store: StoreOf<LevelDetails>
    @State private var isScalling = false
    
    @State private var isBackgroundAppear = false
    @State private var isImageAppear = false
    @State private var isMessageAppear = false
    @State private var isActionButtonsAppear = false
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color(viewStore.completedLevel.colors.background)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            Image(systemName: "trophy.circle.fill")
                                .font(.system(size: 96))
                            
                            Text("Hurray! You completed \(viewStore.completedLevel.message)")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.center)
                            
                            if let gameDuration = viewStore.gameDuration {
                                Text("Duration: " + gameDuration)
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .safeAreaInset(edge: .top, content: {
                        ZStack(alignment: .top) {
                            Button(
                                action: {
                                    viewStore.send(.finishGameButtonTapped)
                                },
                                label: {
                                    Image(systemName: "xmark.circle")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundStyle(.black)
                                }
                            )
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .topTrailing)
                            .background(viewStore.completedLevel.colors.background)
                            .background(ignoresSafeAreaEdges: .top)
                        }
                    })
                    
                    HStack {
                        ScaledButton(
                            color: viewStore.completedLevel.colors.details,
                            shadowColor: viewStore.completedLevel.colors.background,
                            action: {
                                viewStore.send(.goToNextLevelButtonTapped)
                            }
                        ) {
                            HStack(spacing: 20) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 35).bold())
                                Text("Next Level")
                                    .lineLimit(1)
                                    .font(.system(size: 35).bold())
                                    .minimumScaleFactor(0.2)
                            }
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                        }
                        .padding([.leading], 20)
                        .padding(.trailing, 10)
                        
                        ScaledButton(
                            color: viewStore.completedLevel.colors.details,
                            shadowColor: viewStore.completedLevel.colors.background,
                            action: {
                                viewStore.send(.tryCurrentLevelButtonTapped)
                            }
                        ) {
                            HStack(spacing: 20) {
                                Image(systemName: "arrow.up.circle")
                                    .font(.system(size: 35).bold())
                                Text("Try again")
                                    .lineLimit(1)
                                    .font(.system(size: 35).bold())
                                    .minimumScaleFactor(0.2)
                            }
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                        }
                        .padding([.trailing], 20)
                        .padding(.leading, 10)
                        
                    }
                    .padding(.vertical, 20)
                    .background(
                        Color(viewStore.completedLevel.colors.backCard)
                    )
                    .background(ignoresSafeAreaEdges: .bottom)
                }
            }
        }
    }
    
    private func verticalActionView(
        viewStore: ViewStoreOf<LevelDetails>
    ) -> some View {
        VStack(spacing: 20) {
            ScaledButton(
                color: viewStore.completedLevel.colors.details,
                shadowColor: viewStore.completedLevel.colors.background,
                action: {
                    self.animateDissapear()
                    viewStore.send(.goToNextLevelButtonTapped)
                }
            ) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 25).bold())
                    Text("Next Level")
                        .lineLimit(1)
                        .font(.title3.bold())
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
            }
            
            ScaledButton(
                color: viewStore.completedLevel.colors.details,
                shadowColor: viewStore.completedLevel.colors.background,
                action: {
                    self.animateDissapear()
                    viewStore.send(.tryCurrentLevelButtonTapped)
                }
            ) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.up.circle")
                        .font(.system(size: 25).bold())
                    Text("Try again")
                        .lineLimit(1)
                        .font(.title3.bold())
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
            }
            
            ScaledButton(
                color: viewStore.completedLevel.colors.details,
                shadowColor: viewStore.completedLevel.colors.background,
                action: {
                    viewStore.send(.finishGameButtonTapped)
                }
            ) {
                HStack(spacing: 10) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 25).bold())
                    Text("Finish")
                        .lineLimit(1)
                        .font(.title3.bold())
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
    
    private func horizontalActionView(
        viewStore: ViewStoreOf<LevelDetails>
    ) -> some View {
        HStack(spacing: 10) {
            VStack {
                ScaledButton(
                    color: viewStore.completedLevel.colors.details,
                    shadowColor: viewStore.completedLevel.colors.background,
                    action: {
                        self.animateDissapear()
                        viewStore.send(.goToNextLevelButtonTapped)
                    }
                ) {
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 50).bold())
                        Text("Next Level")
                            .font(.title.bold())
                    }
                    .padding(20)
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
            }
            
            VStack {
                ScaledButton(
                    color: viewStore.completedLevel.colors.details,
                    shadowColor: viewStore.completedLevel.colors.background,
                    action: {
                        self.animateDissapear()
                        viewStore.send(.tryCurrentLevelButtonTapped)
                    }
                ) {
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: 50).bold())
                        Text("Try again")
                            .font(.title.bold())
                    }
                    .padding(20)
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
            }
            
            VStack {
                ScaledButton(
                    color: viewStore.completedLevel.colors.details,
                    shadowColor: viewStore.completedLevel.colors.background,
                    action: {
                        viewStore.send(.finishGameButtonTapped)
                    }
                ) {
                    VStack(spacing: 10) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 50).bold())
                        Text("Finish")
                            .font(.title.bold())
                    }
                    .padding(20)
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
            }

        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    func animateDissapear() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isImageAppear = false
            self.isMessageAppear = false
            self.isActionButtonsAppear = false
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isBackgroundAppear = false
            self.isScalling = false
        }
    }
}

#Preview {
    LevelDetailsView(
        store: .init(
            initialState: LevelDetails.State(
                completedLevel: .one,
                difficulty: .easy,
                gameDuration: .seconds(3600)
            )
        ){
            LevelDetails()
        }
    )
}
