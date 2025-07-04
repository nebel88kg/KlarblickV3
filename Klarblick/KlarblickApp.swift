//
//  KlarblickApp.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftData
import SwiftUI

@main
struct KlarblickApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: User.self, MoodEntry.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    checkAndResetStreakIfNeeded()
                }
        }
        .modelContainer(modelContainer)
    }
    
    private func checkAndResetStreakIfNeeded() {
        let context = modelContainer.mainContext
        
        let descriptor = FetchDescriptor<User>()
        if let user = try? context.fetch(descriptor).first {
            guard let lastExerciseDate = user.lastExerciseDate else { return }
            
            let today = Calendar.current.startOfDay(for: Date())
            let lastExerciseDay = Calendar.current.startOfDay(for: lastExerciseDate)
            
            // Calculate days difference
            let daysDifference = Calendar.current.dateComponents([.day], from: lastExerciseDay, to: today).day ?? 0
            
            // If last exercise was day before yesterday or earlier, reset streak
            if daysDifference >= 2 {
                user.currentStreak = 0
                try? context.save()
            }
        }
    }
}
