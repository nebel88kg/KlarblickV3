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
    var name: String
    var badgeDescription: String
    var earnedDate: Date?
    
    init(name: String, description: String, isEarned: Bool = false) {
        self.name = name
        self.badgeDescription = description
        self.earnedDate = isEarned ? Date() : nil
    }
} 
