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
//        CardBoardView(
//            store: .init(
//                initialState: CardBoard.State(
//                    mode: .default,
//                    difficulty: .easy, 
//                    style: .numbers,
//                    level: .one
//                )
//            ) {
//                CardBoard()
//            }
//        )
        GameView(
            store: .init(
                initialState: Game.State(
                    gameOptions: .init(
                        availableModes: MemoryCardGame.Mode.allCases,
                        availableStyles: MemoryCardGame.Style.allCases,
                        difficultyLevels: MemoryCardGame.Difficulty.allCases
                    )
                )
            ) {
                Game()
            }
        )
    }
}

#Preview {
    ContentView()
}
