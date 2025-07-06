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
            modelContainer = try ModelContainer(for: User.self, MoodEntry.self, Badge.self)
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
                        
                case .paywall:
                    PaywallView()
                        .environmentObject(subscriptionManager)
                        .transition(.opacity)
                        
                case .main:
                    MainView()
                        .environmentObject(subscriptionManager)
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                            checkAndResetStreakIfNeeded()
                            refreshSubscriptionStatus()
                        }
                        .transition(.opacity)
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
            
            await MainActor.run {
                // If subscription is lost, show paywall
                if !subscriptionManager.isSubscribed {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appStateManager.transitionTo(.paywall)
                    }
                }
            }
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
}

// MARK: - Loading View (styled like the original splash screen)
struct LoadingView: View {
    @State private var isLoading = true
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient (same as original splash)
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App icon or logo placeholder (same as original splash)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.primary)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 1.0), value: scale)
                    .animation(.easeInOut(duration: 1.0), value: opacity)
                
                // App name (same as original splash)
                Text("Klarblick")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 1.0).delay(0.2), value: opacity)
                
                // Tagline (same as original splash)
                Text("Clarity in Mind")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 1.0).delay(0.4), value: opacity)
                
                // Loading indicator (same animated dots as original splash)
                if isLoading {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .scaleEffect(scale)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: scale
                                )
                        }
                    }
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 1.0).delay(0.6), value: opacity)
                }
            }
        }
        .onAppear {
            withAnimation {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
