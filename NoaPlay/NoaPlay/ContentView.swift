//
//  ContentView.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-17.
//

import SwiftUI
import MemoryCards

struct ContentView: View {
    var body: some View {
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
}

#Preview {
    ContentView()
}
