import Foundation
import UserNotifications
import SwiftData

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            // Mark that we've requested authorization
            UserDefaults.standard.set(true, forKey: "notification_permission_requested")
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    func requestAuthorizationIfNeeded() async -> (isEnabled: Bool, wasJustGranted: Bool) {
        // Check if we've already requested authorization
        let hasRequestedBefore = UserDefaults.standard.bool(forKey: "notification_permission_requested")
        
        if hasRequestedBefore {
            // Already requested, just return current status (no new grant)
            let isEnabled = await areNotificationsEnabled()
            return (isEnabled: isEnabled, wasJustGranted: false)
        }
        
        // Check current authorization status
        let currentStatus = await getNotificationStatus()
        
        // If not determined, request authorization
        if currentStatus == .notDetermined {
            let granted = await requestAuthorization()
            return (isEnabled: granted, wasJustGranted: granted)
        } else {
            // Already determined (granted or denied), mark as requested
            UserDefaults.standard.set(true, forKey: "notification_permission_requested")
            let isEnabled = currentStatus == .authorized
            return (isEnabled: isEnabled, wasJustGranted: false)
        }
    }
    
    // MARK: - Scheduling Daily Reminders
    
    func scheduleDailyReminders(at time: Date) async {
        // Cancel existing notifications first
        await cancelAllDailyReminders()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        guard let hour = components.hour, let minute = components.minute else {
            print("Failed to extract time components")
            return
        }
        
        // Schedule mindfulness reminder
        await scheduleMindfulnessReminder(hour: hour, minute: minute)
        
        // Schedule mood check-in reminder (15 minutes after mindfulness)
        let moodHour = (hour + (minute + 15) / 60) % 24
        let moodMinute = (minute + 15) % 60
        await scheduleMoodCheckInReminder(hour: moodHour, minute: moodMinute)
        
        // Note: Streak warning is scheduled separately after exercise completion
        
        print("Daily reminders scheduled for \(hour):\(String(format: "%02d", minute))")
    }
    
    private func scheduleMindfulnessReminder(hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Time for mindfulness")
        content.body = String(localized: "Take a moment to practice mindfulness and continue your wellness journey")
        content.sound = .default
        content.categoryIdentifier = "MINDFULNESS_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_mindfulness_reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Mindfulness reminder scheduled for \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("Failed to schedule mindfulness reminder: \(error)")
        }
    }
    
    private func scheduleMoodCheckInReminder(hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "How are you feeling?")
        content.body = String(localized: "Track your mood and reflect on your day")
        content.sound = .default
        content.categoryIdentifier = "MOOD_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_mood_reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Mood check-in reminder scheduled for \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("Failed to schedule mood reminder: \(error)")
        }
    }
    
    private func scheduleStreakWarningReminder(hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Your streak is about to be broken!")
        content.body = String(localized: "Complete at least one exercise to continue your wellness streak")
        content.sound = .default
        content.categoryIdentifier = "STREAK_WARNING"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_streak_warning",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Streak warning reminder scheduled for \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("Failed to schedule streak warning reminder: \(error)")
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelAllDailyReminders() async {
        center.removePendingNotificationRequests(withIdentifiers: [
            "daily_mindfulness_reminder",
            "daily_mood_reminder"
        ])
        print("All daily reminders cancelled (streak warning managed separately)")
    }
    
    func cancelTodaysMindfulnessReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_mindfulness_reminder"])
        print("Today's mindfulness reminder cancelled")
    }
    
    func cancelTodaysMoodReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_mood_reminder"])
        print("Today's mood reminder cancelled")
    }
    
    func cancelTodaysStreakWarning() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_streak_warning"])
        print("Today's streak warning cancelled")
    }
    
    func scheduleNextDayStreakWarning() async {
        // Cancel any existing streak warning first
        cancelTodaysStreakWarning()
        
        // Schedule for next day at 10 PM
        await scheduleStreakWarningReminder(hour: 22, minute: 0)
        print("Next day streak warning scheduled for 22:00")
    }
    
    // MARK: - Check if tasks completed today
    
    func checkAndCancelTodaysNotifications(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        // Check for completed exercises today
        let exerciseRequest = FetchDescriptor<ExerciseCompletion>(
            predicate: #Predicate<ExerciseCompletion> { completion in
                completion.date >= today && completion.date < tomorrow
            }
        )
        
        // Check for mood entries today
        let moodRequest = FetchDescriptor<MoodEntry>(
            predicate: #Predicate<MoodEntry> { entry in
                entry.date >= today && entry.date < tomorrow
            }
        )
        
        do {
            let exerciseCompletions = try context.fetch(exerciseRequest)
            let moodEntries = try context.fetch(moodRequest)
            
            if !exerciseCompletions.isEmpty {
                cancelTodaysMindfulnessReminder()
                cancelTodaysStreakWarning() // Cancel streak warning when exercise is completed
            }
            
            if !moodEntries.isEmpty {
                cancelTodaysMoodReminder()
            }
            
        } catch {
            print("Failed to check today's completions: \(error)")
        }
    }
    
    // MARK: - Settings Management
    
    func getReminderTime() -> Date {
        let hour = UserDefaults.standard.object(forKey: "reminder_hour") as? Int ?? 19
        let minute = UserDefaults.standard.object(forKey: "reminder_minute") as? Int ?? 0
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        return calendar.date(from: components) ?? Date()
    }
    
    func saveReminderTime(_ time: Date) async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        UserDefaults.standard.set(components.hour, forKey: "reminder_hour")
        UserDefaults.standard.set(components.minute, forKey: "reminder_minute")
        
        // Reschedule notifications with new time
        await scheduleDailyReminders(at: time)
    }
    
    // MARK: - Notification Status
    
    func getNotificationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    func areNotificationsEnabled() async -> Bool {
        let status = await getNotificationStatus()
        return status == .authorized
    }
} 