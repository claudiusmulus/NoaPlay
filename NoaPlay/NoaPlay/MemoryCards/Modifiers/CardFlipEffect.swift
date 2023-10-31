//
//  CardFlip.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-18.
//

import SwiftUI

struct MemoryCardFlipModifier: ViewModifier, Animatable {
    
    let backgroundColor: Color
    let borderColor: Color
    init(isFaceUp: Bool, backgroundColor: Color, borderColor: Color) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
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
                    backgroundColor
                    .opacity(rotationAngle < 90 ? 0.5 : 1.0)
                )
                .borderOverlay(lineWidth: 5, cornerRadius: 20, color: self.rotationAngle < 90 ? .clear : borderColor)
            
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
    func cardFlipEffect(isFaceUp: Bool, backgroundColor: Color, borderColor: Color) -> some View {
        self.modifier(
            MemoryCardFlipModifier(
                isFaceUp: isFaceUp,
                backgroundColor: backgroundColor,
                borderColor: borderColor
            )
        )
    }
}
