//
//  Player.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import Foundation

struct Player: Identifiable {
    let id: UUID
    var name: String
    var score: Int
    
    init(id: UUID = UUID(), name: String, score: Int = 0) {
        self.id = id
        self.name = name
        self.score = score
    }
}

