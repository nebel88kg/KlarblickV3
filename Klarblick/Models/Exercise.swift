//
//  Exercise.swift
//  Klarblick
//
//  Created by Dominik Nebel on 02.07.25.
//

import Foundation

// MARK: - Exercise Categories
enum ExerciseCategory: String, CaseIterable {
    case awareness = "Awareness"
    case balance = "Balance"
    case reflect = "Reflect"
}

// MARK: - Exercise Types
enum ExerciseType: String, CaseIterable {
    case textPrompt = "Text Prompt"
    case interactive = "Interactive"
}

// MARK: - Interactive Element Types
enum InteractiveElementType: String, CaseIterable {
    case timer = "Timer"
    case singleWordField = "Single Word Field"
    case longTextArea = "Long Text Area"
}

// MARK: - Exercise Instruction
struct ExerciseInstruction: Identifiable {
    let id = UUID()
    let text: String
    let hasInteractiveElement: Bool
    let interactiveElementType: InteractiveElementType?
    
    init(text: String, hasInteractiveElement: Bool = false, interactiveElementType: InteractiveElementType? = nil) {
        self.text = text
        self.hasInteractiveElement = hasInteractiveElement
        self.interactiveElementType = interactiveElementType
    }
}

// MARK: - Exercise Model
struct Exercise: Identifiable {
    let id = UUID()
    let title: String
    let category: ExerciseCategory
    let type: ExerciseType
    let duration: Int? // Duration in seconds for timed exercises
    let instructions: [ExerciseInstruction]
    let textFieldCount: Int? // Number of text fields for single word exercises
    let shortDescription: String
    
    init(title: String, category: ExerciseCategory, type: ExerciseType, duration: Int? = nil, instructions: [ExerciseInstruction], textFieldCount: Int? = nil, shortDescription: String) {
        self.title = title
        self.category = category
        self.type = type
        self.duration = duration
        self.instructions = instructions
        self.textFieldCount = textFieldCount
        self.shortDescription = shortDescription
    }
}

// MARK: - Exercise Library
struct ExerciseLibrary {
    static let predefinedExercises: [Exercise] = [
        // AWARENESS EXERCISES
        Exercise(
            title: "Mindful Breathing",
            category: .awareness,
            type: .interactive,
            duration: 60,
            instructions: [
                ExerciseInstruction(text: "Find a comfortable position and close your eyes"),
                ExerciseInstruction(text: "Focus on your breath and breathe deeply", hasInteractiveElement: true, interactiveElementType: .timer),
                ExerciseInstruction(text: "Notice how you feel after this breathing exercise")
            ],
            shortDescription: "60 seconds of mindful breathing"
        ),
        
        Exercise(
            title: "Window Gazing",
            category: .awareness,
            type: .interactive,
            duration: 60,
            instructions: [
                ExerciseInstruction(text: "Look out the window for 60 seconds"),
                ExerciseInstruction(text: "Breathe deeply and notice what you see", hasInteractiveElement: true, interactiveElementType: .timer),
                ExerciseInstruction(text: "How do you feel after this moment of observation?")
            ],
            shortDescription: "Look outside and breathe deeply"
        ),
        
        Exercise(
            title: "Body Awareness",
            category: .awareness,
            type: .interactive,
            duration: 120,
            instructions: [
                ExerciseInstruction(text: "Sit comfortably and close your eyes"),
                ExerciseInstruction(text: "Move gently for 2 minutes - stretch, walk, or dance", hasInteractiveElement: true, interactiveElementType: .timer),
                ExerciseInstruction(text: "Notice how your body feels after movement")
            ],
            shortDescription: "2 minutes of mindful movement"
        ),
        
        Exercise(
            title: "Mindful Pause",
            category: .awareness,
            type: .interactive,
            duration: 30,
            instructions: [
                ExerciseInstruction(text: "Breathe naturally and just be present"),
                ExerciseInstruction(text: "Open your eyes when ready"),
                ExerciseInstruction(text: "Close your eyes for 30 seconds", hasInteractiveElement: true, interactiveElementType: .timer)
            ],
            shortDescription: "30 seconds of mindful presence"
        ),
        
        Exercise(
            title: "Hydration Check",
            category: .awareness,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: "Drink a glass of water"),
                ExerciseInstruction(text: "Notice how the water feels and tastes"),
                ExerciseInstruction(text: "Take a moment to appreciate staying hydrated")
            ],
            shortDescription: "Stay hydrated mindfully"
        ),
        
        Exercise(
            title: "Digital Declutter",
            category: .awareness,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: "Close one open tab or distracting app"),
                ExerciseInstruction(text: "Notice how it feels to reduce digital clutter"),
                ExerciseInstruction(text: "Consider what apps truly serve you")
            ],
            shortDescription: "Reduce digital distractions"
        ),
        
