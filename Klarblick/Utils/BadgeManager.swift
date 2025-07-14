//
//  BadgeManager.swift
//  Klarblick
//
//  Created by Dominik Nebel on 05.07.25.
//

import Foundation
import SwiftData

// MARK: - Badge Enums
enum BadgeCategory: String, CaseIterable {
    case streak = "streak"
    case xp = "xp"
    case category = "category"
    case mood = "mood"
    case achievement = "achievement"
}

enum BadgeRarity: String, CaseIterable {
    case common = "common"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
}

enum BadgeRequirement {
    case streak(Int)
    case totalXP(Int)
    case categoryCount(ExerciseCategory, Int)
    case moodStreak(Int)
    case moodVariety(Int) // Log different moods
    case perfectDay // Complete all 3 exercise types in one day
}

// MARK: - Badge Definition
struct BadgeDefinition {
    let id: String
    let name: String
    let description: String
    let category: BadgeCategory
    let requirement: BadgeRequirement
    let rarity: BadgeRarity
    let iconName: String
}

// MARK: - Badge Manager
class BadgeManager {
    static let shared = BadgeManager()
    
    private init() {}
    
    // Define all available badges
    let availableBadges: [BadgeDefinition] = [
        // Streak badges
        BadgeDefinition(
            id: "streak_3",
            name: "First Steps",
            description: "Complete exercises 3 days in a row",
            category: .streak,
            requirement: .streak(3),
            rarity: .common,
            iconName: "flame"
        ),
        BadgeDefinition(
            id: "streak_7",
            name: "Getting Warmer",
            description: "Complete exercises 7 days in a row",
            category: .streak,
            requirement: .streak(7),
            rarity: .common,
            iconName: "flame.fill"
        ),
        BadgeDefinition(
            id: "streak_15",
            name: "On Fire",
            description: "Complete exercises 15 days in a row",
            category: .streak,
            requirement: .streak(15),
            rarity: .rare,
            iconName: "flame.circle.fill"
        ),
        BadgeDefinition(
            id: "streak_30",
            name: "Unstoppable",
            description: "Complete exercises 30 days in a row",
            category: .streak,
            requirement: .streak(30),
            rarity: .epic,
            iconName: "flame.circle.fill"
        ),
        
        // XP badges
        BadgeDefinition(
            id: "xp_100",
            name: "Rising Star",
            description: "Earn 100 XP",
            category: .xp,
            requirement: .totalXP(100),
            rarity: .common,
            iconName: "star"
        ),
        BadgeDefinition(
            id: "xp_250",
            name: "Shining Bright",
            description: "Earn 250 XP",
            category: .xp,
            requirement: .totalXP(250),
            rarity: .common,
            iconName: "star.fill"
        ),
        BadgeDefinition(
            id: "xp_500",
            name: "Experienced",
            description: "Earn 500 XP",
            category: .xp,
            requirement: .totalXP(500),
            rarity: .rare,
            iconName: "star.circle"
        ),
        BadgeDefinition(
            id: "xp_1000",
            name: "Expert",
            description: "Earn 1000 XP",
            category: .xp,
            requirement: .totalXP(1000),
            rarity: .epic,
            iconName: "star.circle.fill"
        ),
        
        // Category badges
        BadgeDefinition(
            id: "awareness_10",
            name: "Awareness Apprentice",
            description: "Complete 10 awareness exercises",
            category: .category,
            requirement: .categoryCount(.awareness, 10),
            rarity: .common,
            iconName: "eye"
        ),
        BadgeDefinition(
            id: "awareness_25",
            name: "Awareness Master",
            description: "Complete 25 awareness exercises",
            category: .category,
            requirement: .categoryCount(.awareness, 25),
            rarity: .rare,
            iconName: "eye.fill"
        ),
        BadgeDefinition(
            id: "balance_10",
            name: "Balance Beginner",
            description: "Complete 10 balance exercises",
            category: .category,
            requirement: .categoryCount(.balance, 10),
            rarity: .common,
            iconName: "scale.3d"
        ),
        BadgeDefinition(
            id: "balance_25",
            name: "Balance Expert",
            description: "Complete 25 balance exercises",
            category: .category,
            requirement: .categoryCount(.balance, 25),
            rarity: .rare,
            iconName: "scalemass"
        ),
        BadgeDefinition(
            id: "reflect_10",
            name: "Reflection Rookie",
            description: "Complete 10 reflect exercises",
            category: .category,
            requirement: .categoryCount(.reflect, 10),
            rarity: .common,
            iconName: "brain.head.profile"
        ),
        BadgeDefinition(
            id: "reflect_25",
            name: "Reflection Sage",
            description: "Complete 25 reflect exercises",
            category: .category,
            requirement: .categoryCount(.reflect, 25),
            rarity: .rare,
            iconName: "brain.head.profile.fill"
        ),
        
        // Mood badges
        BadgeDefinition(
            id: "mood_streak_7",
            name: "Mood Tracker",
            description: "Log your mood 7 days in a row",
            category: .mood,
            requirement: .moodStreak(7),
            rarity: .common,
            iconName: "heart"
        ),
        BadgeDefinition(
            id: "mood_streak_30",
            name: "Emotional Awareness",
            description: "Log your mood 30 days in a row",
            category: .mood,
            requirement: .moodStreak(30),
            rarity: .rare,
            iconName: "heart.fill"
        ),
        BadgeDefinition(
            id: "mood_variety",
            name: "Feeling Spectrum",
            description: "Log all 5 different moods",
            category: .mood,
            requirement: .moodVariety(5),
            rarity: .common,
            iconName: "face.smiling"
        ),
        
        // Achievement badges
        BadgeDefinition(
            id: "perfect_day",
            name: "Perfectionist",
            description: "Complete all 3 exercise types in one day",
            category: .achievement,
            requirement: .perfectDay,
            rarity: .rare,
            iconName: "trophy"
        )
    ]
    
    func getBadgeDefinition(by id: String) -> BadgeDefinition? {
        return availableBadges.first { $0.id == id }
    }
    
    func getBadgesByCategory(_ category: BadgeCategory) -> [BadgeDefinition] {
        return availableBadges.filter { $0.category == category }
    }
    
    func getBadgesByRarity(_ rarity: BadgeRarity) -> [BadgeDefinition] {
        return availableBadges.filter { $0.rarity == rarity }
    }
    
    // Initialize badges for a user
    func initializeBadgesForUser(_ user: User, context: ModelContext) {
        // Check if user already has badges initialized
        let existingBadgeIds = Set(user.badges.map { $0.id })
        
        // Add any missing badges
        for definition in availableBadges {
            if !existingBadgeIds.contains(definition.id) {
                let badge = Badge(
                    id: definition.id,
                    name: definition.name,
                    description: definition.description,
                    category: definition.category,
                    rarity: definition.rarity,
                    iconName: definition.iconName
                )
                user.badges.append(badge)
                context.insert(badge)
            }
        }
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Error initializing badges for user: \(error)")
        }
    }
} 