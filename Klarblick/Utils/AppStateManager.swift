import Foundation
import SwiftUI

// MARK: - App State Enum
enum AppState {
    case loading // Start directly with loading instead of splash
    case onboarding
    case paywall
    case main
}

// MARK: - App State Manager
@MainActor
class AppStateManager: ObservableObject {
    @Published var currentState: AppState = .loading // Start with loading instead of splash
    @Published var hasUser = false
    @Published var isOnboardingComplete = false
    @Published var isSubscribed = false
    @Published var isLoading = false
    
    // Track completion of async operations
    private var userCheckCompleted = false
    private var subscriptionCheckCompleted = false
    
    // MARK: - State Transitions
    func transitionTo(_ newState: AppState) {
        currentState = newState
    }
    
    // MARK: - Event Handlers
    func handleAppLaunch() {
        // Start loading immediately when app launches
        isLoading = true
        currentState = .loading
    }
    
    func handleUserCheckComplete(hasUser: Bool) {
        self.hasUser = hasUser
        userCheckCompleted = true
        
        // Only evaluate next state if both checks are complete
        evaluateNextState()
    }
    
    func handleSubscriptionCheckComplete(isSubscribed: Bool) {
        self.isSubscribed = isSubscribed
        subscriptionCheckCompleted = true
        
        // Only evaluate next state if both checks are complete
        evaluateNextState()
    }
    
    func handleOnboardingComplete() {
        hasUser = true
        isOnboardingComplete = true
        
        // Reset subscription check and start it again
        subscriptionCheckCompleted = false
        isLoading = true
        transitionTo(.loading)
    }
    
    func handleSubscriptionPurchased() {
        isSubscribed = true
        transitionTo(.main)
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func evaluateNextState() {
        // Only proceed if we're in loading state and both checks are complete
        guard currentState == .loading else { return }
        
        // For new users, we need user check but subscription check happens after onboarding
        if !hasUser && userCheckCompleted {
            isLoading = false
            transitionTo(.onboarding)
            return
        }
        
        // For existing users, we need both checks to complete
        if hasUser && userCheckCompleted && subscriptionCheckCompleted {
            isLoading = false
            
            if isSubscribed {
                transitionTo(.main)
            } else {
                transitionTo(.paywall)
            }
        }
    }
    
    // MARK: - Reset Methods
    func resetForSubscriptionCheck() {
        subscriptionCheckCompleted = false
        isLoading = true
        transitionTo(.loading)
    }
    
    // MARK: - State Validation
    var isValidState: Bool {
        switch currentState {
        case .loading:
            return isLoading
        case .onboarding:
            return !hasUser
        case .paywall:
            return hasUser && !isSubscribed
        case .main:
            return hasUser && isSubscribed
        }
    }
} 