//MARK: -  BALANCE EXERCISES
        Exercise(
            title: "Priority Setting",
            category: .balance,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: "Think about your day ahead"),
                ExerciseInstruction(text: "Write down 3 things you want to do today", hasInteractiveElement: true, interactiveElementType: .singleWordField),
                ExerciseInstruction(text: "Choose which one is most important")
            ],
            textFieldCount: 3,
            shortDescription: "Set your daily priorities"
        ),
        
        Exercise(
            title: "Next Task Focus",
            category: .balance,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: "Consider what you need to accomplish"),
                ExerciseInstruction(text: "Write down one task you want to do next", hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: "Commit to starting this task")
            ],
            shortDescription: "Focus on your next action"
        ),
        
        Exercise(
            title: "Quick Tidy",
            category: .balance,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: "Look around your space"),
                ExerciseInstruction(text: "Tidy up one single surface"),
                ExerciseInstruction(text: "Enjoy the sense of order you've created")
            ],
            shortDescription: "Create order in your space"
        ),
        
        Exercise(
            title: "Organization Boost",
            category: .balance,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: "Find 3 things that are out of place"),
                ExerciseInstruction(text: "Put them back where they belong"),
                ExerciseInstruction(text: "Notice how organization affects your mood")
            ],
            shortDescription: "Restore order to your environment"
        ),
        
        Exercise(
            title: "Digital Cleanup",
            category: .balance,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: "Open your email or file manager"),
                ExerciseInstruction(text: "Delete 5 unnecessary emails or files"),
                ExerciseInstruction(text: "Feel the satisfaction of digital decluttering")
            ],
            shortDescription: "Clean up digital clutter"
        ),
        
        Exercise(
            title: "Task Relief",
            category: .balance,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: "Think of an overdue task that's weighing on you"),
                ExerciseInstruction(text: "Move it to tomorrow — guilt-free"),
                ExerciseInstruction(text: "Remember: it's okay to reschedule")
            ],
            shortDescription: "Release task pressure"
        ),
        
        // REFLECT EXERCISES
        Exercise(
            title: "Brain Dump",
            category: .reflect,
            type: .interactive,
            duration: 120,
            instructions: [
                ExerciseInstruction(text: "Set a timer for 2 minutes"),
                ExerciseInstruction(text: "Write everything on your mind", hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: "Don't worry about organization, just let it flow")
            ],
            shortDescription: "Clear your mind through writing"
        ),
        
        Exercise(
            title: "Daily Acknowledgment",
            category: .reflect,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: "Think about your day so far"),
                ExerciseInstruction(text: "Write down one thing you did well today", hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: "Take a moment to appreciate your effort")
            ],
            shortDescription: "Recognize your achievements"
        ),
        
        Exercise(
            title: "Gratitude Moment",
            category: .reflect,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: "Pause and look around you"),
                ExerciseInstruction(text: "Write down one thing you're grateful for", hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: "Feel the warmth of gratitude")
            ],
            shortDescription: "Practice gratitude"
        ),
        
        Exercise(
            title: "Future Focus",
            category: .reflect,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: "Reflect on your experiences today"),
                ExerciseInstruction(text: "What do you want to try differently tomorrow?", hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: "Set a gentle intention for tomorrow")
            ],
            shortDescription: "Plan for tomorrow"
        ),
        
        Exercise(
            title: "Day Summary",
            category: .reflect,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: "Think about your entire day"),
                ExerciseInstruction(text: "Write a 3-word summary of your day", hasInteractiveElement: true, interactiveElementType: .singleWordField),
                ExerciseInstruction(text: "Reflect on what those words mean to you")
            ],
            textFieldCount: 3,
            shortDescription: "Summarize your day"
        ),
        
        Exercise(
            title: "Creative Expression",
            category: .reflect,
            type: .interactive,
            duration: 60,
            instructions: [
                ExerciseInstruction(text: "Get a piece of paper or open a drawing app"),
                ExerciseInstruction(text: "Scribble or doodle for 1 minute", hasInteractiveElement: true, interactiveElementType: .timer),
                ExerciseInstruction(text: "Let your creativity flow without judgment")
            ],
            shortDescription: "Express yourself creatively"
        )
    ]
    
    // MARK: - Convenience methods
    static func exercisesByCategory(_ category: ExerciseCategory) -> [Exercise] {
        return predefinedExercises.filter { $0.category == category }
    }
    
    static func exercisesByType(_ type: ExerciseType) -> [Exercise] {
        return predefinedExercises.filter { $0.type == type }
    }
    
    static func timedExercises() -> [Exercise] {
        return predefinedExercises.filter { $0.duration != nil }
    }
    
    static func interactiveExercises() -> [Exercise] {
        return predefinedExercises.filter { $0.type == .interactive }
    }
    
    static func getRandomExercise() -> Exercise {
        return predefinedExercises.randomElement() ?? predefinedExercises[0]
    }
    
    static func getRandomExercise(from category: ExerciseCategory) -> Exercise? {
        let categoryExercises = exercisesByCategory(category)
        return categoryExercises.randomElement()
    }
} 
