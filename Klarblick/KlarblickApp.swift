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
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var appStateManager = AppStateManager()
    
    init() {
        do {
            modelContainer = try ModelContainer(for: User.self, MoodEntry.self, Badge.self, ExerciseCompletion.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appStateManager.currentState {
                case .loading:
                    LoadingView()
                        .onAppear {
                            appStateManager.handleAppLaunch()
                            // Show loading screen for 2.0 seconds like the original splash, then start checks
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                startInitialChecks()
                            }
                        }
                        .transition(.opacity)
                        
                case .onboarding:
                    OnboardingView(isOnboardingComplete: $appStateManager.isOnboardingComplete)
                        .transition(.opacity)
                        
                case .main:
                    MainView()
                        .environmentObject(subscriptionManager)
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                            print("🚀 App entered foreground, running checks...")
                            checkAndResetStreakIfNeeded()
                            refreshSubscriptionStatus()
                            requestNotificationPermissionIfNeeded()
                        }
                        .transition(.opacity)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AccountDeleted"))) { _ in
                // Reset app state and trigger onboarding
                withAnimation(.easeInOut(duration: 0.5)) {
                    appStateManager.resetForAccountDeletion()
                }
            }
        }
        .modelContainer(modelContainer)
        .onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
            if isSubscribed {
                withAnimation(.easeInOut(duration: 0.5)) {
                    appStateManager.handleSubscriptionPurchased()
                }
            }
        }
        .onChange(of: appStateManager.isOnboardingComplete) { _, isComplete in
            if isComplete {
                appStateManager.handleOnboardingComplete()
                // Start subscription check after onboarding
                checkSubscriptionStatus()
                // Request notification permission if not already done during onboarding
                requestNotificationPermissionIfNeeded()
            }
        }
    }
    
    // MARK: - Initial Checks
    private func startInitialChecks() {
        // Check for existing user first
        checkForExistingUser()
        
        // For existing users, also check subscription status
        // For new users, subscription check happens after onboarding
    }
    
    private func checkForExistingUser() {
        let context = modelContainer.mainContext
        
        let descriptor = FetchDescriptor<User>()
        do {
            let users = try context.fetch(descriptor)
            let hasUser = !users.isEmpty
            
            // Initialize badges for existing users
            if hasUser, let user = users.first {
                BadgeManager.shared.initializeBadgesForUser(user, context: context)
            }
            
            // Update app state based on user existence
            appStateManager.handleUserCheckComplete(hasUser: hasUser)
            
            // If user exists, continue with subscription check
            if hasUser {
                print("👤 Existing user found during startup, checking streak...")
                checkAndResetStreakIfNeeded()
                checkSubscriptionStatus()
            }
            
        } catch {
            // Handle error - assume no user exists
            print("Error checking for existing user: \(error)")
            appStateManager.handleUserCheckComplete(hasUser: false)
        }
    }
    
    private func checkSubscriptionStatus() {
        Task {
            // Wait for subscription manager to be initialized
            while !subscriptionManager.isInitialized {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            
            await subscriptionManager.updateSubscriptionStatus()
            
            await MainActor.run {
                appStateManager.handleSubscriptionCheckComplete(isSubscribed: subscriptionManager.isSubscribed)
            }
        }
    }
    
    // MARK: - Refresh Methods
    private func refreshSubscriptionStatus() {
        // Only refresh if we're in main state
        guard appStateManager.currentState == .main else { return }
        
        Task {
            await subscriptionManager.updateSubscriptionStatus()
            // MainView will handle showing the paywall sheet when subscription is lost
        }
    }
    
    private func checkAndResetStreakIfNeeded() {
        print("🔄 checkAndResetStreakIfNeeded called")
        let context = modelContainer.mainContext
        
        let descriptor = FetchDescriptor<User>()
        guard let user = try? context.fetch(descriptor).first else { 
            print("❌ No user found for streak check")
            return 
        }
        
        print("👤 Current user streak: \(user.currentStreak)")
        
        // Debug: Show ALL exercise completions in the database
        let allCompletionsDescriptor = FetchDescriptor<ExerciseCompletion>()
        do {
            let allCompletions = try context.fetch(allCompletionsDescriptor)
            print("🗄️ Total ExerciseCompletion records in database: \(allCompletions.count)")
            for completion in allCompletions {
                print("   - Category: \(completion.category), Date: \(completion.date), Source: \(completion.source)")
            }
            
            // Check if this might be the user's first exercise ever
            if allCompletions.isEmpty {
                print("🎯 No exercise completions found - this might be before the first exercise")
                return // Don't reset streak if no exercises have been completed yet
            }
            
        } catch {
            print("❌ Failed to fetch all completions: \(error)")
        }
        
        // Calculate yesterday's date range
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        
        print("📆 Date ranges:")
        print("   Today: \(today)")
        print("   Yesterday: \(yesterday)")
        print("   Start of yesterday: \(startOfYesterday)")
        
        // Check if any exercises were completed yesterday
        let exerciseDescriptor = FetchDescriptor<ExerciseCompletion>(
            predicate: #Predicate<ExerciseCompletion> { completion in
                completion.date >= startOfYesterday && completion.date < today
            }
        )
        
        do {
            let yesterdayCompletions = try context.fetch(exerciseDescriptor)
            print("📝 Found \(yesterdayCompletions.count) exercise completions for yesterday")
            
            for completion in yesterdayCompletions {
                print("   - Category: \(completion.category), Date: \(completion.date), Source: \(completion.source)")
            }
            
            // Check if any exercises were completed today
            let todayDescriptor = FetchDescriptor<ExerciseCompletion>(
                predicate: #Predicate<ExerciseCompletion> { completion in
                    completion.date >= today
                }
            )
            let todayCompletions = try context.fetch(todayDescriptor)
            print("📝 Found \(todayCompletions.count) exercise completions for today")
            
            // If no exercises completed yesterday, check if this is a valid scenario to keep the streak
            if yesterdayCompletions.isEmpty {
                // Case 1: First exercise ever (streak = 1, exercises today, none yesterday)
                if todayCompletions.count > 0 && user.currentStreak == 1 {
                    print("🎯 First exercise scenario detected - user has 1 streak, exercises today, none yesterday")
                    print("✅ Keeping streak intact for first exercise")
                    return // Don't reset the streak for the first exercise
                }
                
                // Case 2: Streak restart scenario (streak = 0, exercises today, none yesterday)
                if todayCompletions.count > 0 && user.currentStreak == 0 {
                    print("🔄 Streak restart scenario detected - user has 0 streak, exercises today, none yesterday")
                    print("✅ User is starting fresh, no need to reset streak (already 0)")
                    return // Don't reset the streak when it's already 0 and user is starting fresh
                }
                
                // Case 3: Actual streak break (streak > 1, no exercises yesterday)
                print("⚠️ No exercises completed yesterday, resetting streak from \(user.currentStreak) to 0")
                user.currentStreak = 0
                try context.save()
                print("💾 Streak reset saved to context")
            } else {
                print("✅ Exercises were completed yesterday, keeping streak at \(user.currentStreak)")
            }
        } catch {
            // If we can't check exercise completions, don't reset the streak
            print("❌ Failed to check exercise completions: \(error)")
        }
    }
    
    private func requestNotificationPermissionIfNeeded() {
        // Only request permission if user has completed onboarding
        // This prevents the request from showing during onboarding flow
        guard appStateManager.currentState == .main else { return }
        
        Task {
            let result = await NotificationManager.shared.requestAuthorizationIfNeeded()
            if result.wasJustGranted {
                // Only reschedule if permission was just granted (not on every app foreground)
                print("🔔 Notification permission was just granted, scheduling daily reminders")
                let reminderTime = NotificationManager.shared.getReminderTime()
                await NotificationManager.shared.scheduleDailyReminders(at: reminderTime)
            } else if result.isEnabled {
                print("🔔 Notifications already enabled, no need to reschedule")
            }
        }
    }
}

// MARK: - Loading View (styled like the original splash screen)
struct LoadingView: View {
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Background gradient (same as original splash)
            Color.backgroundSecondary
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack{
                    // App icon or logo placeholder (same as original splash)
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .cornerRadius(10)

                    
                    // App name (same as original splash)
                    Text("Klarblick")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.wildMaple)
                }
                
                // Tagline (same as original splash)
                Text("Clarity in Mind")
                    .font(.headline)
                    .foregroundColor(.purpleCarolite)
            }
        }
    }
}
