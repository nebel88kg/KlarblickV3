//
//  Badge.swift
//  Klarblick
//
//  Created by Dominik Nebel on 04.07.25.
//

import Foundation
import SwiftData

@Model
class Badge {
    var id: String
    var name: String
    var badgeDescription: String
    var category: String // BadgeCategory rawValue
    var rarity: String // BadgeRarity rawValue
    var iconName: String
    var earnedDate: Date?
    var progress: Int // Current progress toward earning
    
    // Computed properties
    var isEarned: Bool {
        return earnedDate != nil
    }
    
    var badgeCategory: BadgeCategory {
        return BadgeCategory(rawValue: category) ?? .achievement
    }
    
    var badgeRarity: BadgeRarity {
        return BadgeRarity(rawValue: rarity) ?? .common
    }
    
    init(id: String, name: String, description: String, category: BadgeCategory, rarity: BadgeRarity, iconName: String, isEarned: Bool = false) {
        self.id = id
        self.name = name
        self.badgeDescription = description
        self.category = category.rawValue
        self.rarity = rarity.rawValue
        self.iconName = iconName
        self.earnedDate = isEarned ? Date() : nil
        self.progress = 0
    }
    
    func markAsEarned() {
        earnedDate = Date()
    }
    
    func updateProgress(_ newProgress: Int) {
        progress = newProgress
    }
} 
