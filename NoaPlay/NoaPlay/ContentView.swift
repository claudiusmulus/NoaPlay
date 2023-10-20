//
//  ContentView.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CardBoard(
            store: .init(
                initialState: MemoryCardBoard.State(cards: .mock)) {
                    MemoryCardBoard()
                }
        )
    }
}

#Preview {
    ContentView()
}
