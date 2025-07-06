//
//  OnboardingView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userName = ""
    @State private var currentStep = 0
    @State private var isAnimating = false
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                if currentStep == 0 {
                    welcomeStep
                } else if currentStep == 1 {
                    nameInputStep
                } else if currentStep == 2 {
                    completionStep
                }
            }
            .padding(.horizontal ,30)
            .padding(.top, 100)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.8), value: isAnimating)
            
            VStack(spacing: 20) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .opacity(isAnimating ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(0.2), value: isAnimating)
                
                Text("Klarblick")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(isAnimating ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: isAnimating)
                
                Text("Your journey to mental clarity starts here")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: isAnimating)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStep = 1
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .opacity(isAnimating ? 1.0 : 0)
            .animation(.easeInOut(duration: 0.8).delay(0.8), value: isAnimating)
        }
    }
    
    private var nameInputStep: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Text("What's your name?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("We'd love to personalize your experience")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                    .padding(.horizontal, 10)
                    .frame(height: 50)
                
                Text("Don't worry, you can change this later")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentStep = 0
                    }
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    if !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        createUser()
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep = 2
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private var completionStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.8), value: isAnimating)
            
            VStack(spacing: 20) {
                Text("Welcome, \(userName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("You're all set to begin your journey to mental clarity and wellbeing.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isOnboardingComplete = true
                }
            }) {
                Text("Let's Begin")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
    
    private func createUser() {
        let newUser = User(name: userName.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(newUser)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
} 
