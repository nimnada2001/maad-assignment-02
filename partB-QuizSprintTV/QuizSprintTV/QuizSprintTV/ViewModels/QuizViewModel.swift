//
//  QuizViewModel.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class QuizViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var currentScreen: AppScreen = .home
    @Published var player1Name: String = ""
    @Published var player2Name: String = ""
    @Published var showScoreAnimation: Bool = false
    @Published var selectedAnswerIndex: Int? = nil
    @Published var answerFeedback: AnswerFeedback? = nil
    
    nonisolated(unsafe) private var timer: Timer?
    private let questionTimeLimit: Int = 15
    
    init() {
        self.gameState = GameState()
    }
    
    // MARK: - Game Setup
    
    func startGame() {
        guard !player1Name.isEmpty && !player2Name.isEmpty else { return }
        
        gameState.players = [
            Player(name: player1Name, score: 0),
            Player(name: player2Name, score: 0)
        ]
        gameState.currentPlayerIndex = 0
        gameState.currentQuestionIndex = 0
        gameState.selectRandomQuestions()
        gameState.timerSecondsRemaining = questionTimeLimit
        
        currentScreen = .quiz
        startTimer()
    }
    
    // MARK: - Timer Management
    
    func startTimer() {
        stopTimer()
        gameState.timerSecondsRemaining = questionTimeLimit
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.gameState.timerSecondsRemaining > 0 {
                    self.gameState.timerSecondsRemaining -= 1
                } else {
                    // Time's up - automatically move to next question
                    self.handleTimeUp()
                }
            }
        }
    }
    
    nonisolated func stopTimer() {
        // Timer invalidation is thread-safe, so this can be nonisolated
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimeUp() {
        stopTimer()
        // Time's up counts as incorrect answer
        answerFeedback = .incorrect
        selectedAnswerIndex = nil
        
        // Wait a moment to show feedback, then advance
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            await advanceToNextQuestion()
        }
    }
    
    // MARK: - Answer Handling
    
    func selectAnswer(at index: Int) {
        guard selectedAnswerIndex == nil else { return } // Prevent multiple selections
        guard let currentQuestion = gameState.currentQuestion else { return }
        
        selectedAnswerIndex = index
        stopTimer()
        
        if index == currentQuestion.correctIndex {
            // Correct answer
            gameState.players[gameState.currentPlayerIndex].score += 10
            answerFeedback = .correct
            showScoreAnimation = true
            
            // Hide animation after a moment
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                showScoreAnimation = false
                await advanceToNextQuestion()
            }
        } else {
            // Incorrect answer
            answerFeedback = .incorrect
            
            // Wait a moment to show feedback, then advance
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                await advanceToNextQuestion()
            }
        }
    }
    
    // MARK: - Navigation
    
    private func advanceToNextQuestion() async {
        answerFeedback = nil
        selectedAnswerIndex = nil
        
        // Move to next question
        gameState.currentQuestionIndex += 1
        
        // Check if current player finished their 5 questions
        let questions = gameState.currentPlayerIndex == 0 
            ? gameState.questionsForPlayer1 
            : gameState.questionsForPlayer2
        
        if gameState.currentQuestionIndex >= questions.count {
            // Current player finished, move to next player
            gameState.currentPlayerIndex += 1
            gameState.currentQuestionIndex = 0
            
            if gameState.isGameComplete {
                // Both players finished - show results
                stopTimer()
                currentScreen = .result
            } else {
                // Start next player's turn
                gameState.timerSecondsRemaining = questionTimeLimit
                startTimer()
            }
        } else {
            // Continue with next question for current player
            gameState.timerSecondsRemaining = questionTimeLimit
            startTimer()
        }
    }
    
    func playAgain() {
        // Reset game state but keep player names
        gameState.currentPlayerIndex = 0
        gameState.currentQuestionIndex = 0
        gameState.players[0].score = 0
        gameState.players[1].score = 0
        gameState.selectRandomQuestions()
        gameState.timerSecondsRemaining = questionTimeLimit
        selectedAnswerIndex = nil
        answerFeedback = nil
        showScoreAnimation = false
        stopTimer()
        
        currentScreen = .quiz
        startTimer()
    }
    
    func goHome() {
        // Reset everything
        stopTimer()
        gameState = GameState()
        player1Name = ""
        player2Name = ""
        selectedAnswerIndex = nil
        answerFeedback = nil
        showScoreAnimation = false
        currentScreen = .home
    }
    
    deinit {
        stopTimer()
    }
}
