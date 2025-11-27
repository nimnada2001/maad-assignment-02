//
//  AnswerCardView.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct AnswerCardView: View {
    let answer: String
    let index: Int
    let isCorrect: Bool
    let isSelected: Bool
    let feedback: AnswerFeedback?
    let onSelect: () -> Void
    
    @FocusState private var isFocused: Bool
    
    private var strokeGradient: LinearGradient {
        if let feedback = feedback, isSelected {
            return LinearGradient(
                colors: feedback == .correct
                    ? [Color.green.opacity(0.9), Color.green.opacity(0.6)]
                    : [Color.red.opacity(0.9), Color.red.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isFocused {
            return LinearGradient(
                colors: [Color.white.opacity(0.8), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var strokeWidth: CGFloat {
        (isFocused || (feedback != nil && isSelected)) ? 4 : 0
    }
    
    var body: some View {
        Button(action: onSelect) {
            Text(answer)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(
                    Group {
                        // Background color based on feedback
                        if let feedback = feedback {
                            if feedback == .correct && isSelected {
                                Color.green.opacity(0.3)
                            } else if feedback == .incorrect && isSelected {
                                Color.red.opacity(0.3)
                            } else {
                                Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6)
                            }
                        } else {
                            Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6)
                        }
                    }
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(strokeGradient, lineWidth: strokeWidth)
                )
                .scaleEffect(isFocused ? 1.06 : 1.0)
                .rotation3DEffect(
                    .degrees(isFocused ? 5 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .shadow(
                    color: isFocused ? Color.blue.opacity(0.5) : Color.clear,
                    radius: 20,
                    x: 0,
                    y: 10
                )
                .animation(.easeOut(duration: 0.2), value: isFocused)
                .animation(.easeOut(duration: 0.2), value: feedback)
        }
        .buttonStyle(PlainButtonStyle())
        .focused($isFocused)
        .focusable()
    }
}
