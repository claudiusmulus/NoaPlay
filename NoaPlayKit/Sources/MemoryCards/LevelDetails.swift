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
    @Dependency(\.cardsGenerator) var cardsGenerator
    
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
                    await send(.delegate(.finishGame))
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
                Color(viewStore.completedLevel.colors.details)
                    .opacity(0.5)
                    .overlay(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .opacity(self.isBackgroundAppear ? 1 : 0)
                
                VStack(spacing: 20) {
                    Image(systemName: "trophy.circle.fill")
                        .font(.system(size: 96))
                        .foregroundStyle(.white)
                        .opacity(self.isImageAppear ? 1 : 0)
                    
                    Text("Hurray! You completed \(viewStore.completedLevel.message)")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .opacity(self.isMessageAppear ? 1 : 0)
                    
                    if let gameDuration = viewStore.gameDuration {
                        Text("Duration: " + gameDuration)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                            .opacity(self.isMessageAppear ? 1 : 0)
                    }
                    
                    ViewThatFits {
                        horizontalActionView(viewStore: viewStore)
                        verticalActionView(viewStore: viewStore)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                    .opacity(self.isActionButtonsAppear ? 1 : 0)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 80)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(viewStore.completedLevel.colors.details)
                        .opacity(self.isBackgroundAppear ? 1 : 0)
                        .padding()
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 1.0, y: 1.0)
                }
                .scaleEffect(self.isScalling ? 1 : 0.5)

            }
            .interactiveDismissDisabled()
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.isBackgroundAppear = true
                }
                withAnimation(.easeInOut(duration: 0.4).delay(0.2)) {
                    self.isImageAppear = true
                }
                withAnimation(.easeInOut(duration: 0.4).delay(0.4)) {
                    self.isMessageAppear = true
                }
                withAnimation(.easeInOut(duration: 0.4).delay(0.6)) {
                    self.isActionButtonsAppear = true
                }
                withAnimation(
                    .interactiveSpring(
                        response: 0.8,
                        dampingFraction: 0.6,
                        blendDuration: 0.6
                    )
                ) {
                    self.isScalling = true
                }
            }
        }
    }
    
    private func verticalActionView(
        viewStore: ViewStoreOf<LevelDetails>
    ) -> some View {
        VStack(spacing: 20) {
            StackHorizontalButton(
                icon: "arrow.right.circle",
                title: "Next Level", 
                color: viewStore.completedLevel.colors.details,
                shadowColor: viewStore.completedLevel.colors.background
            ) {
                animateDissapear()
                viewStore.send(.goToNextLevelButtonTapped)
            }
            .frame(maxWidth: .infinity)
            
            StackHorizontalButton(
                icon: "arrow.up.circle",
                title: "Try again",
                color: viewStore.completedLevel.colors.details,
                shadowColor: viewStore.completedLevel.colors.background
            ) {
                animateDissapear()
                viewStore.send(.tryCurrentLevelButtonTapped)
            }
            .frame(maxWidth: .infinity)
            
            StackHorizontalButton(
                icon: "xmark.circle",
                title: "Finish",
                color: viewStore.completedLevel.colors.details,
                shadowColor: viewStore.completedLevel.colors.background
            ) {
                viewStore.send(.finishGameButtonTapped)
            }
            .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
    
    private func horizontalActionView(
        viewStore: ViewStoreOf<LevelDetails>
    ) -> some View {
        HStack(spacing: 10) {
            VStack {
                StackVerticalButton(
                    icon: "arrow.right.circle",
                    title: "Next Level",
                    color: viewStore.completedLevel.colors.details, 
                    shadowColor: viewStore.completedLevel.colors.background
                ) {
                    animateDissapear()
                    viewStore.send(.goToNextLevelButtonTapped)
                }
                .padding()
                .frame(maxHeight: .infinity)
            }
            
            VStack {
                StackVerticalButton(
                    icon: "arrow.up.circle",
                    title: "Try again",
                    color: viewStore.completedLevel.colors.details,
                    shadowColor: viewStore.completedLevel.colors.background
                ) {
                    animateDissapear()
                    viewStore.send(.tryCurrentLevelButtonTapped)
                }
                .padding()
                .frame(maxHeight: .infinity)
            }
            
            VStack {
                StackVerticalButton(
                    icon: "xmark.circle",
                    title: "Finish",
                    color: viewStore.completedLevel.colors.details,
                    shadowColor: viewStore.completedLevel.colors.background
                ) {
                    viewStore.send(.finishGameButtonTapped)
                }
                .padding()
                .frame(maxHeight: .infinity)

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
