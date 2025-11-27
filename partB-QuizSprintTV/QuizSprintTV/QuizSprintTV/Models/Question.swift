//
//  Question.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import Foundation

struct Question: Identifiable, Codable {
    let id: UUID
    let text: String
    let answers: [String]
    let correctIndex: Int
    
    init(id: UUID = UUID(), text: String, answers: [String], correctIndex: Int) {
        self.id = id
        self.text = text
        self.answers = answers
        self.correctIndex = correctIndex
    }
}

// In-memory question bank with 15 questions
extension Question {
    static let questionBank: [Question] = [
        Question(
            text: "What is the capital of France?",
            answers: ["London", "Berlin", "Paris", "Madrid"],
            correctIndex: 2
        ),
        Question(
            text: "Which planet is known as the Red Planet?",
            answers: ["Venus", "Mars", "Jupiter", "Saturn"],
            correctIndex: 1
        ),
        Question(
            text: "What is the largest ocean on Earth?",
            answers: ["Atlantic", "Indian", "Arctic", "Pacific"],
            correctIndex: 3
        ),
        Question(
            text: "Who painted the Mona Lisa?",
            answers: ["Vincent van Gogh", "Pablo Picasso", "Leonardo da Vinci", "Michelangelo"],
            correctIndex: 2
        ),
        Question(
            text: "What is the chemical symbol for gold?",
            answers: ["Go", "Gd", "Au", "Ag"],
            correctIndex: 2
        ),
        Question(
            text: "In which year did World War II end?",
            answers: ["1943", "1944", "1945", "1946"],
            correctIndex: 2
        ),
        Question(
            text: "What is the smallest prime number?",
            answers: ["0", "1", "2", "3"],
            correctIndex: 2
        ),
        Question(
            text: "Which gas makes up most of Earth's atmosphere?",
            answers: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Argon"],
            correctIndex: 2
        ),
        Question(
            text: "What is the speed of light in vacuum?",
            answers: ["300,000 km/s", "150,000 km/s", "450,000 km/s", "600,000 km/s"],
            correctIndex: 0
        ),
        Question(
            text: "Who wrote 'Romeo and Juliet'?",
            answers: ["Charles Dickens", "William Shakespeare", "Jane Austen", "Mark Twain"],
            correctIndex: 1
        ),
        Question(
            text: "What is the largest mammal in the world?",
            answers: ["African Elephant", "Blue Whale", "Giraffe", "Polar Bear"],
            correctIndex: 1
        ),
        Question(
            text: "Which programming language was created by Apple?",
            answers: ["Java", "Python", "Swift", "Kotlin"],
            correctIndex: 2
        ),
        Question(
            text: "What is the hardest natural substance on Earth?",
            answers: ["Gold", "Iron", "Diamond", "Platinum"],
            correctIndex: 2
        ),
        Question(
            text: "How many continents are there?",
            answers: ["5", "6", "7", "8"],
            correctIndex: 2
        ),
        Question(
            text: "What is the longest river in the world?",
            answers: ["Amazon", "Nile", "Yangtze", "Mississippi"],
            correctIndex: 1
        )
    ]
}

