//
//  ProfileView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData
import PhotosUI
import Charts

struct ChartMoodEntry: Identifiable {
    let id = UUID()
    let date: Date
    let moodValue: Int
}

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var moodEntries: [MoodEntry]
    @Query private var users: [User]
    @State private var showingSettings = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingPhotoPicker = false
    @State private var showingBadgeGallery = false
    @State private var showingMoodHistory = false
    
    var body: some View {
        NavigationView {
            ZStack {
                mainContentView
                settingsButtonOverlay
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingBadgeGallery) {
            BadgeGalleryView()
        }
        .sheet(isPresented: $showingMoodHistory) {
            MoodHistoryView()
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newValue in
            if let newValue = newValue {
                loadPhoto(from: newValue)
            }
        }
    }
    
    // MARK: - View Components
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            avatarSection
            overviewHeader
            statsSection
            moodHistorySection
            Spacer()
        }
        .padding(20)
        .background(RadialGradient(
            colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
            center: .bottom,
            startRadius: 100,
            endRadius: 900
        ))
    }
    
    private var avatarSection: some View {
        VStack(spacing: 0) {
            avatarButton
            userNameSection
        }
    }
    
    private var avatarButton: some View {
        Button(action: { showingPhotoPicker = true }) {
            ZStack {
                Circle()
                    .fill(Color.ambrosiaIvory)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.purpleCarolite, lineWidth: 2)
                    )
                
                avatarContent
                cameraOverlay
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private var avatarContent: some View {
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
    }
    
    private var cameraOverlay: some View {
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
    
    @ViewBuilder
    private var userNameSection: some View {
        if let user = users.first {
            Text(user.name)
                .font(.title)
                .fontWeight(.regular)
                .foregroundColor(.ambrosiaIvory)
            
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
    
    private var overviewHeader: some View {
        HStack {
            Text("Overview")
                .font(.title3)
                .foregroundColor(.ambrosiaIvory)
                .padding(.top, 26)
                .padding(.bottom, 16)
            Spacer()
        }
    }
    
    @ViewBuilder
    private var statsSection: some View {
        if let user = users.first {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    StatItem(title: "Day Streak", value: "\(user.currentStreak)")
                    StatItem(title: "Total XP", value: "\(user.currentXp)")
                }
                
                HStack(spacing: 10) {
                    StatItem(title: "Level", value: "\(user.currentXp / 100 + 1)")
                    TappableStatItem(title: "Earned Badges", value: "\(user.badges.filter { $0.isEarned }.count)") {
                        showingBadgeGallery = true
                    }
                }
            }
        }
    }
    
    private var moodHistorySection: some View {
        VStack(spacing: 0) {
            moodHistoryHeader
            moodChartView
        }
    }
    
    private var moodHistoryHeader: some View {
        HStack {
            Text("Mood History")
                .font(.title3)
                .foregroundColor(.ambrosiaIvory)
                .padding(.bottom, 16)
                .padding(.top, 26)
            Spacer()
        }
    }
    
    private var moodChartView: some View {
        Button(action: {
            showingMoodHistory = true
        }) {
            VStack(spacing: 16) {
                moodChartContent
                
                HStack {
                    Text("\(moodEntries.count) entries")
                        .font(.caption)
                        .foregroundColor(.wildMaple)
                    
                    Spacer()
                    
                    if !moodEntries.isEmpty {
                        Text("Tap to view all")
                            .font(.caption)
                            .foregroundColor(.wildMaple)
                            .italic()
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .frame(maxHeight: 208)
        .background(Color.backgroundSecondary.opacity(1))
        .cornerRadius(20)
    }
    
    @ViewBuilder
    private var moodChartContent: some View {
        if moodEntries.isEmpty {
            Text("No mood entries yet. Start tracking your mood!")
                .font(.body)
                .foregroundColor(.wildMaple)
                .padding(.vertical, 20)
        } else {
            Chart(weeklyMoodData) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Mood", entry.moodValue)
                )
                .foregroundStyle(Color.afterBurn)
                .lineStyle(StrokeStyle(lineWidth: 1))
            }
            .chartYScale(domain: 1...5)
            .chartYAxis(.hidden)
            .chartXScale(domain: last7Days.first!...Calendar.current.date(byAdding: .hour, value: 12, to: last7Days.last!)!)
            .chartXAxis {
                AxisMarks(values: last7Days) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        .font(.caption2)
                        .foregroundStyle(Color.gray2)
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical, 8)
        }
    }
    
    private var settingsButtonOverlay: some View {
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
    
    // Computed property for weekly mood data
    private var weeklyMoodData: [ChartMoodEntry] {
        let calendar = Calendar.current
        
        // Filter mood entries to only include those from the last 7 days
        return moodEntries
            .filter { entry in
                last7Days.contains { day in
                    calendar.isDate(entry.date, inSameDayAs: day)
                }
            }
            .compactMap { entry in
                // Find the corresponding day from last7Days and use that normalized date
                if let normalizedDay = last7Days.first(where: { day in
                    calendar.isDate(entry.date, inSameDayAs: day)
                }) {
                    // Normalize to noon (12:00) instead of midnight
                    let startOfDay = calendar.startOfDay(for: normalizedDay)
                    let noonDate = calendar.date(byAdding: .hour, value: 6, to: startOfDay) ?? normalizedDay
                    return ChartMoodEntry(date: noonDate, moodValue: moodValue(for: entry.mood))
                }
                return nil
            }
            .sorted { $0.date < $1.date }
    }
    
    // Create the last 7 days for X-axis display (normalized to start of day)
    private var last7Days: [Date] {
        let calendar = Calendar.current
        return (0...6).compactMap { dayOffset in
            let targetDate = calendar.date(byAdding: .day, value: -6 + dayOffset, to: Date()) ?? Date()
            return calendar.startOfDay(for: targetDate)
        }
    }
    
    private func moodValue(for mood: String) -> Int {
        switch mood {
        case "Stressed": return 1
        case "Sad": return 2
        case "Neutral": return 3
        case "Happy": return 4
        case "Very Happy": return 5
        default: return 3
        }
    }
    
    private func moodLabel(for value: Int) -> String {
        switch value {
        case 1: return "Stressed"
        case 2: return "Sad"
        case 3: return "Neutral"
        case 4: return "Happy"
        case 5: return "Very Happy"
        default: return "Neutral"
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

struct TappableStatItem: View {
    let title: String
    let value: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
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
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
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
                HStack {
                    Text(entry.mood)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.ambrosiaIvory)
                        .padding(10)
                        .background(moodColor.opacity(0.4))
                        .cornerRadius(8)
                    
                    // Note indicator
                    if entry.note != nil && !entry.note!.isEmpty {
                        Image(systemName: "note.text")
                            .font(.caption)
                            .foregroundColor(.wildMaple)
                    }
                }
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


@MainActor
private func createSampleContainer() -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, MoodEntry.self, Badge.self, configurations: config)
    
    // Add sample user
    let sampleUser = User(name: "John Doe", currentStreak: 7, currentXp: 150)
    container.mainContext.insert(sampleUser)
    
    // Add sample mood entries for the past week (with some missing days to show line breaks)
    let calendar = Calendar.current
    let sampleData: [(dayOffset: Int, mood: String)] = [
        (-6, "Very Happy"),  // 6 days ago
        (-5, "Happy"),       // 5 days ago
        // -4 missing (day 4 ago) - will create line break
        (-3, "Neutral"),     // 3 days ago
        (-2, "Happy"),       // 2 days ago
        // -1 missing (yesterday) - will create line break
        (0, "Very Happy")    // today
    ]
    
    for (dayOffset, mood) in sampleData {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
        let entry = MoodEntry(date: date, mood: mood, note: "Sample note")
        container.mainContext.insert(entry)
    }
    
    try! container.mainContext.save()
    return container
}

#Preview {
    ProfileView()
        .modelContainer(createSampleContainer())
} 
