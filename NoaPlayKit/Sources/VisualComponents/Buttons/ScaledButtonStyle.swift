//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-03.
//

import SwiftUI

public struct ScaledButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    let color: Color
    let shadowColor: Color
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .minimumScaleFactor(0.6)
            .padding(20)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                        .shadow(
                            color: self.shadowColor,
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
