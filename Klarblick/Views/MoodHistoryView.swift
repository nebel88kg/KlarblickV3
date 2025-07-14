import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var moodEntries: [MoodEntry]
    @State private var sortOption: SortOption = .dateDescending
    @State private var showingDeleteConfirmation = false
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Latest First"
        case dateAscending = "Oldest First"
        case moodHappyToStressed = "Happy to Stressed"
        case moodStressedToHappy = "Stressed to Happy"
        
        var systemImage: String {
            switch self {
            case .dateDescending: return "calendar.badge.minus"
            case .dateAscending: return "calendar.badge.plus"
            case .moodHappyToStressed: return "face.smiling"
            case .moodStressedToHappy: return "face.dashed"
            }
        }
    }
    
    private var sortedEntries: [MoodEntry] {
        switch sortOption {
        case .dateDescending:
            return moodEntries.sorted { $0.date > $1.date }
        case .dateAscending:
            return moodEntries.sorted { $0.date < $1.date }
        case .moodHappyToStressed:
            return moodEntries.sorted { moodSeverity($0.mood) < moodSeverity($1.mood) }
        case .moodStressedToHappy:
            return moodEntries.sorted { moodSeverity($0.mood) > moodSeverity($1.mood) }
        }
    }
    
    private func moodSeverity(_ mood: String) -> Int {
        switch mood {
        case "Very Happy": return 0
        case "Happy": return 1
        case "Neutral": return 2
        case "Sad": return 3
        case "Stressed": return 4
        default: return 2 // Default to neutral
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                RadialGradient(
                    colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                    center: .bottom,
                    startRadius: 100,
                    endRadius: 900
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with sort options
                    HStack {
                        Text("Mood History")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.ambrosiaIvory)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    sortOption = option
                                }) {
                                    HStack {
                                        Text(option.rawValue)
                                        Image(systemName: option.systemImage)
                                        if sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.caption)
                                Text("Sort")
                                    .font(.caption)
                            }
                            .foregroundColor(.ambrosiaIvory)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.backgroundSecondary.opacity(0.8))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Entry count and delete button
                    HStack {
                        Text("\(moodEntries.count) entries")
                            .font(.caption)
                            .foregroundColor(.wildMaple)
                        
                        Spacer()
                        
                        if !moodEntries.isEmpty {
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete All")
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Mood entries list
                    if sortedEntries.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 48))
                                .foregroundColor(.wildMaple)
                            
                            Text("No mood entries yet")
                                .font(.title3)
                                .foregroundColor(.ambrosiaIvory)
                            
                            Text("Start tracking your mood to see your history here!")
                                .font(.body)
                                .foregroundColor(.wildMaple)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(sortedEntries) { entry in
                                    MoodHistoryDetailRow(entry: entry)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationTitle("Mood History")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.ambrosiaIvory)
            }
        }
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
        for entry in moodEntries {
            modelContext.delete(entry)
        }
        
        do {
            try modelContext.save()
        } catch {
            // Handle save errors silently
        }
    }
}

struct MoodHistoryDetailRow: View {
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
    
    private var moodText: String {
        switch entry.mood {
        case "Very Happy": return String(localized: "Very Happy")
        case "Happy": return String(localized: "Happy")
        case "Neutral": return String(localized: "Neutral")
        case "Sad": return String(localized: "Sad")
        case "Stressed": return String(localized: "Stressed")
        default: return ""
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with mood and date
            HStack {
                Text(moodText)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.ambrosiaIvory)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(moodColor.opacity(0.4))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(entry.date.formatted(.dateTime.month().day().year()))
                    .font(.caption)
                    .foregroundColor(.wildMaple)
                
            }
            
            // Note section
            if let note = entry.note, !note.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note)
                        .font(.body)
                        .foregroundColor(.ambrosiaIvory)
                        .padding(.top, 2)
                }
            } else {
                HStack {
                    Text("No note added")
                        .font(.caption)
                        .foregroundColor(.wildMaple.opacity(0.5))
                        .italic()
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.backgroundSecondary.opacity(0.8))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.mangosteenViolet.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    MoodHistoryView()
        .modelContainer(for: [MoodEntry.self])
} 
