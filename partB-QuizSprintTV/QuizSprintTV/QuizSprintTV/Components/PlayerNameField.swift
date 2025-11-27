//
//  PlayerNameField.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct PlayerNameField: View {
    let placeholder: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.plain)
                .focused($isFocused)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6)
                .background(.ultraThinMaterial)
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), Color.blue.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isFocused ? 4 : 0
                )
        )
        .scaleEffect(isFocused ? 1.03 : 1.0)
        .shadow(
            color: isFocused ? Color.blue.opacity(0.5) : Color.clear,
            radius: 20,
            x: 0,
            y: 10
        )
        .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}

