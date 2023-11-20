//
//  ContentView.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-17.
//

import SwiftUI
import MemoryCards
import Models

struct ContentView: View {
    var body: some View {
        GameView(
            store: .init(
                initialState: Game.State(
                    gameOptions: .init(
                        modeSection: .init(title: "Game mode", availableModes: MemoryCardGame.Mode.allCases, selectedMode: .practice),
                        styleSection: .init(title: "Game style", availableStyles: MemoryCardGame.Style.allCases, selectedStyle: .numbers),
                        difficultySection: .init(title: "Difficulty", availableOptions: MemoryCardGame.Difficulty.allCases, selectedOption: .easy)
                    )
                )
            ) {
                Game()
                    ._printChanges()
            }
        )
    }
}

#Preview {
    ContentView()
}
