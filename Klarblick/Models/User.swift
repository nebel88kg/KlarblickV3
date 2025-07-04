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
    
    init(name: String, currentStreak: Int = 7, currentXp: Int = 500) {
        self.name = name
        self.currentStreak = currentStreak
        self.currentXp = currentXp
        self.lastMoodCheckIn = nil
    }
}
