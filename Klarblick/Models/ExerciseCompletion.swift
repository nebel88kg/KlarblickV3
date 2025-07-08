//
//  ExerciseCompletion.swift
//  Klarblick
//
//  Created by Dominik Nebel on [Date].
//

import Foundation
import SwiftData

@Model
class ExerciseCompletion: Identifiable {
    var id = UUID()
    var date: Date
    var category: String // Store as string to avoid enum issues
    var source: String // "cardView" or "library"
    
    init(date: Date, category: ExerciseCategory, source: String = "cardView") {
        self.date = date
        self.category = category.rawValue
        self.source = source
    }
} 