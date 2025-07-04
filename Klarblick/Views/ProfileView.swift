//
//  ProfileView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var moodEntries: [MoodEntry]
    @Query private var users: [User]
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("Your Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Stats Section
                if let user = users.first {
                    VStack(spacing: 12) {
                        HStack(spacing: 40) {
                            StatItem(title: "XP", value: "\(user.currentXp)")
                            StatItem(title: "Level", value: "\(user.currentXp / 100 + 1)")
                            StatItem(title: "Streak", value: "\(user.currentStreak)")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                        .background(Color.backgroundSecondary.opacity(0.5))
                        .cornerRadius(12)
                    }
                }
                
                // Mood History Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Mood History")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(moodEntries.count) entries")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !moodEntries.isEmpty {
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    if moodEntries.isEmpty {
                        Text("No mood entries yet. Start tracking your mood!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 20)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(moodEntries) { entry in
                                    MoodHistoryRow(entry: entry)
                                }
                            }
                        }
                        .frame(maxHeight: 400)
                    }
                }
                .padding()
                .background(Color.backgroundSecondary.opacity(0.3))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete All Mood Entries", isPresented: $showingDeleteConfirmation) {
            Button("Delete All", role: .destructive) {
                deleteAllMoodEntries()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete all \(moodEntries.count) mood entries? This action cannot be undone.")
        }
    }
    
    private func deleteAllMoodEntries() {
        // Delete all mood entries
        for entry in moodEntries {
            modelContext.delete(entry)
        }
        
        // Save the context
        do {
            try modelContext.save()
        } catch {
            // Handle save errors silently
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct MoodHistoryRow: View {
    let entry: MoodEntry
    
    private var moodEmoji: String {
        switch entry.mood {
        case "Very Happy": return "😄"
        case "Happy": return "😊"
        case "Neutral": return "😐"
        case "Sad": return "😔"
        case "Stressed": return "😰"
        default: return "😐"
        }
    }
    
    private var moodColor: Color {
        switch entry.mood {
        case "Very Happy": return .green
        case "Happy": return .blue
        case "Neutral": return .gray
        case "Sad": return .orange
        case "Stressed": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        HStack {
            // Mood Emoji
            Text(moodEmoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(moodColor.opacity(0.2))
                .cornerRadius(8)
            
            // Mood Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mood)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time ago
            Text(timeAgoString(from: entry.date))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.backgroundSecondary.opacity(0.5))
        .cornerRadius(8)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else {
            return "Now"
        }
    }
}


#Preview {
    ProfileView()
        .modelContainer(for: [User.self, MoodEntry.self])
} 
