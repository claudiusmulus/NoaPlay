//
//  SwiftUIView.swift
//  
//
//  Created by Alberto Novo Garrido on 2023-11-03.
//

import SwiftUI

public struct StackVerticalButton: View {
    
    let icon: String
    let title: String
    let color: Color
    let shadowColor: Color
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let action: () -> Void
    
    @ScaledMetric private var iconSize: CGFloat = 50.0
    
    public init(
        icon: String,
        title: String,
        color: Color,
        shadowColor: Color,
        borderWidth: CGFloat = 5,
        cornerRadius: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.shadowColor = shadowColor
        self.action = action
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        VStack {
            Button(
                action: self.action,
                label: {
                    VStack(spacing: 10) {
                        Image(systemName: self.icon)
                            .font(.system(size: self.iconSize).bold())
                        Text(self.title)
                            .font(.title.bold())
                    }
                    .padding(20)
            })
            .buttonStyle(
                StackButtonStyle(
                    cornerRadius: self.cornerRadius,
                    color: self.color,
                    shadowColor: self.shadowColor
                )
            )
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
            .minimumScaleFactor(0.6)
        }
    }
}

public struct StackHorizontalButton: View {
    
    let icon: String
    let title: String
    let titleFont: Font
    let color: Color
    let shadowColor: Color
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let action: () -> Void
    
    @ScaledMetric private var iconSize: CGFloat = 25.0
    
    public init(
        icon: String,
        title: String,
        color: Color,
        shadowColor: Color,
        titleFont: Font = .title3.bold(),
        borderWidth: CGFloat = 5,
        cornerRadius: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.titleFont = titleFont
        self.color = color
        self.shadowColor = shadowColor
        self.action = action
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        Button(
            action: self.action,
            label: {
                HStack(spacing: 10) {
                    Image(systemName: self.icon)
                        .font(.system(size: self.iconSize).bold())
                    Text(self.title)
                        .lineLimit(1)
                        .font(self.titleFont)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(
            StackButtonStyle(
                cornerRadius: self.cornerRadius,
                color: self.color,
                shadowColor: self.shadowColor
            )
        )
    }
}
