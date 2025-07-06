//
//  ProfileView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var moodEntries: [MoodEntry]
    @Query private var users: [User]
    @State private var showingDeleteConfirmation = false
    @State private var showingSettings = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingPhotoPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Avatar Section
                VStack(spacing: 0) {
                    // Avatar Circle
                    Button(action: { showingPhotoPicker = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.ambrosiaIvory)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color.purpleCarolite, lineWidth: 2)
                                )
                            
                            // Avatar content - profile picture, first letter of name, or default icon
                            if let user = users.first, let profileData = user.profilePictureData, let uiImage = UIImage(data: profileData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                            } else if let user = users.first {
                                Text(String(user.name.prefix(1)).uppercased())
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.mangosteenViolet)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(.mangosteenViolet)
                            }
                            
                            // Camera overlay
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "camera.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                            }
                            .frame(width: 96, height: 96)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 20)

                    
                    // User Name
                    if let user = users.first {
                        Text(user.name)
                            .font(.title)
                            .fontWeight(.regular)
                            .foregroundColor(.ambrosiaIvory)
                        
                        // Join Date
                        Text("Joined in \(user.userCreated.formatted(.dateTime.month(.wide).year()))")
                            .font(.caption)
                            .foregroundColor(.wildMaple)
                    } else {
                        Text("Welcome!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.ambrosiaIvory)
                    }
                    

                }
                
                // Header
                HStack {
                    Text("Overview")
                        .font(.title3)
                        .foregroundColor(.ambrosiaIvory)
                        .padding(.top, 26)
                        .padding(.bottom, 16)
                    Spacer()
                }
                
                // Stats Section
                if let user = users.first {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            StatItem(title: "Day Streak", value: "\(user.currentStreak)")
                            StatItem(title: "Total XP", value: "\(user.currentXp)")
                        }
                        
                        HStack(spacing: 10) {
                            StatItem(title: "Level", value: "\(user.currentXp / 100 + 1)")
                            StatItem(title: "Earned Badges", value: "\(user.badges.count)")
                        }
                    }
                }
                
                HStack {
                    Text("Mood History")
                        .font(.title3)
                        .foregroundColor(.ambrosiaIvory)
                        .padding(.bottom, 16)
                        .padding(.top, 26)
                    Spacer()
                }
                
                // Mood History Section
                VStack(spacing: 16) {
                    if moodEntries.isEmpty {
                        Text("No mood entries yet. Start tracking your mood!")
                            .font(.body)
                            .foregroundColor(.wildMaple)
                            .padding(.vertical, 20)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(moodEntries) { entry in
                                    MoodHistoryRow(entry: entry)
                                }
                            }
                        }
                        .frame(maxHeight: 208)
                    }
                    HStack {
                        Text("\(moodEntries.count) entries")
                            .font(.caption)
                            .foregroundColor(.wildMaple)
                        
                        if !moodEntries.isEmpty {
                                                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.wildMaple)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }

                }
                .padding()
                .background(Color.backgroundSecondary.opacity(1))
                .cornerRadius(20)
                Spacer()
                }
                .padding(20)
                .background(RadialGradient(
                    colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                    center: .bottom,
                    startRadius: 100,
                    endRadius: 900
                ))
                
                // Settings Button - Top Left
                VStack {
                    HStack {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .foregroundColor(.ambrosiaIvory)
                                .frame(width: 46, height: 46)
                                .background(Color.backgroundSecondary.opacity(0.8))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.mangosteenViolet, lineWidth: 2)
                                )
                        }
                        .padding(.top, 20)
                        .padding(.leading, 20)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
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
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView()
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newValue in
            if let newValue = newValue {
                loadPhoto(from: newValue)
            }
        }
    }
    
    private func loadPhoto(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let user = users.first {
                    DispatchQueue.main.async {
                        user.profilePictureData = data
                        do {
                            try modelContext.save()
                        } catch {
                            // Handle save errors silently
                        }
                    }
                }
            case .failure(_):
                // Handle loading errors silently
                break
            }
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
                .foregroundColor(.ambrosiaIvory)
            Text(title)
                .font(.caption)
                .foregroundColor(Color.gray2)
                .italic()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(Color.backgroundSecondary)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.mangosteenViolet, lineWidth: 2
                )
        )
    }
}

struct MoodHistoryRow: View {
    let entry: MoodEntry
    
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
            // Mood Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.mood)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.ambrosiaIvory)
                    .padding(10)
                    .background(moodColor.opacity(0.4))
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // Time ago
            Text(timeAgoString(from: entry.date))
                .font(.caption)
                .foregroundColor(.wildMaple)
        }
        .padding(4)
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
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
} 
