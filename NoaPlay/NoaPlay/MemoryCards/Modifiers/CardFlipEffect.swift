//
//  CardFlip.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//

import SwiftUI

struct MemoryCardFlipModifier: ViewModifier, Animatable {
    
    init(isFaceUp: Bool) {
        self.rotationAngle = isFaceUp ? 0 : 180
    }
    
    var animatableData: Double {
        get {
            rotationAngle
        }
        set {
            self.rotationAngle = newValue
        }
    }
    
    var rotationAngle: Double
    
    func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    .linearGradient(colors: [.pink, .purple, .blue], startPoint: .topTrailing, endPoint: .bottomLeading)
                    .opacity(rotationAngle < 90 ? 0.5 : 1.0)
                )
            content
                .opacity(rotationAngle < 90 ? 1.0 : 0.0)
        }
        .rotation3DEffect(
            .degrees(rotationAngle),
            axis: (0, 1, 0),
            perspective: 0.2
        )
    }
    
}



extension View {
    func cardFlipEffect(isFaceUp: Bool) -> some View {
        self.modifier(MemoryCardFlipModifier(isFaceUp: isFaceUp))
    }
}
