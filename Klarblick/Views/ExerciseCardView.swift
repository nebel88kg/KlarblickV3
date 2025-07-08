//
//  ExerciseCardView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData

struct ExerciseCard {
    let title: String
    let caption: String
    let symbol: String
    let gradient: LinearGradient
    let category: ExerciseCategory
}

struct ExerciseCardView: View {
    @State private var selectedExercise: Exercise?
    @State private var showingExercise = false
    @State private var pressedIndex: Int? = nil
    @State private var completedCategories: Set<ExerciseCategory> = []
    @State private var midnightTimer: Timer?
    @Environment(\.modelContext) private var modelContext
    
    private let exercises = [
        ExerciseCard(
            title: String(localized: "Awareness"),
            caption: String(localized: "Mindful moments to connect with your mind and body"),
            symbol: "eye.fill",
            gradient: LinearGradient(
                colors: [Color.purpleCarolite, Color.afterBurn.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            category: .awareness
        ),
        ExerciseCard(
            title: String(localized: "Balance"),
            caption: String(localized: "Simple actions that create order and stability"),
            symbol: "scale.3d",
            gradient: LinearGradient(
                colors: [Color.purpleCarolite, Color.afterBurn.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            category: .balance
        ),
        ExerciseCard(
            title: String(localized: "Reflect"),
            caption: String(localized: "Process your experiences and emotions"),
            symbol: "brain.head.profile",
            gradient: LinearGradient(
                colors: [Color.purpleCarolite, Color.afterBurn.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            category: .reflect
        )
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(exercises.indices, id: \.self) { index in
                let isCompleted = completedCategories.contains(exercises[index].category)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercises[index].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isCompleted ? .gray : .ambrosiaIvory)
                        
                        Text(isCompleted ? "Completed today!" : exercises[index].caption)
                            .font(.caption2)
                            .italic()
                            .foregroundColor(isCompleted ? .gray : .gray2)
                    }
                    .padding(.trailing, 85)
                    
                    Spacer()
                    
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : exercises[index].symbol)
                        .font(.system(size: 40))
                        .foregroundColor(isCompleted ? .gray : .white)
                        .shadow(color: isCompleted ? .clear : .yellow.opacity(0.6), radius: 8, x: 0, y: 0)
                        .shadow(color: isCompleted ? .clear : .yellow.opacity(0.3), radius: 16, x: 0, y: 0)
                        .scaleEffect(pressedIndex == index ? 0.9 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressedIndex)
                }
                .frame(height: 110)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .background(
                    isCompleted ? 
                    LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) : 
                    exercises[index].gradient
                )
                .cornerRadius(20)
                .scaleEffect(pressedIndex == index ? 0.95 : 1.0)
                .shadow(color: .black.opacity(0.3), radius: pressedIndex == index ? 2 : 8, x: 0, y: pressedIndex == index ? 2 : 4)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressedIndex)
                .onTapGesture {
                    if !isCompleted {
                        performHapticFeedback(.medium)
                        selectRandomExercise(from: exercises[index].category)
                    }
                }
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    if !isCompleted {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            pressedIndex = pressing ? index : nil
                        }
                    }
                }, perform: {})
            }
        }
        .onAppear {
            loadTodaysCompletions()
            scheduleAutomaticReset()
        }
        .onDisappear {
            midnightTimer?.invalidate()
            midnightTimer = nil
        }
        .fullScreenCover(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise, isFromCardView: true, onCompletion: {
                markCategoryAsCompleted(exercise.category)
            })
        }
    }
    
    private func scheduleAutomaticReset() {
        // Cancel existing timer
        midnightTimer?.invalidate()
        
        // Calculate time until next midnight
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let nextMidnight = calendar.startOfDay(for: tomorrow)
        let timeUntilMidnight = nextMidnight.timeIntervalSince(now)
        
        // Schedule timer for midnight
        midnightTimer = Timer.scheduledTimer(withTimeInterval: timeUntilMidnight, repeats: false) { _ in
            completedCategories.removeAll()
            loadTodaysCompletions()
        }
    }
    
    private func loadTodaysCompletions() {
        let descriptor = FetchDescriptor<ExerciseCompletion>()
        guard let completions = try? modelContext.fetch(descriptor) else {
            return
        }
        
        let today = Date()
        let todaysCompletions = completions.filter { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: today) && completion.source == "cardView"
        }
        
        completedCategories = Set(todaysCompletions.compactMap { completion in
            ExerciseCategory(rawValue: completion.category)
        })
    }
    
    private func markCategoryAsCompleted(_ category: ExerciseCategory) {
        // Check if already completed today
        let descriptor = FetchDescriptor<ExerciseCompletion>()
        guard let completions = try? modelContext.fetch(descriptor) else {
            return
        }
        
        let today = Date()
        let hasCompletionToday = completions.contains { completion in
            Calendar.current.isDate(completion.date, inSameDayAs: today) && 
            completion.category == category.rawValue && 
            completion.source == "cardView"
        }
        
        if !hasCompletionToday {
            let newCompletion = ExerciseCompletion(date: today, category: category, source: "cardView")
            modelContext.insert(newCompletion)
            
            do {
                try modelContext.save()
                completedCategories.insert(category)
            } catch {
                // Handle save errors silently
            }
        }
    }
    
    private func selectRandomExercise(from category: ExerciseCategory) {
        if let randomExercise = ExerciseLibrary.getRandomExercise(from: category) {
            selectedExercise = randomExercise
        }
    }
    
    private func performHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    ExerciseCardView()
        .padding()
        .padding(.leading, 20)
        .background(Color.gray.opacity(0.1))
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self, ExerciseCompletion.self])
} 
