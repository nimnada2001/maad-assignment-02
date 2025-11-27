//
//  PrimaryButton.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isEnabled: Bool
    
    @FocusState private var isFocused: Bool
    
    init(title: String, icon: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                }
                Text(title)
                    .font(.system(size: 28, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.4, blue: 0.8), Color(red: 0.5, green: 0.3, blue: 0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.8), Color.blue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isFocused ? 4 : 0
                    )
            )
            .scaleEffect(isFocused ? 1.06 : 1.0)
            .shadow(color: isFocused ? Color.blue.opacity(0.5) : Color.clear, radius: 20, x: 0, y: 10)
            .animation(.easeOut(duration: 0.2), value: isFocused)
        }
        .buttonStyle(PlainButtonStyle())
        .focused($isFocused)
        .focusable(isEnabled)
        .disabled(!isEnabled)
    }
}

