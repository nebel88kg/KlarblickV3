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
    @State private var showMoodSheet = false
    @Environment(\.modelContext) private var modelContext
    @State private var midnightTimer: Timer?
    @State private var isInitialLoad = true
    
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
                        moodIndex: index,
                        isInitialLoad: isInitialLoad
                    ) {
                        selectedMood = index
                        showMoodSheet = true
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
        .sheet(isPresented: $showMoodSheet) {
            MoodNoteSheet(isPresented: $showMoodSheet, selectedMoodIndex: selectedMood)
        }
        .onAppear {
            loadTodaysMoodSelection()
            scheduleAutomaticReset()
            
            // Enable animations after initial load
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInitialLoad = false
            }
        }
        .onDisappear {
            midnightTimer?.invalidate()
            midnightTimer = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh state when app enters foreground (new day check)
            loadTodaysMoodSelection()
            scheduleAutomaticReset()
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
            selectedMood = nil // Reset if can't fetch
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
        } else {
            // FIX: Reset selectedMood if no entry for today
            selectedMood = nil
        }
    }
    
}

struct MoodPill: View {
    let imageName: String
    let isSelected: Bool
    let moodIndex: Int
    let isInitialLoad: Bool
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
            .animation(isInitialLoad ? .none : .easeInOut(duration: 0.2), value: isSelected)
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
            
            // Check for new badges after XP award (notifications handled by parent view)
            _ = BadgeChecker.shared.checkForNewBadges(for: user, context: modelContext)
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
            awardXp(5)
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
        
        // Check if there's already a mood entry for today (before making changes)
        _ = moodEntries.contains { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: today)
        }
        
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
            
            // Cancel today's mood reminder if this is a new entry
            NotificationManager.shared.checkAndCancelTodaysNotifications(context: modelContext)
        } catch {
            // Handle save errors silently
        }
    }
}

// MARK: - MoodNoteSheet
struct MoodNoteSheet: View {
    @Binding var isPresented: Bool
    let selectedMoodIndex: Int?
    @State private var noteText = ""
    @Environment(\.modelContext) private var modelContext
    
    private let moodStrings = [
        String(localized: "Very Happy"),
        String(localized: "Happy"),
        String(localized: "Neutral"),
        String(localized: "Sad"),
        String(localized: "Stressed")
    ]
    
    private var selectedMoodString: String {
        guard let index = selectedMoodIndex, index < moodStrings.count else {
            return "Unknown"
        }
        return moodStrings[index]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Why are you feeling \(selectedMoodString.lowercased())?")
                    .font(.headline)
                    .foregroundColor(.ambrosiaIvory)
                
                TextField("Write your thoughts...", text: $noteText, axis: .vertical)
                    .lineLimit(4...8)
                    .padding(.horizontal, 4)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.wildMaple)
                    .padding(20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .colorScheme(.dark)  // Add this to force dark mode
            }
            
            HStack {
                Spacer()
                
                Button("Add Note") {
                    saveNoteToLatestMoodEntry()
                    isPresented = false
                }
                .font(.headline)
                .foregroundColor(.ambrosiaIvory)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.afterBurn.opacity(0.8), Color.mangosteenViolet.opacity(1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                
                Spacer()
                
                Button("Not now") {
                    isPresented = false
                }
                .font(.headline)
                .foregroundColor(.gray2)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray2, lineWidth: 2)
                )
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(300), .medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.backgroundSecondary)
        .onAppear {
            loadExistingNote()
        }
    }
    
    private func loadExistingNote() {
        let descriptor = FetchDescriptor<MoodEntry>()
        guard let moodEntries = try? modelContext.fetch(descriptor) else { return }
        
        let today = Date()
        
        // Find today's mood entry and load its note
        if let todaysMoodEntry = moodEntries.first(where: { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: today)
        }) {
            noteText = todaysMoodEntry.note ?? ""
        }
    }

    
    private func saveNoteToLatestMoodEntry() {
        // Don't save empty notes
        guard !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let descriptor = FetchDescriptor<MoodEntry>()
        guard let moodEntries = try? modelContext.fetch(descriptor) else { return }
        
        let today = Date()
        
        // Find today's mood entry
        if let todaysMoodEntry = moodEntries.first(where: { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: today)
        }) {
            // Update the note for today's mood entry
            todaysMoodEntry.note = noteText
            
            // Save the context
            do {
                try modelContext.save()
            } catch {
                // Handle save errors silently
                print("Error saving note: \(error)")
            }
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
            .modelContainer(for: [User.self, MoodEntry.self, Badge.self])

        
        Text("No Selection")
            .font(.caption)
            .foregroundColor(.secondary)
        
        MoodEmojiSelector()
            .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
    }
    .padding()
} 
