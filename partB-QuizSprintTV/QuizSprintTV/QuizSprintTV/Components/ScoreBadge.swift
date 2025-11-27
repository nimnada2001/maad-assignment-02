//
//  ScoreBadge.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct ScoreBadge: View {
    let score: Int
    let isAnimated: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(score)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.4, blue: 0.8), Color(red: 0.5, green: 0.3, blue: 0.9)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .scaleEffect(isAnimated ? 1.3 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimated)
    }
}

