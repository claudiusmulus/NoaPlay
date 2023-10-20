//
//  OutlineOverlay.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-20.
//

import SwiftUI

struct OutlineOverlay: ViewModifier {
    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    var color: Color

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    .linearGradient(
                        colors: [
                            color,
                            color.opacity(0.6)
                        ],
                        startPoint: .top,
                        endPoint: .bottom),
                    lineWidth: lineWidth
                )
                .blendMode(.overlay)
        )
    }
}

extension View {
    func borderOverlay(lineWidth: CGFloat = 10, cornerRadius: CGFloat = 20, color: Color = .green) -> some View {
        self.modifier(OutlineOverlay(lineWidth: lineWidth, cornerRadius: cornerRadius, color: color))
    }
}

