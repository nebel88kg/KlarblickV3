//
//  SettingsView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 04.07.25.
//

import SwiftUI
import SwiftData
import MessageUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var moodEntries: [MoodEntry]
    @Query private var exerciseCompletions: [ExerciseCompletion]
    @Query private var badges: [Badge]
    @State private var userName: String = ""
    @State private var showingNameEditor = false
    @State private var showingReminderTimeEditor = false
    @State private var showingAboutApp = false
    @State private var showingMailComposer = false
    @State private var showingDeleteConfirmation = false
    @State private var reminderTime = Date()
    @State private var notificationsEnabled = false
    @State private var isUpdatingReminder = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header - Fixed at top
                ZStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.ambrosiaIvory)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Scrollable Settings Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Profile Settings
                        VStack(spacing: 16) {
                            HStack {
                                Text("Profile")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.ambrosiaIvory)
                                Spacer()
                            }
                            
                            // Edit Name
                            Button(action: { showingNameEditor = true }) {
                                HStack {
                                    Image(systemName: "person.circle")
                                        .font(.title2)
                                        .foregroundColor(.wildMaple)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Edit Name")
                                            .font(.body)
                                            .foregroundColor(.ambrosiaIvory)
                                        
                                        Text(users.first?.name ?? "User")
                                            .font(.caption)
                                            .foregroundColor(.wildMaple)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.wildMaple)
                                }
                                .padding(16)
                                .background(Color.backgroundSecondary.opacity(0.3))
                                .cornerRadius(12)
                            }
                            
                            // Delete Account
                            Button(action: { showingDeleteConfirmation = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.body)
                                        .foregroundColor(.wildMaple)
                                        .padding(.horizontal, 6)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Delete Account")
                                            .font(.caption)
                                            .foregroundColor(.ambrosiaIvory)
                                        
                                        Text("Permanently remove all data.")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .padding(10)
                                .background(Color.backgroundSecondary.opacity(0.3))
                                .cornerRadius(12)
                            }
                        }
                        
                        // App Settings
                        VStack(spacing: 16) {
                            HStack {
                                Text("App")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.ambrosiaIvory)
                                Spacer()
                            }
                            
                            // Reminder Time
                            Button(action: { showingReminderTimeEditor = true }) {
                                HStack {
                                    Image(systemName: "bell")
                                        .font(.title2)
                                        .foregroundColor(.wildMaple)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Daily Reminders")
                                            .font(.body)
                                            .foregroundColor(.ambrosiaIvory)
                                        
                                        Text(formatTime(reminderTime))
                                            .font(.caption)
                                            .foregroundColor(.wildMaple)
                                    }
                                    
                                    Spacer()
                                    
                                    if isUpdatingReminder {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.wildMaple)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.wildMaple)
                                    }
                                }
                                .padding(16)
                                .background(Color.backgroundSecondary.opacity(0.3))
                                .cornerRadius(12)
                            }
                            .disabled(isUpdatingReminder)
                            
                            // Notifications Status
                            HStack {
                                Image(systemName: notificationsEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(notificationsEnabled ? .green : .red)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notification Status")
                                        .font(.body)
                                        .foregroundColor(.ambrosiaIvory)
                                    
                                    Text(notificationsEnabled ? "Enabled" : "Disabled in Settings")
                                        .font(.caption)
                                        .foregroundColor(.wildMaple)
                                }
                                
                                Spacer()
                                
                                if !notificationsEnabled {
                                    Button("Enable") {
                                        openAppSettings()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.afterBurn)
                                }
                            }
                            .padding(16)
                            .background(Color.backgroundSecondary.opacity(0.3))
                            .cornerRadius(12)
                        }
                        
                        // About Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("About")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.ambrosiaIvory)
                                Spacer()
                            }
                            
                            // About this app
                            Button(action: { showingAboutApp = true }) {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .font(.title2)
                                        .foregroundColor(.wildMaple)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("About this app")
                                            .font(.body)
                                            .foregroundColor(.ambrosiaIvory)
                                        
                                        Text("Learn more about Klarblick")
                                            .font(.caption)
                                            .foregroundColor(.wildMaple)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.wildMaple)
                                }
                                .padding(16)
                                .background(Color.backgroundSecondary.opacity(0.3))
                                .cornerRadius(12)
                            }
                            
                            // Contact & Feedback
                            Button(action: { showingMailComposer = true }) {
                                HStack {
                                    Image(systemName: "envelope")
                                        .font(.title2)
                                        .foregroundColor(.wildMaple)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Contact & Feedback")
                                            .font(.body)
                                            .foregroundColor(.ambrosiaIvory)
                                        
                                        Text("Get in touch or share feedback")
                                            .font(.caption)
                                            .foregroundColor(.wildMaple)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.wildMaple)
                                }
                                .padding(16)
                                .background(Color.backgroundSecondary.opacity(0.3))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40) // Extra bottom padding for comfortable scrolling
                }
            }
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingNameEditor) {
            NameEditorView(userName: $userName)
        }
        .sheet(isPresented: $showingReminderTimeEditor) {
            ReminderTimeEditorView(reminderTime: $reminderTime, isUpdating: $isUpdatingReminder)
        }
        .sheet(isPresented: $showingAboutApp) {
            AboutAppView()
        }
        .sheet(isPresented: $showingMailComposer) {
            if MFMailComposeViewController.canSendMail() {
                MailComposeView(
                    subject: "Klarblick - Contact & Feedback",
                    body: "Hello Klarblick Team,\n\nI'm reaching out to:\n\n□ Ask a question\n□ Share feedback\n□ Report an issue\n□ Other\n\nMessage:\n\n"
                )
            } else {
                MailNotAvailableView()
            }
        }
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data including mood entries, exercise progress, and personal information.")
        }
        .onAppear {
            userName = users.first?.name ?? ""
            loadNotificationSettings()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh notification status when app comes to foreground
            loadNotificationSettings()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func loadNotificationSettings() {
        Task {
            reminderTime = NotificationManager.shared.getReminderTime()
            notificationsEnabled = await NotificationManager.shared.areNotificationsEnabled()
        }
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func deleteAccount() {
        // Delete all user data
        for user in users {
            modelContext.delete(user)
        }
        
        for moodEntry in moodEntries {
            modelContext.delete(moodEntry)
        }
        
        for exerciseCompletion in exerciseCompletions {
            modelContext.delete(exerciseCompletion)
        }
        
        for badge in badges {
            modelContext.delete(badge)
        }
        
        do {
            try modelContext.save()
            
            // Dismiss settings and trigger onboarding
            dismiss()
            
            // Post notification to restart the app flow
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: NSNotification.Name("AccountDeleted"), object: nil)
            }
            
        } catch {
            print("Error deleting account: \(error)")
        }
    }
}

