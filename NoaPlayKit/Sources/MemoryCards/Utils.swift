//
//  Models.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//
import SwiftUI
import Models
import Theme
import ComposableArchitecture
import DataGenerator

extension MemoryCardGame.Level {
    func availableCards(style: MemoryCardGame.Style) -> IdentifiedArrayOf<Card.State> {
        @Dependency(\.dataGenerator.availableCards) var cardsGenerator
        let cardsArray: [Card.State] = cardsGenerator(self, style).map {
            .init(style: $0)
        }
        return .init(uniqueElements: cardsArray)
    }
}

extension MemoryCardGame.Difficulty {
    func initialLevel() -> MemoryCardGame.Level {
        @Dependency(\.dataGenerator.initialLevel) var initialLevelGenerator
        
        return initialLevelGenerator(self)
    }
}

extension MemoryCardGame.Mode {
    var title: String {
        switch self {
        case .practice:
            return "Practice"
        case .timer:
            return "Timer"
        }
    }
    
    var iconName: String {
        switch self {
        case .practice:
            return "house.fill"
        case .timer:
            return "clock.fill"
        }
    }
}

extension MemoryCardGame.Style {
    var title: String {
        switch self {
        case .numbers:
            return "123"
        case .letters:
            return "Abc"
        }
    }
}

extension MemoryCardGame.Difficulty {
    var title: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
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

struct GameOptionSection<Option: Hashable, Content: View>: View {
    
    let title: String
    let height: CGFloat
    let options: [Option]
    let isSelected: (Option) -> Bool
    let action: (Option) -> Void
    let label: (Option) -> Content
    
    init(
        title: String,
        height: CGFloat = 140.0,
        options: [Option],
        isSelected: @escaping (Option) -> Bool,
        action: @escaping (Option) -> Void,
        @ViewBuilder label: @escaping (Option) -> Content
    ) {
        self.title = title
        self.height = height
        self.options = options
        self.isSelected = isSelected
        self.action = action
        self.label = label
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(self.title)
                .font(.system(.largeTitle).weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal) {
                LazyHGrid(
                    rows: [GridItem(.fixed(self.height), spacing: 10)],
                    spacing: 10
                ){
                    ForEach(options, id: \.self) { option in
                        GameOption(color: .onBackgroundPrimary) {
                            label(option)
                        }
                        .borderOverlay(lineWidth: 6, cornerRadius: 20, color: isSelected(option) ? .actionPrimary : .clear)
                        .frame(width: 200)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            action(option)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
