//
//  MemoryCardLevelDetails.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-25.
//

import SwiftUI
import Models
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
            ActionHorizontalButton(
                icon: "arrow.right.circle",
                title: "Next Level", 
                color: viewStore.completedLevel.colors.details,
                shadowColor: viewStore.completedLevel.colors.background
            ) {
                animateDissapear()
                viewStore.send(.goToNextLevelButtonTapped)
            }
            .frame(maxWidth: .infinity)
            
            ActionHorizontalButton(
                icon: "arrow.up.circle",
                title: "Try again",
                color: viewStore.completedLevel.colors.details,
                shadowColor: viewStore.completedLevel.colors.background
            ) {
                animateDissapear()
                viewStore.send(.tryCurrentLevelButtonTapped)
            }
            .frame(maxWidth: .infinity)
            
            ActionHorizontalButton(
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
                ActionVerticalButton(
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
                .buttonStyle(
                    ActionButtonStyle(cornerRadius: 10, color: viewStore.completedLevel.colors.details, shadowColor: viewStore.completedLevel.colors.background))
            }
            
            VStack {
                ActionVerticalButton(
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
                ActionVerticalButton(
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

struct ActionButtonStyle: ButtonStyle {
    
    let cornerRadius: CGFloat
    let color: Color
    let shadowColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .minimumScaleFactor(0.6)
            .padding(20)
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                        .shadow(
                            color: shadowColor,
                            radius: configuration.isPressed ? 1 : 2,
                            x: configuration.isPressed ? -0.5 : -1,
                            y: configuration.isPressed ? -0.5: -1
                        )
                        .shadow(
                            color: .black,
                            radius: configuration.isPressed ? 1 : 2,
                            x: configuration.isPressed ? 0.5 : 1,
                            y: configuration.isPressed ? 0.5: 1
                        )
                        .blendMode(.overlay)
                    RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                        .fill(self.color)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.white)
            .animation(.spring(), value: configuration.isPressed)
    }
    
}

struct ActionVerticalButton: View {
    
    let icon: String
    let title: String
    let color: Color
    let shadowColor: Color
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let action: () -> Void
    
    @ScaledMetric private var iconSize: CGFloat = 50.0
    
    init(
        icon: String,
        title: String,
        color: Color,
        shadowColor: Color,
        borderWidth: CGFloat = 5,
        cornerRadius: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.shadowColor = shadowColor
        self.action = action
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        VStack {
            Button(
                action: self.action,
                label: {
                    VStack(spacing: 10) {
                        Image(systemName: self.icon)
                            .font(.system(size: self.iconSize).bold())
                        Text(self.title)
                            .font(.title.bold())
                    }
                    .padding(20)
            })
            .buttonStyle(
                ActionButtonStyle(
                    cornerRadius: self.cornerRadius,
                    color: self.color,
                    shadowColor: self.shadowColor
                )
            )
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
            .minimumScaleFactor(0.6)
        }
    }
}

struct ActionHorizontalButton: View {
    
    let icon: String
    let title: String
    let titleFont: Font
    let color: Color
    let shadowColor: Color
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let action: () -> Void
    
    @ScaledMetric private var iconSize: CGFloat = 25.0
    
    init(
        icon: String,
        title: String,
        color: Color,
        shadowColor: Color,
        titleFont: Font = .title3.bold(),
        borderWidth: CGFloat = 5,
        cornerRadius: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.titleFont = titleFont
        self.color = color
        self.shadowColor = shadowColor
        self.action = action
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Button(
            action: self.action,
            label: {
                HStack(spacing: 10) {
                    Image(systemName: self.icon)
                        .font(.system(size: self.iconSize).bold())
                    Text(self.title)
                        .lineLimit(1)
                        .font(self.titleFont)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(
            ActionButtonStyle(
                cornerRadius: self.cornerRadius,
                color: self.color,
                shadowColor: self.shadowColor
            )
        )
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
