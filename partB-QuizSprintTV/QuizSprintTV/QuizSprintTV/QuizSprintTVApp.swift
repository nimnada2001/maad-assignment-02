//
//  QuizSprintTVApp.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//
//  README - QuizSprintTV App Summary
//  ===================================
//
//  QuizSprintTV is a 2-player timed trivia game for Apple TV (tvOS) built with SwiftUI.
//
//  GAME FLOW:
//  ----------
//  1. Home Screen: Players enter their names in two text fields. The "Play" button
//     is enabled only when both names are provided.
//
//  2. Quiz Screen: Each player answers 5 randomly selected questions from a bank
//     of 15 questions. Each question has a 15-second timer. Correct answers award
//     10 points. The game automatically advances after an answer is selected or
//     when the timer reaches zero. Player 1 completes all 5 questions first,
//     then Player 2 takes their turn.
//
//  3. Results Screen: Displays both players' scores, highlights the winner (or
//     shows "It's a Draw!" for ties). Options to "Play Again" (keeps names, resets
//     game) or "Go Home" (full reset).
//
//  ARCHITECTURE:
//  ------------
//  - MVVM pattern with QuizViewModel managing game state and logic
//  - Models: Question, Player, GameState
//  - Views: HomeView, QuizView, ResultView
//  - Reusable Components: PrimaryButton, AnswerCardView, PlayerNameField, TimerView, ScoreBadge
//  - Navigation managed via AppScreen enum in ContentView
//
//  KEY FEATURES:
//  ------------
//  - Custom tvOS focus system with gradient borders and scale effects
//  - Smooth animations for focus changes and screen transitions
//  - Timer-based gameplay with automatic question advancement
//  - Visual feedback for correct/incorrect answers
//  - Score animations (+10 points) on correct answers
//  - Beautiful dark gradient theme optimized for TV viewing
//  - Respects tvOS Human Interface Guidelines
//
//  TECHNICAL NOTES:
//  ---------------
//  - Uses Timer.publish for countdown functionality
//  - Questions are randomly selected without repetition per player
//  - Focus management uses .focusable() and .onFocusChange
//  - All interactive elements use .buttonStyle(.plain) for custom styling
//  - Background gradients use .ignoresSafeArea() for full-screen coverage

import SwiftUI

@main
struct QuizSprintTVApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
