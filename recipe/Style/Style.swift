//
//  Style.swift
//  recipe
//
//  Created by Wyatt Cheang on 11/10/2024.
//

import Foundation
import SwiftUI

enum Size {
    case small
    case regular
}

struct CircleStyle: ButtonStyle {
    var size: Size
    var color: Color
    
    init (_ size: Size = .regular, color: Color = .accent) {
        self.size = size
        self.color = color
    }
    
    private var width: CGFloat {
        switch size {
        case .small: return 28
        case .regular: return 56
        }
    }
    
    @Environment(\.isEnabled) var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size == .small ?
                .system(size: 16, weight: .bold) : .system(size: 20, weight: .bold))
            .frame(width: width, height: width)
            .foregroundColor(.white)
            .background(isEnabled ? configuration.isPressed ?
                color.opacity(0.8) : color : Color(UIColor.systemGray4))
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .labelStyle(.iconOnly)
    }
}

struct AccentButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(isEnabled ? configuration.isPressed ?
                .accent.opacity(0.8) : .accent : Color(UIColor.systemGray4))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .disabled(!isEnabled)
    }
}

#Preview {
    Button("hi", systemImage: "plus", action: {})
        .buttonStyle(CircleStyle())
    Button("hi", systemImage: "plus", action: {})
        .buttonStyle(CircleStyle())
        .disabled(true)
    Button("hi", systemImage: "plus", action: {})
        .buttonStyle(CircleStyle(.small))
}

struct RectStyle: TextFieldStyle {
    var isValid: Bool
    var color: Color
    
    init(isValid: Bool = false, color: Color = Color(UIColor.secondarySystemBackground)) {
        self.isValid = isValid
        self.color = color
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(color)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isValid ? .accent : .clear, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: isValid)
    }
}

struct RectFrame<Content: View>: View {
    let content: Content
    var isAccent: Bool = false

    init(isAccent: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isAccent = isAccent
    }
    
    var body: some View {
        HStack {
            content
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isAccent ? Color.accentColor : Color.clear, lineWidth: 2) // Use Color.accentColor
        )
    }
}

#Preview {
    RectFrame(isAccent: true) {
        Text("Hello World")
            .padding()
    }
}

