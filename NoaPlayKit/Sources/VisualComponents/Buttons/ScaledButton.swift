//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-03.
//

import SwiftUI

public struct ScaledButton<Label: View>: View {
    
    let color: Color
    let shadowColor: Color
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let label: () -> Label
    let action: () -> Void
    
    public init(
        color: Color,
        shadowColor: Color,
        borderWidth: CGFloat = 5,
        cornerRadius: CGFloat = 20,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.color = color
        self.shadowColor = shadowColor
        self.label = label
        self.action = action
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        Button(
            action: self.action,
            label: self.label
        )
        .buttonStyle(
            ScaledButtonStyle(
                cornerRadius: self.cornerRadius,
                color: self.color,
                shadowColor: self.shadowColor
            )
        )
    }
}
