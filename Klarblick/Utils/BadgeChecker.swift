//
//  BadgeChecker.swift
//  Klarblick
//
//  Created by Dominik Nebel on 05.07.25.
//

import Foundation
import SwiftData

class BadgeChecker {
    static let shared = BadgeChecker()
    private let badgeManager = BadgeManager.shared
    
    private init() {}
    
    // Main function to check for new badges
    func checkForNewBadges(for user: User, context: ModelContext) -> [Badge] {
        var newBadges: [Badge] = []
        
        // Check each badge definition
        for definition in badgeManager.availableBadges {
            // Find or create badge for this user
            let badge = findOrCreateBadge(for: definition, user: user, context: context)
            
            // Skip if already earned
            if badge.isEarned {
                continue
            }
            
            // Check if requirements are met
            if meetsRequirements(definition, user: user, context: context) {
                badge.markAsEarned()
                newBadges.append(badge)
            } else {
                // Update progress even if not earned
                updateBadgeProgress(badge, definition: definition, user: user, context: context)
            }
        }
        
        // Save context if there are changes
        if !newBadges.isEmpty {
            try? context.save()
        }
        
        return newBadges
    }
    
    // Find existing badge or create new one
    private func findOrCreateBadge(for definition: BadgeDefinition, user: User, context: ModelContext) -> Badge {
        // Check if badge already exists for this user
        if let existingBadge = user.badges.first(where: { $0.id == definition.id }) {
            return existingBadge
        }
        
        // Create new badge
        let newBadge = Badge(
            id: definition.id,
            name: definition.name,
            description: definition.description,
            category: definition.category,
            rarity: definition.rarity,
            iconName: definition.iconName
        )
        
        user.badges.append(newBadge)
        context.insert(newBadge)
        
        return newBadge
    }
    
    // Check if badge requirements are met
    private func meetsRequirements(_ definition: BadgeDefinition, user: User, context: ModelContext) -> Bool {
        switch definition.requirement {
        case .streak(let days):
            return user.currentStreak >= days
            
        case .totalXP(let xp):
            return user.currentXp >= xp
            
        case .categoryCount(let category, let count):
            return getExerciseCompletionCount(for: category, context: context) >= count
            
        case .moodStreak(let days):
            return getMoodStreak(context: context) >= days
            
        case .moodVariety(let count):
            return getUniqueMoodCount(context: context) >= count
            
        case .perfectDay:
            return hasPerfectDay(context: context)
        }
    }
    
    // Update badge progress
    private func updateBadgeProgress(_ badge: Badge, definition: BadgeDefinition, user: User, context: ModelContext) {
        let progress: Int
        
        switch definition.requirement {
        case .streak(let target):
            progress = min(user.currentStreak, target)
            
        case .totalXP(let target):
            progress = min(user.currentXp, target)
            
        case .categoryCount(let category, let target):
            progress = min(getExerciseCompletionCount(for: category, context: context), target)
            
        case .moodStreak(let target):
            progress = min(getMoodStreak(context: context), target)
            
        case .moodVariety(let target):
            progress = min(getUniqueMoodCount(context: context), target)
            
        case .perfectDay:
            progress = hasPerfectDay(context: context) ? 1 : 0
        }
        
        badge.updateProgress(progress)
    }
    
    // Helper functions for requirements checking
    private func getExerciseCompletionCount(for category: ExerciseCategory, context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<ExerciseCompletion>()
        guard let completions = try? context.fetch(descriptor) else { return 0 }
        
        return completions.filter { $0.category == category.rawValue }.count
    }
    
    private func getMoodStreak(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        guard let moodEntries = try? context.fetch(descriptor) else { return 0 }
        
        if moodEntries.isEmpty { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var streak = 0
        var currentDate = today
        
        for entry in moodEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            
            if entryDate == currentDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if entryDate < currentDate {
                // Gap in streak
                break
            }
        }
        
        return streak
    }
    
    private func getUniqueMoodCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<MoodEntry>()
        guard let moodEntries = try? context.fetch(descriptor) else { return 0 }
        
        let uniqueMoods = Set(moodEntries.map { $0.mood })
        return uniqueMoods.count
    }
    
    private func hasPerfectDay(context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<ExerciseCompletion>()
        guard let completions = try? context.fetch(descriptor) else { return false }
        
        let today = Date()
        let todaysCompletions = completions.filter { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: today)
        }
        
        let todaysCategories = Set(todaysCompletions.compactMap { ExerciseCategory(rawValue: $0.category) })
        
        // Check if all 3 categories are completed today
        return todaysCategories.contains(.awareness) && 
               todaysCategories.contains(.balance) && 
               todaysCategories.contains(.reflect)
    }
    
    // Convenience method to check specific badge types
    func checkStreakBadges(for user: User, context: ModelContext) -> [Badge] {
        return checkBadgesOfType(.streak, for: user, context: context)
    }
    
    func checkXPBadges(for user: User, context: ModelContext) -> [Badge] {
        return checkBadgesOfType(.xp, for: user, context: context)
    }
    
    func checkCategoryBadges(for user: User, context: ModelContext) -> [Badge] {
        return checkBadgesOfType(.category, for: user, context: context)
    }
    
    func checkMoodBadges(for user: User, context: ModelContext) -> [Badge] {
        return checkBadgesOfType(.mood, for: user, context: context)
    }
    
    func checkAchievementBadges(for user: User, context: ModelContext) -> [Badge] {
        return checkBadgesOfType(.achievement, for: user, context: context)
    }
    
    private func checkBadgesOfType(_ category: BadgeCategory, for user: User, context: ModelContext) -> [Badge] {
        var newBadges: [Badge] = []
        
        let categoryBadges = badgeManager.getBadgesByCategory(category)
        
        for definition in categoryBadges {
            let badge = findOrCreateBadge(for: definition, user: user, context: context)
            
            if !badge.isEarned && meetsRequirements(definition, user: user, context: context) {
                badge.markAsEarned()
                newBadges.append(badge)
            }
        }
        
        if !newBadges.isEmpty {
            try? context.save()
        }
        
        return newBadges
    }
} 