//
//  HomeView.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.03, blue: 0.09),
                    Color(red: 0.06, green: 0.10, blue: 0.21)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 48) {
                Spacer()
                
                // App Title
                VStack(spacing: 16) {
                    Text("QuizSprintTV")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("2-Player Timed Trivia")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Player Name Fields
                VStack(spacing: 32) {
                    TextField("Player 1 Name", text: $viewModel.player1Name)
                        .textFieldStyle(.plain)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6))
                        .cornerRadius(20)
                    
                    TextField("Player 2 Name", text: $viewModel.player2Name)
                        .textFieldStyle(.plain)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6))
                        .cornerRadius(20)
                }
                .frame(maxWidth: 1100)
                
                // Play Button
                NavigationLink(value: "quiz") {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.4, blue: 0.8), Color(red: 0.5, green: 0.3, blue: 0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .disabled(viewModel.player1Name.isEmpty || viewModel.player2Name.isEmpty)
                .frame(maxWidth: 1100)
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.startGame()
                })
                
                Spacer()
            }
        }
    }
}

