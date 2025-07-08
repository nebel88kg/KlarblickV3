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
    
    var localizedName: String {
        switch self {
        case .awareness:
            return String(localized: "Awareness")
        case .balance:
            return String(localized: "Balance")
        case .reflect:
            return String(localized: "Reflect")
        }
    }
}

// MARK: - Exercise Types
enum ExerciseType: String, CaseIterable {
    case textPrompt = "Text Prompt"
    case interactive = "Interactive"
    
    var localizedName: String {
        switch self {
        case .textPrompt:
            return String(localized: "exercise.type.text_prompt")
        case .interactive:
            return String(localized: "exercise.type.interactive")
        }
    }
}

// MARK: - Interactive Element Types
enum InteractiveElementType: String, CaseIterable {
    case timer = "Timer"
    case singleWordField = "Single Word Field"
    case longTextArea = "Long Text Area"
    
    var localizedName: String {
        switch self {
        case .timer:
            return String(localized: "exercise.interactive.timer")
        case .singleWordField:
            return String(localized: "exercise.interactive.single_word_field")
        case .longTextArea:
            return String(localized: "exercise.interactive.long_text_area")
        }
    }
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
            title: String(localized: "exercise.mindful_breathing.title"),
            category: .awareness,
            type: .interactive,
            duration: 60,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.mindful_breathing.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.mindful_breathing.instruction.2"), hasInteractiveElement: true, interactiveElementType: .timer),
                ExerciseInstruction(text: String(localized: "exercise.mindful_breathing.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.mindful_breathing.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.window_gazing.title"),
            category: .awareness,
            type: .interactive,
            duration: 60,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.window_gazing.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.window_gazing.instruction.2"), hasInteractiveElement: true, interactiveElementType: .timer),
                ExerciseInstruction(text: String(localized: "exercise.window_gazing.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.window_gazing.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.body_awareness.title"),
            category: .awareness,
            type: .interactive,
            duration: 120,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.body_awareness.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.body_awareness.instruction.2"), hasInteractiveElement: true, interactiveElementType: .timer),
                ExerciseInstruction(text: String(localized: "exercise.body_awareness.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.body_awareness.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.mindful_pause.title"),
            category: .awareness,
            type: .interactive,
            duration: 30,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.mindful_pause.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.mindful_pause.instruction.2")),
                ExerciseInstruction(text: String(localized: "exercise.mindful_pause.instruction.3"), hasInteractiveElement: true, interactiveElementType: .timer)
            ],
            shortDescription: String(localized: "exercise.mindful_pause.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.hydration_check.title"),
            category: .awareness,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.hydration_check.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.hydration_check.instruction.2")),
                ExerciseInstruction(text: String(localized: "exercise.hydration_check.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.hydration_check.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.digital_declutter.title"),
            category: .awareness,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.digital_declutter.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.digital_declutter.instruction.2")),
                ExerciseInstruction(text: String(localized: "exercise.digital_declutter.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.digital_declutter.description")
        ),
        
//MARK: -  BALANCE EXERCISES
        Exercise(
            title: String(localized: "exercise.priority_setting.title"),
            category: .balance,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.priority_setting.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.priority_setting.instruction.2"), hasInteractiveElement: true, interactiveElementType: .singleWordField),
                ExerciseInstruction(text: String(localized: "exercise.priority_setting.instruction.3"))
            ],
            textFieldCount: 3,
            shortDescription: String(localized: "exercise.priority_setting.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.next_task_focus.title"),
            category: .balance,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.next_task_focus.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.next_task_focus.instruction.2"), hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: String(localized: "exercise.next_task_focus.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.next_task_focus.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.quick_tidy.title"),
            category: .balance,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.quick_tidy.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.quick_tidy.instruction.2")),
                ExerciseInstruction(text: String(localized: "exercise.quick_tidy.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.quick_tidy.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.organization_boost.title"),
            category: .balance,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.organization_boost.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.organization_boost.instruction.2")),
                ExerciseInstruction(text: String(localized: "exercise.organization_boost.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.organization_boost.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.digital_cleanup.title"),
            category: .balance,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.digital_cleanup.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.digital_cleanup.instruction.2")),
                ExerciseInstruction(text: String(localized: "exercise.digital_cleanup.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.digital_cleanup.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.task_relief.title"),
            category: .balance,
            type: .textPrompt,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.task_relief.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.task_relief.instruction.2")),
                ExerciseInstruction(text: String(localized: "exercise.task_relief.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.task_relief.description")
        ),
        
        // REFLECT EXERCISES
        Exercise(
            title: String(localized: "exercise.brain_dump.title"),
            category: .reflect,
            type: .interactive,
            duration: 120,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.brain_dump.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.brain_dump.instruction.2"), hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: String(localized: "exercise.brain_dump.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.brain_dump.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.daily_acknowledgment.title"),
            category: .reflect,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.daily_acknowledgment.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.daily_acknowledgment.instruction.2"), hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: String(localized: "exercise.daily_acknowledgment.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.daily_acknowledgment.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.gratitude_moment.title"),
            category: .reflect,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.gratitude_moment.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.gratitude_moment.instruction.2"), hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: String(localized: "exercise.gratitude_moment.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.gratitude_moment.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.future_focus.title"),
            category: .reflect,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.future_focus.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.future_focus.instruction.2"), hasInteractiveElement: true, interactiveElementType: .longTextArea),
                ExerciseInstruction(text: String(localized: "exercise.future_focus.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.future_focus.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.day_summary.title"),
            category: .reflect,
            type: .interactive,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.day_summary.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.day_summary.instruction.2"), hasInteractiveElement: true, interactiveElementType: .singleWordField),
                ExerciseInstruction(text: String(localized: "exercise.day_summary.instruction.3"))
            ],
            textFieldCount: 3,
            shortDescription: String(localized: "exercise.day_summary.description")
        ),
        
        Exercise(
            title: String(localized: "exercise.creative_expression.title"),
            category: .reflect,
            type: .interactive,
            duration: 60,
            instructions: [
                ExerciseInstruction(text: String(localized: "exercise.creative_expression.instruction.1")),
                ExerciseInstruction(text: String(localized: "exercise.creative_expression.instruction.2"), hasInteractiveElement: true, interactiveElementType: .timer),
                ExerciseInstruction(text: String(localized: "exercise.creative_expression.instruction.3"))
            ],
            shortDescription: String(localized: "exercise.creative_expression.description")
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
