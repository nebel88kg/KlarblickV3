//
//  MoodEmojiSelector.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData

struct MoodEmojiSelector: View {
    @State private var selectedMood: Int? = nil
    @Environment(\.modelContext) private var modelContext
    @State private var midnightTimer: Timer?
    
    private let moods: [(imageName: String, id: Int)] = [
        ("smiley1", 0),
        ("smiley2", 1),
        ("smiley3", 2),
        ("smiley4", 3),
        ("smiley5", 4)
    ]
    
    var body: some View {
        VStack{
            HStack {
                ForEach(0..<moods.count, id: \.self) { index in
                    if index > 0 {
                        Spacer()
                    }
                    MoodPill(
                        imageName: moods[index].imageName,
                        isSelected: selectedMood == index,
                        moodIndex: index
                    ) {
                        selectedMood = index
                    }
                }
            }
            HStack {
                Text("Very Happy")
                    .font(.caption)
                    .foregroundColor(.wildMaple)
                
                Spacer()
                
                Text("Stressed")
                    .font(.caption)
                    .foregroundColor(.wildMaple)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .onAppear {
            loadTodaysMoodSelection()
            scheduleAutomaticReset()
        }
        .onDisappear {
            midnightTimer?.invalidate()
            midnightTimer = nil
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
            selectedMood = nil
            loadTodaysMoodSelection() // Check for new day's mood
        }
    }
    
    private func loadTodaysMoodSelection() {
        let descriptor = FetchDescriptor<MoodEntry>()
        guard let moodEntries = try? modelContext.fetch(descriptor) else {
            return
        }
        
        let today = Date()
        if let todaysMoodEntry = moodEntries.first(where: { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: today)
        }) {
            let moodStrings = ["Very Happy", "Happy", "Neutral", "Sad", "Stressed"]
            if let moodIndex = moodStrings.firstIndex(of: todaysMoodEntry.mood) {
                selectedMood = moodIndex
            }
        }
    }
}

struct MoodPill: View {
    let imageName: String
    let isSelected: Bool
    let moodIndex: Int
    let onTap: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Button(action: onClick) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            .frame(width: 63, height: 86)
            .background(
                RoundedRectangle(cornerRadius: 100)
                    .fill(
                        isSelected ? 
                        LinearGradient(
                            colors: [Color.afterBurn.opacity(0.8), Color.mangosteenViolet.opacity(1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.backgroundSecondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(
                        Color.mangosteenViolet, lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//MARK: - Logic
extension MoodPill {
    private func awardXp(_ amount: Int) {
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            user.currentXp += amount
        }
    }
    
    private func onClick() {
        // 1. Check for existing mood entry today FIRST
        let hasMoodEntryToday = checkForMoodEntryToday()
        
        // 2. Update/create mood entry in SwiftData
        saveMoodEntry()
        
        // 3. Update visual selection
        onTap() // This calls the parent's closure to update selectedMood binding
        
        // 4. Award XP only if first mood today
        if !hasMoodEntryToday {
            awardXp(50)
        }
        // 5. Make selection persistent until midnight
        // Selection persistence is handled by onAppear in the parent view
    }
    
    private func checkForMoodEntryToday() -> Bool {
        let descriptor = FetchDescriptor<MoodEntry>()
        guard let moodEntries = try? modelContext.fetch(descriptor) else {
            return false
        }
        
        let today = Date()
        let hasEntryToday = moodEntries.contains { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: today)
        }
        
        return hasEntryToday
    }
    
    private func saveMoodEntry() {
        let moodStrings = ["Very Happy", "Happy", "Neutral", "Sad", "Stressed"]
        let moodString = moodStrings[moodIndex]
        
        let descriptor = FetchDescriptor<MoodEntry>()
        guard let moodEntries = try? modelContext.fetch(descriptor) else {
            return
        }
        
        let today = Date()
        
        // Check if there's already a mood entry for today
        if let existingEntry = moodEntries.first(where: { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: today)
        }) {
            // Update existing entry
            existingEntry.mood = moodString
        } else {
            // Create new entry
            let newMoodEntry = MoodEntry(
                date: today,
                mood: moodString
            )
            modelContext.insert(newMoodEntry)
        }
        
        // Try to save the context
        do {
            try modelContext.save()
        } catch {
            // Handle save errors silently
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        Text("Mood Selector")
            .font(.title2)
            .fontWeight(.semibold)
        
        MoodEmojiSelector()
            .modelContainer(for: [User.self, MoodEntry.self])

        
        Text("No Selection")
            .font(.caption)
            .foregroundColor(.secondary)
        
        MoodEmojiSelector()
            .modelContainer(for: [User.self, MoodEntry.self])
    }
    .padding()
} 
