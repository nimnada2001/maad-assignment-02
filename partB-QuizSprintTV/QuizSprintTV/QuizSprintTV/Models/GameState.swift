//
//  GameState.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import Foundation

enum AppScreen {
    case home
    case quiz
    case result
}

struct GameState {
    var players: [Player]
    var currentPlayerIndex: Int
    var currentQuestionIndex: Int
    var timerSecondsRemaining: Int
    var questionsForPlayer1: [Question]
    var questionsForPlayer2: [Question]
    
    init() {
        self.players = []
        self.currentPlayerIndex = 0
        self.currentQuestionIndex = 0
        self.timerSecondsRemaining = 15
        self.questionsForPlayer1 = []
        self.questionsForPlayer2 = []
    }
    
    var currentPlayer: Player? {
        guard currentPlayerIndex < players.count else { return nil }
        return players[currentPlayerIndex]
    }
    
    var currentQuestion: Question? {
        let questions = currentPlayerIndex == 0 ? questionsForPlayer1 : questionsForPlayer2
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var isGameComplete: Bool {
        return currentPlayerIndex >= players.count
    }
    
    mutating func selectRandomQuestions() {
        var availableQuestions = Question.questionBank.shuffled()
        questionsForPlayer1 = Array(availableQuestions.prefix(5))
        availableQuestions.removeFirst(5)
        
        // If we have enough questions, select 5 more for player 2
        if availableQuestions.count >= 5 {
            questionsForPlayer2 = Array(availableQuestions.prefix(5))
        } else {
            // Otherwise, shuffle again and take 5
            questionsForPlayer2 = Array(Question.questionBank.shuffled().prefix(5))
        }
    }
}

