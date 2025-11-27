//
//  QuizView.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct QuizView: View {
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
            
            VStack(spacing: 40) {
                // Top Row: Player Info and Timer
                HStack {
                    // Current Player Info
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(viewModel.gameState.currentPlayer?.name ?? "")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("\(viewModel.gameState.currentPlayer?.score ?? 0)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
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
                            .scaleEffect(viewModel.showScoreAnimation ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.showScoreAnimation)
                    }
                    
                    Spacer()
                    
                    // Timer
                    HStack(spacing: 12) {
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("\(viewModel.gameState.timerSecondsRemaining)")
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
                                viewModel.gameState.timerSecondsRemaining <= 5
                                    ? Color.red.opacity(0.8)
                                    : Color.blue.opacity(0.6),
                                lineWidth: 3
                            )
                    )
                }
                .frame(maxWidth: 1100)
                
                Spacer()
                
                // Question Text
                if let question = viewModel.gameState.currentQuestion {
                    Text(question.text)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .frame(maxWidth: 1100)
                }
                
                Spacer()
                
                // Answer Cards Grid (2x2)
                if let question = viewModel.gameState.currentQuestion {
                    VStack(spacing: 24) {
                        HStack(spacing: 24) {
                            Button(action: {
                                viewModel.selectAnswer(at: 0)
                            }) {
                                Text(question.answers[0])
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140)
                                    .background(
                                        viewModel.selectedAnswerIndex == 0 && viewModel.answerFeedback == .correct
                                            ? Color.green.opacity(0.3)
                                            : viewModel.selectedAnswerIndex == 0 && viewModel.answerFeedback == .incorrect
                                            ? Color.red.opacity(0.3)
                                            : Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6)
                                    )
                                    .cornerRadius(20)
                            }
                            
                            Button(action: {
                                viewModel.selectAnswer(at: 1)
                            }) {
                                Text(question.answers[1])
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140)
                                    .background(
                                        viewModel.selectedAnswerIndex == 1 && viewModel.answerFeedback == .correct
                                            ? Color.green.opacity(0.3)
                                            : viewModel.selectedAnswerIndex == 1 && viewModel.answerFeedback == .incorrect
                                            ? Color.red.opacity(0.3)
                                            : Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                        
                        HStack(spacing: 24) {
                            Button(action: {
                                viewModel.selectAnswer(at: 2)
                            }) {
                                Text(question.answers[2])
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140)
                                    .background(
                                        viewModel.selectedAnswerIndex == 2 && viewModel.answerFeedback == .correct
                                            ? Color.green.opacity(0.3)
                                            : viewModel.selectedAnswerIndex == 2 && viewModel.answerFeedback == .incorrect
                                            ? Color.red.opacity(0.3)
                                            : Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6)
                                    )
                                    .cornerRadius(20)
                            }
                            
                            Button(action: {
                                viewModel.selectAnswer(at: 3)
                            }) {
                                Text(question.answers[3])
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140)
                                    .background(
                                        viewModel.selectedAnswerIndex == 3 && viewModel.answerFeedback == .correct
                                            ? Color.green.opacity(0.3)
                                            : viewModel.selectedAnswerIndex == 3 && viewModel.answerFeedback == .incorrect
                                            ? Color.red.opacity(0.3)
                                            : Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.6)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .frame(maxWidth: 1100)
                }
                
                
                // Score Animation Overlay
                if viewModel.showScoreAnimation {
                    VStack {
                        Text("+10")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.green)
                            .shadow(color: .green.opacity(0.8), radius: 20)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
}

