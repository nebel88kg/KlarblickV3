//
//  User.swift
//  Klarblick
//
//  Created by Dominik Nebel on 04.07.25.
//

import Foundation
import SwiftData

@Model
class User {
    var name: String
    var currentStreak: Int
    var currentXp: Int
    var lastMoodCheckIn: Date?
    var lastExerciseDate: Date?
    
    init(name: String, currentStreak: Int = 0, currentXp: Int = 0) {
        self.name = name
        self.currentStreak = currentStreak
        self.currentXp = currentXp
        self.lastMoodCheckIn = nil
        self.lastExerciseDate = nil
    }
}
