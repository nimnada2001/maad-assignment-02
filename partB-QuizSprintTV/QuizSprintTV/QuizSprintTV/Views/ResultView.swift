//
//  ResultView.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Binding var navigationPath: NavigationPath
    
    private var winner: Player? {
        guard viewModel.gameState.players.count == 2 else { return nil }
        let player1 = viewModel.gameState.players[0]
        let player2 = viewModel.gameState.players[1]
        
        if player1.score > player2.score {
            return player1
        } else if player2.score > player1.score {
            return player2
        } else {
            return nil // Draw
        }
    }
    
    private var isDraw: Bool {
        guard viewModel.gameState.players.count == 2 else { return false }
        return viewModel.gameState.players[0].score == viewModel.gameState.players[1].score
    }
    
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
                
                // Results Title
                HStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("Results")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Draw Message or Winner Indicator
                if isDraw {
                    Text("It's a Draw!")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                } else if let winner = winner {
                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                        
                        Text("\(winner.name) Wins!")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                // Player Scores
                HStack(spacing: 60) {
                    // Player 1
                    if viewModel.gameState.players.count > 0 {
                        PlayerScoreCard(
                            player: viewModel.gameState.players[0],
                            isWinner: winner?.id == viewModel.gameState.players[0].id && !isDraw
                        )
                    }
                    
                    // Player 2
                    if viewModel.gameState.players.count > 1 {
                        PlayerScoreCard(
                            player: viewModel.gameState.players[1],
                            isWinner: winner?.id == viewModel.gameState.players[1].id && !isDraw
                        )
                    }
                }
                .frame(maxWidth: 1100)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 24) {
                    Button(action: {
                        viewModel.playAgain()
                        navigationPath.removeLast()
                        navigationPath.append("quiz")
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Play Again")
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
                    
                    Button(action: {
                        viewModel.goHome()
                        navigationPath.removeLast(navigationPath.count)
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Go Home")
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
                }
                .frame(maxWidth: 1100)
            }
        }
    }
}

// Helper view for displaying individual player scores
struct PlayerScoreCard: View {
    let player: Player
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(player.name)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                if isWinner {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
                
                Text("\(player.score)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(isWinner ? .yellow : .white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 32)
        .background(
            Group {
                if isWinner {
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.6),
                            Color(red: 0.4, green: 0.3, blue: 0.15).opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6)
                }
            }
            .background(.ultraThinMaterial)
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    isWinner
                        ? LinearGradient(
                            colors: [Color.yellow.opacity(0.9), Color.orange.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                    lineWidth: isWinner ? 4 : 2
                )
        )
    }
}