// MARK: - About App View
struct AboutAppView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Logo
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .padding(.top, 20)
                
                Text("Klarblick")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                
                Text("Your mindfulness companion")
                    .font(.headline)
                    .foregroundColor(.wildMaple)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20) {
                    Text("Klarblick helps you maintain mental clarity and emotional balance through guided mindfulness exercises, daily mood tracking, and personalized insights.")
                        .font(.body)
                        .foregroundColor(.ambrosiaIvory)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Build healthy habits, track your progress, and discover the power of mindful living with our comprehensive wellness platform.")
                        .font(.body)
                        .foregroundColor(.ambrosiaIvory)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Text("Version 1.0.5")
                    .font(.caption)
                    .foregroundColor(.wildMaple)
                    .padding(.bottom, 20)
            }
            .padding(20)
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.ambrosiaIvory)
                }
            }
        }
    }
}

// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    let subject: String
    let body: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        composer.setToRecipients(["klarblick.app@gmail.com"])
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

// MARK: - Mail Not Available View
struct MailNotAvailableView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.wildMaple)
                    .padding(.top, 40)
                
                Text("Mail Not Available")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                
                Text("Please set up Mail on your device or contact us directly at:")
                    .font(.body)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("klarblick.app@gmail.com")
                    .font(.headline)
                    .foregroundColor(.afterBurn)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(20)
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.ambrosiaIvory)
                }
            }
        }
    }
}

struct ReminderTimeEditorView: View {
    @Binding var reminderTime: Date
    @Binding var isUpdating: Bool
    @Environment(\.dismiss) private var dismiss
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Set Reminder Time")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .padding(.top, 20)
                
                VStack(spacing: 20) {
                    Text("When should we remind you to check in daily?")
                        .font(.headline)
                        .foregroundColor(.wildMaple)
                        .multilineTextAlignment(.center)
                    
                    DatePicker(
                        "Reminder Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .colorScheme(.dark)
                    .foregroundColor(.ambrosiaIvory)
                    
                    Text("We'll send you gentle reminders for mindfulness exercises and mood check-ins")
                        .font(.subheadline)
                        .foregroundColor(.ambrosiaIvory)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                Button(action: saveReminderTime) {
                    HStack {
                        if isUpdating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(isUpdating ? "Updating..." : "Save Time")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.afterBurn)
                    .cornerRadius(12)
                }
                .disabled(isUpdating)
                
                Spacer()
            }
            .padding(20)
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.ambrosiaIvory)
                }
            }
        }
    }
    
    private func saveReminderTime() {
        Task {
            isUpdating = true
            await NotificationManager.shared.saveReminderTime(reminderTime)
            isUpdating = false
            dismiss()
        }
    }
}

struct NameEditorView: View {
    @Binding var userName: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Edit Your Name")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .padding(.top, 20)
                
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(16)
                    .background(Color.backgroundSecondary.opacity(0.3))
                    .cornerRadius(12)
                    .foregroundColor(.ambrosiaIvory)
                
                Button(action: saveUserName) {
                    Text("Save")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.afterBurn)
                        .cornerRadius(12)
                }
                .disabled(userName.isEmpty)
                
                Spacer()
            }
            .padding(20)
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.ambrosiaIvory)
                }
            }
        }
    }
    
    private func saveUserName() {
        if let user = users.first {
            user.name = userName
        } else {
            let newUser = User(name: userName)
            modelContext.insert(newUser)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // Handle save errors
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
} 
