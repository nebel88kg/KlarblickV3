//
//  MoodEntry.swift
//  Klarblick
//
//  Created by Dominik Nebel on 02.07.25.
//

import Foundation
import SwiftData

@Model
class MoodEntry: Identifiable {
    var id = UUID()
    var date: Date
    var mood: String
    var note: String?
    
    init(date: Date, mood: String, note: String? = nil) {
        self.date = date
        self.mood = mood
        self.note = note
    }
}
