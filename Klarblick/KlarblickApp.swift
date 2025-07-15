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
        let context = modelContainer.mainContext
        
        let descriptor = FetchDescriptor<User>()
        if let user = try? context.fetch(descriptor).first {
            guard let lastExerciseDate = user.lastExerciseDate else { return }
            
            let today = Calendar.current.startOfDay(for: Date())
            let lastExerciseDay = Calendar.current.startOfDay(for: lastExerciseDate)
            
            // Calculate days difference
            let daysDifference = Calendar.current.dateComponents([.day], from: lastExerciseDay, to: today).day ?? 0
            
            // If last exercise was day before yesterday or earlier, reset streak
            if daysDifference >= 2 {
                user.currentStreak = 0
                try? context.save()
            }
        }
    }
    
    private func requestNotificationPermissionIfNeeded() {
        // Only request permission if user has completed onboarding
        // This prevents the request from showing during onboarding flow
        guard appStateManager.currentState == .main else { return }
        
        Task {
            let granted = await NotificationManager.shared.requestAuthorizationIfNeeded()
            if granted {
                // If permission was just granted and we have a stored reminder time, schedule notifications
                let reminderTime = NotificationManager.shared.getReminderTime()
                await NotificationManager.shared.scheduleDailyReminders(at: reminderTime)
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
                        .cornerRadius(12)

                    
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
