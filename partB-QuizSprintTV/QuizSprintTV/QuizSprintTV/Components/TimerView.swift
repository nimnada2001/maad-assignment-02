//
//  TimerView.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct TimerView: View {
    let secondsRemaining: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.title2)
                .foregroundColor(.white)
            
            Text("\(secondsRemaining)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            Color(red: 0.2, green: 0.3, blue: 0.5).opacity(0.8)
                .background(.ultraThinMaterial)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    secondsRemaining <= 5 
                        ? Color.red.opacity(0.8)
                        : Color.blue.opacity(0.6),
                    lineWidth: 3
                )
        )
    }
}

