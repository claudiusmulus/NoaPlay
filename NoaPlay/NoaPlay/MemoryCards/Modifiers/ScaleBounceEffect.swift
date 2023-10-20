//
//  ScaleBounceEffect.swift
//  NoaPlay
//
//  Created by Alberto Novo Garrido on 2023-10-20.
//

import SwiftUI

struct ScaleBounceModifier: ViewModifier, Animatable {
    
    private var scaleOffset: CGFloat
    
    private var scale: CGFloat {
        didSet {
            self.bounceScale = bounceScale(for: self.scale)
        }
    }
    
    private var bounceScale: CGFloat = 1
    
    init(_ value: CGFloat) {
        self.scaleOffset = value != 1 ? value - 1 : 1
        self.scale = value
        self.bounceScale = 1
    }
    
    var animatableData: CGFloat {
        get {
            scale
        }
        set {
            self.scale = newValue
        }
    }
        
    func body(content: Content) -> some View {
        content
            .scaleEffect(self.bounceScale)
    }
    
    // MARK: - Utils
    private func bounceScale(for scale: CGFloat) -> CGFloat {
        let currentScaleOffset = scale - 1
        let progress = currentScaleOffset / scaleOffset
        
        if progress <= 0.5 {
            return 1 + (progress / 0.5) * scaleOffset
        } else {
            return 1 + ((1 - progress) / 0.5) * scaleOffset
        }
    }
}

extension View {
    func scaleBounceEffect(_ value: CGFloat) -> some View {
        self.modifier(ScaleBounceModifier(value))
    }
}
