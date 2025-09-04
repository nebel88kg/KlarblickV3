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
        print("🔔 === SCHEDULING DAILY REMINDERS ===")
        print("🔔 Requested time: \(time)")
        
        // Cancel existing notifications first
        await cancelAllDailyReminders()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        guard let hour = components.hour, let minute = components.minute else {
            print("🔔 ❌ Failed to extract time components from \(time)")
            return
        }
        
        print("🔔 Extracted time components: \(hour):\(String(format: "%02d", minute))")
        
        // Schedule mindfulness reminder
        print("🔔 Scheduling mindfulness reminder...")
        await scheduleMindfulnessReminder(hour: hour, minute: minute)
        
        // Schedule mood check-in reminder (15 minutes after mindfulness)
        let moodHour = (hour + (minute + 15) / 60) % 24
        let moodMinute = (minute + 15) % 60
        print("🔔 Scheduling mood reminder...")
        await scheduleMoodCheckInReminder(hour: moodHour, minute: moodMinute)
        
        // Note: Streak warning is scheduled separately after exercise completion
        
        print("🔔 ✅ Daily reminders scheduled for \(hour):\(String(format: "%02d", minute))")
        await debugPrintAllPendingNotifications()
    }
    
    private func scheduleMindfulnessReminder(hour: Int, minute: Int) async {
        print("🧘 === SCHEDULING MINDFULNESS REMINDER ===")
        print("🧘 Target time: \(hour):\(String(format: "%02d", minute))")
        
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
            print("🧘 ✅ Mindfulness reminder scheduled for \(hour):\(String(format: "%02d", minute)) (repeats daily)")
        } catch {
            print("🧘 ❌ Failed to schedule mindfulness reminder: \(error)")
        }
    }
    
    private func scheduleMoodCheckInReminder(hour: Int, minute: Int) async {
        print("😊 === SCHEDULING MOOD REMINDER ===")
        print("😊 Target time: \(hour):\(String(format: "%02d", minute))")
        
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
            print("😊 ✅ Mood check-in reminder scheduled for \(hour):\(String(format: "%02d", minute)) (repeats daily)")
        } catch {
            print("😊 ❌ Failed to schedule mood reminder: \(error)")
        }
    }
    
    private func scheduleStreakWarningReminder(hour: Int, minute: Int) async {
        print("🔥 === SCHEDULING STREAK WARNING ===")
        print("🔥 Target time: \(hour):\(String(format: "%02d", minute))")
        
        let content = UNMutableNotificationContent()
        content.title = String(localized: "🚨 Your streak is in danger!")
        content.body = String(localized: "Complete at least one exercise to continue your wellness streak")
        content.sound = .default
        content.categoryIdentifier = "STREAK_WARNING"
        
        // Calculate tomorrow's date at the specified time
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: tomorrow)
        dateComponents.month = calendar.component(.month, from: tomorrow)
        dateComponents.day = calendar.component(.day, from: tomorrow)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "daily_streak_warning",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            let targetDate = calendar.date(from: dateComponents) ?? tomorrow
            print("🔥 ✅ Streak warning scheduled for tomorrow \(targetDate) (one-time only)")
        } catch {
            print("🔥 ❌ Failed to schedule streak warning reminder: \(error)")
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelAllDailyReminders() async {
        print("🚫 === CANCELLING ALL DAILY REMINDERS ===")
        await debugPrintAllPendingNotifications()
        
        center.removePendingNotificationRequests(withIdentifiers: [
            "daily_mindfulness_reminder",
            "daily_mood_reminder"
        ])
        print("🚫 ✅ All daily reminders cancelled (streak warning managed separately)")
        
        // Show what's left after cancellation
        await debugPrintAllPendingNotifications()
    }
    
    func cancelTodaysMindfulnessReminder() {
        print("🧘 🚫 === CANCELLING MINDFULNESS REMINDER ===")
        center.removePendingNotificationRequests(withIdentifiers: ["daily_mindfulness_reminder"])
        print("🧘 🚫 ✅ Mindfulness reminder cancelled")
    }
    
    func cancelTodaysMoodReminder() {
        print("😊 🚫 === CANCELLING MOOD REMINDER ===")
        center.removePendingNotificationRequests(withIdentifiers: ["daily_mood_reminder"])
        print("😊 🚫 ✅ Mood reminder cancelled")
    }
    
    func cancelTodaysStreakWarning() {
        print("🔥 🚫 === CANCELLING STREAK WARNING ===")
        center.removePendingNotificationRequests(withIdentifiers: ["daily_streak_warning"])
        print("🔥 🚫 ✅ Streak warning cancelled")
    }
    
    func scheduleNextDayStreakWarning() async {
        print("🔥 ⏭️ === SCHEDULING NEXT DAY STREAK WARNING ===")
        
        // Cancel any existing streak warning first
        cancelTodaysStreakWarning()
        
        // Schedule for next day at 10 PM
        await scheduleStreakWarningReminder(hour: 22, minute: 0)
        print("🔥 ⏭️ ✅ Next day streak warning scheduled for 22:00")
        await debugPrintAllPendingNotifications()
    }
    
    func rescheduleNextDayMindfulnessReminder() async {
        print("🧘 ♻️ === RESCHEDULING MINDFULNESS REMINDER ===")
        
        // Cancel existing mindfulness reminder
        cancelTodaysMindfulnessReminder()
        
        // Get current reminder time settings
        let reminderTime = getReminderTime()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        guard let hour = components.hour, let minute = components.minute else {
            print("🧘 ♻️ ❌ Failed to extract time components for mindfulness reminder")
            return
        }
        
        print("🧘 ♻️ Rescheduling mindfulness reminder for \(hour):\(String(format: "%02d", minute))")
        
        // Reschedule mindfulness reminder
        await scheduleMindfulnessReminder(hour: hour, minute: minute)
        print("🧘 ♻️ ✅ Mindfulness reminder rescheduled for next day at \(hour):\(String(format: "%02d", minute))")
        await debugPrintAllPendingNotifications()
    }
    
    func rescheduleNextDayMoodReminder() async {
        print("😊 ♻️ === RESCHEDULING MOOD REMINDER ===")
        
        // Cancel existing mood reminder
        cancelTodaysMoodReminder()
        
        // Get current reminder time settings (mood is 15 minutes after mindfulness)
        let reminderTime = getReminderTime()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        guard let hour = components.hour, let minute = components.minute else {
            print("😊 ♻️ ❌ Failed to extract time components for mood reminder")
            return
        }
        
        // Calculate mood reminder time (15 minutes after mindfulness)
        let moodHour = (hour + (minute + 15) / 60) % 24
        let moodMinute = (minute + 15) % 60
        
        print("😊 ♻️ Rescheduling mood reminder for \(moodHour):\(String(format: "%02d", moodMinute))")
        
        // Reschedule mood reminder
        await scheduleMoodCheckInReminder(hour: moodHour, minute: moodMinute)
        print("😊 ♻️ ✅ Mood reminder rescheduled for next day at \(moodHour):\(String(format: "%02d", moodMinute))")
        await debugPrintAllPendingNotifications()
    }
    
    // MARK: - Check if tasks completed today
    
    func checkAndCancelTodaysNotifications(context: ModelContext) {
        print("🔍 === CHECKING TODAY'S COMPLETIONS FOR NOTIFICATION CANCELLATION ===")
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        print("🔍 Today's date range: \(today) to \(tomorrow)")
        
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
            
            print("🔍 Found \(exerciseCompletions.count) exercise completions today")
            print("🔍 Found \(moodEntries.count) mood entries today")
            
            if !exerciseCompletions.isEmpty {
                print("🔍 ✅ Exercise completed today - processing notification changes...")
                // Cancel today's notifications but reschedule for tomorrow
                Task {
                    await rescheduleNextDayMindfulnessReminder()
                }
                cancelTodaysStreakWarning() // This is handled separately
                print("🔍 ✅ Exercise completed today - cancelled today's mindfulness reminder and rescheduled for tomorrow")
            } else {
                print("🔍 ⏸️ No exercises completed today - keeping mindfulness reminders active")
            }
            
            if !moodEntries.isEmpty {
                print("🔍 ✅ Mood logged today - processing notification changes...")
                // Cancel today's mood reminder but reschedule for tomorrow
                Task {
                    await rescheduleNextDayMoodReminder()
                }
                print("🔍 ✅ Mood logged today - cancelled today's mood reminder and rescheduled for tomorrow")
            } else {
                print("🔍 ⏸️ No mood entries today - keeping mood reminders active")
            }
            
        } catch {
            print("🔍 ❌ Failed to check today's completions: \(error)")
        }
        
        print("🔍 === END CHECKING TODAY'S COMPLETIONS ===")
    }
    
    // MARK: - Debug Functions
    
    func debugPrintAllPendingNotifications() async {
        let pendingRequests = await center.pendingNotificationRequests()
        print("📋 === PENDING NOTIFICATIONS DEBUG ===")
        print("📋 Total pending notifications: \(pendingRequests.count)")
        
        for request in pendingRequests {
            let trigger = request.trigger
            var triggerInfo = "Unknown trigger"
            
            if let calendarTrigger = trigger as? UNCalendarNotificationTrigger {
                let components = calendarTrigger.dateComponents
                let hour = components.hour ?? -1
                let minute = components.minute ?? -1
                let repeats = calendarTrigger.repeats
                
                // Build date string if available
                var dateString = ""
                if let year = components.year, let month = components.month, let day = components.day {
                    dateString = " on \(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
                } else if !repeats {
                    dateString = " (one-time, date calculated from components)"
                }
                
                triggerInfo = "Calendar: \(hour):\(String(format: "%02d", minute))\(dateString), repeats: \(repeats)"
            }
            
            print("📋   - ID: \(request.identifier)")
            print("📋     Title: \(request.content.title)")
            print("📋     Body: \(request.content.body)")
            print("📋     Trigger: \(triggerInfo)")
            print("📋     Category: \(request.content.categoryIdentifier)")
            print("📋   ---")
        }
        print("📋 === END PENDING NOTIFICATIONS ===")
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
