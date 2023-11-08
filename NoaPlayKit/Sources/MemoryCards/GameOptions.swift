//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-07.
//

import SwiftUI
import ComposableArchitecture
import Models
import VisualComponents
import Theme

public struct GameOptions: Reducer {
    public init() {
        
    }
    public struct State: Equatable {
        let availableModes: [MemoryCardGame.Mode]
        let availableStyles: [MemoryCardGame.Style]
        
        var selectedMode: MemoryCardGame.Mode
        var selectedStyle: MemoryCardGame.Style
        
        public init(
            availableModes: [MemoryCardGame.Mode],
            availableStyles: [MemoryCardGame.Style],
            selectedMode: MemoryCardGame.Mode = .practice,
            selectedStyle: MemoryCardGame.Style = .numbers
        ) {
            self.availableModes = availableModes
            self.availableStyles = availableStyles
            self.selectedMode = selectedMode
            self.selectedStyle = selectedStyle
        }
    }
    public enum Action: Equatable {
        case delegate(Delegate)
        case selectModeTapped(mode: MemoryCardGame.Mode)
        case selectStyleTapped(style: MemoryCardGame.Style)
        case startGameButtonTapped
        
        public enum Delegate: Equatable {
            case startGame(mode: MemoryCardGame.Mode, style: MemoryCardGame.Style)
        }
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
            case let .selectModeTapped(mode):
                if mode != state.selectedMode {
                    state.selectedMode = mode
                }
                return .none
            case let .selectStyleTapped(style):
                if style != state.selectedStyle {
                    state.selectedStyle = style
                }
                return .none
            case .startGameButtonTapped:
                return .run { [mode = state.selectedMode, style = state.selectedStyle] send in
                    await send(.delegate(.startGame(mode: mode, style: style)))
                }
            }
        }
    }
}

public struct GameOptionsView: View {
    let store: StoreOf<GameOptions>
    
    public init(store: StoreOf<GameOptions>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color.gameBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        gameOptionSection(
                            options: viewStore.availableModes,
                            title: "Game mode",
                            isSelected: { $0 == viewStore.selectedMode },
                            action: {
                                viewStore.send(.selectModeTapped(mode: $0))
                            }
                        ) { mode in
                            VStack(spacing: 10) {
                                Image(systemName: mode.iconName)
                                    .font(.system(size: 38))
                                Text(mode.title)
                                    .font(.largeTitle.bold())
                                    .minimumScaleFactor(0.4)
                                    .lineLimit(1)
                            }
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                        }
                        gameOptionSection(
                            options: viewStore.availableStyles,
                            title: "Game style",
                            isSelected: { $0 == viewStore.selectedStyle },
                            action: {
                                viewStore.send(.selectStyleTapped(style: $0))
                            }
                        ) { style in
                            VStack(spacing: 10) {
                                Text(style.title)
                                    .font(.system(size: 48).bold())
                                    .minimumScaleFactor(0.4)
                                    .lineLimit(1)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.white)
                            }
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)
                        }
                    }
                    HStack {
                        ScaledButton(
                            color: .gameAction,
                            shadowColor: .white,
                            action: {
                                viewStore.send(.startGameButtonTapped)
                            }
                        ) {
                            HStack(spacing: 10) {
                                Image(systemName: "gamecontroller")
                                    .font(.system(size: 60).bold())
                                Text("Play")
                                    .font(.system(size: 60).bold())
                            }
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)
                    .background(
                        Color.gameBackground
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 0)
                            .mask(Rectangle().padding(.top, -10))
                    )
                }
                .ignoresSafeArea(edges: [.top])
                .padding(.bottom, 10)
            }
        }
    }
    
    @ViewBuilder
    private func gameOptionSection<Option: Hashable, Content: View>(
        options: [Option],
        height: CGFloat = 180.0,
        title: String,
        isSelected: @escaping (Option) -> Bool,
        action: @escaping (Option) -> Void,
        @ViewBuilder label: @escaping (Option) -> Content
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 40).weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView(.horizontal) {
                    LazyHGrid(
                        rows: [GridItem(.fixed(height), spacing: 10)],
                        spacing: 10
                    ){
                        ForEach(options, id: \.self) { option in
                            GameOption(color: .gameOption) {
                                label(option)
                            }
                            .borderOverlay(lineWidth: 10, cornerRadius: 20, color: isSelected(option) ? .gameAction : .clear)
                            .frame(width: 200)
                            .padding(.horizontal, 10)
                            .padding(.vertical)
                            .onTapGesture {
                                action(option)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding([.top, .leading], 40)
        }
    }
}

struct GameOption<Content: View>: View {
    let color: Color
    let content: Content
    
    init(color: Color, @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(color)
            content
        }
    }
}




#Preview {
    GameOptionsView(
        store: .init(
            initialState: GameOptions.State(
                availableModes: MemoryCardGame.Mode.allCases,
                availableStyles: MemoryCardGame.Style.allCases
            )) {
                GameOptions()
            }
    )
}
