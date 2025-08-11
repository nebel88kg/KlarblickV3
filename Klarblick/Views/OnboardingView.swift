//
//  OnboardingView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData

// MARK: - Localization Protocol
protocol Localizable {
    var localizedTitle: String { get }
}

enum HapticType {
    case light, medium, heavy, success, selection
    
    var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        case .success, .selection: return .medium // fallback
        }
    }
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userName = ""
    @State private var currentStep = 0
    @State private var isAnimating = false
    @State private var isBenefitsAnimating = false
    @State private var selectedGoal: WellnessGoal?
    @State private var selectedAge: AgeRange?
    @State private var selectedExperience: MindfulnessExperience?
    @State private var selectedStressLevel: StressLevel?
    @State private var reminderTime = Date()
    @State private var hasCompletedBreathingExercise = false
    @State private var isRequestingNotificationPermission = false
    @State private var isCreatingPlan = false
    @State private var loadingProgress: Double = 0.0
    @State private var currentLoadingStep = 0
    @State private var animatedWeekCards = 0
    @Binding var isOnboardingComplete: Bool
    
    // MARK: - Haptic Feedback
    private func triggerHaptic(_ type: HapticType) {
        switch type {
        case .light, .medium, .heavy:
            let impactFeedback = UIImpactFeedbackGenerator(style: type.impactStyle)
            impactFeedback.impactOccurred()
        case .success:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        case .selection:
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
    }
    
    
    enum WellnessGoal: String, CaseIterable, Localizable {
        case lessAnxiety, moreEnergy, betterSleep, focus, createHabit
        
        var icon: String {
            switch self {
            case .lessAnxiety: return "heart.circle.fill"
            case .moreEnergy: return "bolt.circle.fill"
            case .betterSleep: return "moon.circle.fill"
            case .focus: return "target"
            case .createHabit: return "plus"
            }
        }
        
        var color: Color {
            switch self {
            case .lessAnxiety: return .pink
            case .moreEnergy: return .orange
            case .betterSleep: return .blue
            case .focus: return .purple
            case .createHabit: return .green
            }
        }
        
        var localizedTitle: String {
            switch self {
            case .lessAnxiety: return String(localized: "goal_less_anxiety")
            case .moreEnergy: return String(localized: "goal_more_energy")
            case .betterSleep: return String(localized: "goal_better_sleep")
            case .focus: return String(localized: "goal_clear_head")
            case .createHabit: return String(localized: "goal_create_habit")
            }
        }
    }
    
    enum AgeRange: String, CaseIterable, Localizable {
        case teens, twenties, thirties, forties, fifties
        
        var localizedTitle: String {
            switch self {
            case .teens: return String(localized: "age_under_20")
            case .twenties: return String(localized: "age_20_29")
            case .thirties: return String(localized: "age_30_39")
            case .forties: return String(localized: "age_40_49")
            case .fifties: return String(localized: "age_50_plus")
            }
        }
    }
    
    enum MindfulnessExperience: String, CaseIterable, Localizable {
        case beginner, some, experienced
        
        var localizedTitle: String {
            switch self {
            case .beginner: return String(localized: "experience_complete_beginner")
            case .some: return String(localized: "experience_some_experience")
            case .experienced: return String(localized: "experience_meditating_regularly")
            }
        }
    }
    
    enum StressLevel: String, CaseIterable, Localizable {
        case low, moderate, high, notSure
        
        var localizedTitle: String {
            switch self {
            case .low: return String(localized: "stress_low")
            case .moderate: return String(localized: "stress_moderate")
            case .high: return String(localized: "stress_high")
            case .notSure: return String(localized: "stress_not_sure")
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        ZStack {
            if currentStep == 0 {
                // Beautiful sunset mountain background for welcome step
                SunsetMountainView()
                    .ignoresSafeArea()
            } else {
                // Background gradient for other steps
            RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            )
            .ignoresSafeArea()
            }
            
            VStack(spacing: 40) {
                if currentStep == 0 {
                    welcomeStep
                } else if currentStep == 1 {
                    benefitsStep
                } else if currentStep == 2 {
                    breathingIntroStep
                } else if currentStep == 3 {
                    breathingExerciseStep
                } else if currentStep == 4 {
                    breathingCompletionStep
                } else if currentStep == 5 {
                    nameInputStep
                } else if currentStep == 6 {
                    ageSelectionStep
                } else if currentStep == 7 {
                    experienceSelectionStep
                } else if currentStep == 8 {
                    stressLevelStep
                } else if currentStep == 9 {
                    goalSelectionStep
                } else if currentStep == 10 {
                    reminderTimeStep
                } else if currentStep == 11 {
                    planOverviewStep
                } else if currentStep == 12 {
                    completionStep
                } else if currentStep == 13 {
                    thirtyDayPlanStep
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
        .onChange(of: currentStep) { oldValue, newValue in
            if newValue == 1 {
                // Reset and trigger benefits animation
                isBenefitsAnimating = false
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.1)) {
                    isBenefitsAnimating = true
                }
            }
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 8) {
            HStack {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .cornerRadius(12)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0), value: isAnimating)
                
                Text("Klarblick")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.purpleCarolite)
                    .offset(x: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1.0 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0).delay(0.1), value: isAnimating)
            }
            
            Text("Your journey to mental clarity")
                .font(.caption)
                .foregroundColor(.purpleCarolite)
                .multilineTextAlignment(.center)
                .offset(y: isAnimating ? 0 : 10)
                    .opacity(isAnimating ? 1.0 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0).delay(0.2), value: isAnimating)
            
            
            Spacer()
            
            Button(action: {
                triggerHaptic(.light)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    currentStep = 1
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.ambrosiaIvory)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.afterBurn)
                    .cornerRadius(12)
                    .padding(.bottom, 34)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.95)
            .opacity(isAnimating ? 1.0 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.3), value: isAnimating)
        }
        .ignoresSafeArea(edges: .bottom)
        
    }
    
    private var benefitsStep: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text(String(localized: "Welcome to Klarblick"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                    .offset(y: isBenefitsAnimating ? 0 : -50)
                    .opacity(isBenefitsAnimating ? 1.0 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0).delay(0.1), value: isBenefitsAnimating)
                
                Text(String(localized: "Your new safe space for wellbeing"))
                    .font(.subheadline)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(isBenefitsAnimating ? 1.0 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.9, blendDuration: 0).delay(0.3), value: isBenefitsAnimating)
            }
            .padding(.bottom, 80)
            
            VStack(spacing: 60) {
                BenefitRow(
                    title: String(localized: "Thousands"),
                    subtitle: String(localized: "Already trust us")
                )
                .opacity(isBenefitsAnimating ? 1.0 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(0.5), value: isBenefitsAnimating)
                
                BenefitRow(
                    title: "96%",
                    subtitle: String(localized: "Satisfaction rate")
                )
                .opacity(isBenefitsAnimating ? 1.0 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(1), value: isBenefitsAnimating)
                
                BenefitRow(
                    title: String(localized: "Science"),
                    subtitle: String(localized: "Based approach")
                )
                .opacity(isBenefitsAnimating ? 1.0 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0).delay(1.5), value: isBenefitsAnimating)
            }
            
            Spacer()
            
            Button(action: {
                triggerHaptic(.light)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    currentStep = 2
                }
            }) {
                Text(String(localized: "Continue"))
                    .font(.headline)
                    .foregroundColor(.ambrosiaIvory)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.afterBurn)
                    .cornerRadius(12)
            }
            .scaleEffect(isBenefitsAnimating ? 1.0 : 0.8)
            .opacity(isBenefitsAnimating ? 1.0 : 0)
            .animation(.spring(response: 0.9, dampingFraction: 0.8, blendDuration: 0).delay(2), value: isBenefitsAnimating)
        }
    }
    
    private var breathingIntroStep: some View {
        VStack(spacing: 10) {

                
                Text(String(localized: "Let's take a few seconds to feel better"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)

            Text(String(localized: "Experience the power of mindfulness with a simple breathing exercise"))
                .font(.subheadline)
                .foregroundColor(.wildMaple)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    triggerHaptic(.medium)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 3
                    }
                }) {
                    Text(String(localized: "Start Exercise"))
                        .font(.headline)
                        .foregroundColor(.ambrosiaIvory)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.afterBurn)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    triggerHaptic(.light)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 5  // Skip to name input
                    }
                }) {
                    Text(String(localized: "Skip for now"))
                        .font(.subheadline)
                        .foregroundColor(.ambrosiaIvory)
                }
            }
        }
    }
    
    private var breathingExerciseStep: some View {
        BreathingExerciseView(
            onComplete: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    currentStep = 4
                }
            },
            onSkip: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    currentStep = 5  // Skip to name input
                }
            }
        )
    }
    
    private var breathingCompletionStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0), value: isAnimating)
                
                VStack(spacing: 15) {
                    Text(String(localized: "Nice work!"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                        .multilineTextAlignment(.center)
                    
                    Text(String(localized: "You just completed your first session"))
                        .font(.title3)
                        .foregroundColor(.wildMaple)
                        .multilineTextAlignment(.center)
                    
                    Text(String(localized: "That's the first step towards clarity"))
                        .font(.subheadline)
                        .foregroundColor(.ambrosiaIvory)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            
            Spacer()
            
            Button(action: {
                triggerHaptic(.success)
                hasCompletedBreathingExercise = true
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    currentStep = 5
                }
            }) {
                Text(String(localized: "Continue"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.afterBurn)
                    .cornerRadius(12)
            }
        }
    }
    
    private var goalSelectionStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Text(String(localized: "What do you want most right now?"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10) {
                ForEach(WellnessGoal.allCases, id: \.self) { goal in
                    Button(action: {
                        triggerHaptic(.selection)
                        selectedGoal = goal
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: goal.icon)
                                .font(.title2)
                                .foregroundColor(goal.color)
                                .frame(width: 30)
                            
                            Text(goal.localizedTitle)
                                .font(.headline)
                                .foregroundColor(.ambrosiaIvory)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedGoal == goal ? goal.color.opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedGoal == goal ? goal.color : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                        )
                        .contentShape(Rectangle())
                        .scaleEffect(selectedGoal == goal ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedGoal == goal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    triggerHaptic(.light)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 8
                    }
                }) {
                    Text(String(localized: "Back"))
                        .font(.headline)
                        .foregroundColor(.afterBurn)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.afterBurn.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    triggerHaptic(.medium)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 10
                    }
                }) {
                    Text(String(localized: "Continue"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedGoal != nil ? Color.afterBurn : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(selectedGoal == nil)
            }
        }
    }
    
    private var reminderTimeStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 10) {
                Text(String(localized: "When should we remind you"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                
                Text(String(localized: "to check in daily?"))
                    .font(.subheadline)
                    .foregroundColor(.wildMaple)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 30) {
                DatePicker(
                    String(localized: "Reminder Time"),
                    selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .foregroundColor(.ambrosiaIvory)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .colorScheme(.dark)

                
                Text(String(localized: "We'll send you a gentle reminder to check in with yourself and track your progress"))
                    .font(.caption)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    triggerHaptic(.light)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 9
                    }
                }) {
                    Text(String(localized: "Back"))
                        .font(.headline)
                        .foregroundColor(.afterBurn)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.afterBurn.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    triggerHaptic(.medium)
                    Task {
                        isRequestingNotificationPermission = true
                        let granted = await NotificationManager.shared.requestAuthorization()
                        
                        if granted {
                            await NotificationManager.shared.scheduleDailyReminders(at: reminderTime)
                            await NotificationManager.shared.saveReminderTime(reminderTime)
                        }
                        
                        isRequestingNotificationPermission = false
                        
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                            currentStep = 11
                        }
                    }
                }) {
                    HStack {
                        if isRequestingNotificationPermission {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(isRequestingNotificationPermission ? String(localized: "Setting up...") : String(localized: "Set Reminder"))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.afterBurn)
                    .cornerRadius(12)
                }
                .disabled(isRequestingNotificationPermission)
            }
        }
    }
    
    private var loadingSteps: [String] {
        [
            String(localized: "Analyzing answers"),
            String(localized: "Checking goals"),
            String(localized: "Creating recommendations"),
            String(localized: "Personalizing experience")
        ]
    }
    
    private var planCreationLoadingView: some View {
        VStack(spacing: 60) {
            VStack(spacing: 20) {
                Text("Creating your plan...")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                
                Text("Personalizing your wellness journey")
                    .font(.subheadline)
                    .foregroundColor(.wildMaple)
                    .multilineTextAlignment(.center)
            }
            
            // Circular progress bar
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0.0, to: loadingProgress)
                    .stroke(Color.afterBurn,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: loadingProgress)
                
                // Center percentage text
                VStack(spacing: 4) {
                    Text("\(Int(loadingProgress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                    
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.afterBurn)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
            .frame(height: 140)
            
            // Loading steps
            VStack(spacing: 20) {
                ForEach(0..<loadingSteps.count, id: \.self) { index in
                    HStack(spacing: 15) {
                        // Step indicator
                        ZStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 24, height: 24)
                            
                            if index <= currentLoadingStep {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        // Step text
                        Text(loadingSteps[index])
                            .font(.subheadline)
                            .foregroundColor(index <= currentLoadingStep ? .ambrosiaIvory : .gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }
                    .opacity(index <= currentLoadingStep ? 1.0 : 0)
                    .offset(x: index <= currentLoadingStep ? 0 : 20)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .onAppear {
            startLoadingAnimation()
        }
    }
    
    private func startLoadingAnimation() {
        // Reset state
        isAnimating = false
        loadingProgress = 0.0
        currentLoadingStep = 0
        
        // Start sparkle animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = true
        }
        
        // Animate through each step
        for i in 0..<loadingSteps.count {
            let delay = Double(i) * 2.0 // 2 seconds per step
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    currentLoadingStep = i
                    loadingProgress = Double(i + 1) / Double(loadingSteps.count)
                }
            }
        }
    }
    
    private func startWeekCardAnimations() {
        // Reset animation state
        animatedWeekCards = 0
        
        // Animate cards one by one
        for i in 1...4 {
            let delay = Double(i - 1) * 0.3 // 0.3 seconds between each card
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0)) {
                    animatedWeekCards = i
                }
            }
        }
    }
    
    private var planOverviewStep: some View {
        VStack(spacing: 40) {
            if isCreatingPlan {
                // Loading screen
                planCreationLoadingView
            } else {
                // Plan overview content
                VStack(spacing: 10) {
                    Text("Let's build your")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                        .multilineTextAlignment(.center)
                    
                    Text("30-day mental wellness plan")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.wildMaple)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 10) {
                    if let goal = selectedGoal {
                        HStack(spacing: 15) {
                            Image(systemName: goal.icon)
                                .font(.title)
                                .foregroundColor(goal.color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Goal")
                                    .font(.caption)
                                    .foregroundColor(.wildMaple)
                                Text(goal.localizedTitle)
                                    .font(.headline)
                                    .foregroundColor(.ambrosiaIvory)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(goal.color.opacity(0.1))
                        )
                    }
                    
                    HStack(spacing: 15) {
                        Image(systemName: "clock.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Check-in")
                                .font(.caption)
                                .foregroundColor(.wildMaple)
                            Text("\(reminderTime, formatter: timeFormatter)")
                                .font(.headline)
                                .foregroundColor(.ambrosiaIvory)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                    
                    HStack(spacing: 15) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.title)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Plan Duration")
                                .font(.caption)
                                .foregroundColor(.wildMaple)
                            Text("30 Days")
                                .font(.headline)
                                .foregroundColor(.ambrosiaIvory)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                }
                
                Spacer()
                
                Button(action: {
                    triggerHaptic(.heavy)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        isCreatingPlan = true
                    }
                    
                    // After 10 seconds (4 steps * 2 seconds each + 2 seconds buffer), proceed to completion step
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                            isCreatingPlan = false
                            currentStep = 12
                        }
                    }
                }) {
                    Text("Create My Plan")
                        .font(.headline)
                        .foregroundColor(.ambrosiaIvory)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.afterBurn)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var thirtyDayPlanStep: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Your transformation journey")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                
                Text("See what you can achieve in just 30 days")
                    .font(.subheadline)
                    .foregroundColor(.wildMaple)
                    .multilineTextAlignment(.center)
            }
            
            // 4-week progression
            VStack(spacing: 10) {
                WeekProgressView(
                    weekNumber: 1,
                    title: String(localized: "week_1_title"),
                    description: String(localized: "week_1_description"),
                    icon: "seedling",
                    isVisible: animatedWeekCards >= 1
                )
                
                WeekProgressView(
                    weekNumber: 2,
                    title: String(localized: "week_2_title"),
                    description: String(localized: "week_2_description"),
                    icon: "leaf",
                    isVisible: animatedWeekCards >= 2
                )
                
                WeekProgressView(
                    weekNumber: 3,
                    title: String(localized: "week_3_title"),
                    description: String(localized: "week_3_description"),
                    icon: "sun.max",
                    isVisible: animatedWeekCards >= 3
                )
                
                WeekProgressView(
                    weekNumber: 4,
                    title: String(localized: "week_4_title"),
                    description: String(localized: "week_4_description"),
                    icon: "star",
                    isVisible: animatedWeekCards >= 4
                )
            }
            .onAppear {
                startWeekCardAnimations()
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    triggerHaptic(.success)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        isOnboardingComplete = true
                    }
                }) {
                    Text("Get access")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.afterBurn)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var ageSelectionStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Text("How old are you?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10) {
                ForEach(AgeRange.allCases, id: \.self) { age in
                    Button(action: {
                        triggerHaptic(.selection)
                        selectedAge = age
                    }) {
                        HStack(spacing: 15) {
                            Text(age.localizedTitle)
                                .font(.headline)
                                .foregroundColor(.ambrosiaIvory)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if selectedAge == age {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedAge == age ? Color.afterBurn.opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedAge == age ? Color.afterBurn : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                        )
                        .contentShape(Rectangle())
                        .scaleEffect(selectedAge == age ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedAge == age)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    triggerHaptic(.light)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 5
                    }
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.afterBurn)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.afterBurn.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    triggerHaptic(.medium)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 7
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedAge != nil ? Color.afterBurn : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(selectedAge == nil)
            }
        }
    }
    
    private var experienceSelectionStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Text("What's your experience with mindfulness?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10) {
                ForEach(MindfulnessExperience.allCases, id: \.self) { experience in
                    Button(action: {
                        triggerHaptic(.selection)
                        selectedExperience = experience
                    }) {
                        HStack(spacing: 15) {
                            Text(experience.localizedTitle)
                                .font(.headline)
                                .foregroundColor(.ambrosiaIvory)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if selectedExperience == experience {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedExperience == experience ? Color.afterBurn.opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedExperience == experience ? Color.afterBurn : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                        )
                        .contentShape(Rectangle())
                        .scaleEffect(selectedExperience == experience ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedExperience == experience)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    triggerHaptic(.light)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 6
                    }
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.afterBurn)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.afterBurn.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    triggerHaptic(.medium)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 8
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedExperience != nil ? Color.afterBurn : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(selectedExperience == nil)
            }
        }
    }
    
    private var stressLevelStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Text("What's your current stress level?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10) {
                ForEach(StressLevel.allCases, id: \.self) { stress in
                    Button(action: {
                        triggerHaptic(.selection)
                        selectedStressLevel = stress
                    }) {
                        HStack(spacing: 15) {
                            Text(stress.localizedTitle)
                                .font(.headline)
                                .foregroundColor(.ambrosiaIvory)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if selectedStressLevel == stress {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedStressLevel == stress ? stressColor(for: stress).opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedStressLevel == stress ? stressColor(for: stress) : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                        )
                        .contentShape(Rectangle())
                        .scaleEffect(selectedStressLevel == stress ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: selectedStressLevel == stress)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    triggerHaptic(.light)
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 7
                    }
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.afterBurn)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.afterBurn.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    triggerHaptic(.medium)
                    createUser()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        currentStep = 9
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedStressLevel != nil ? Color.afterBurn : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(selectedStressLevel == nil)
            }
        }
    }
    
    private func stressColor(for stress: StressLevel) -> Color {
        switch stress {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .red
        case .notSure: return .blue
        }
    }
    
    private var nameInputStep: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("How can we call you?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                TextField("Nickname...", text: $userName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundStyle(Color.ambrosiaIvory)
                    .padding(10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .font(.subheadline)
                    .frame(height: 60)
                    .accentColor(.wildMaple)
                    .colorScheme(.dark)  // Add this to force dark mode
                    .onChange(of: userName) { oldValue, newValue in
                        if newValue.count > 20 {
                            userName = String(newValue.prefix(20))
                        }
                    }

                
                Text("Don't worry, you can change this later")
                    .font(.caption)
                    .foregroundColor(.ambrosiaIvory)
            }
            
            Spacer()
            
                
            Button(action: {
                if !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    triggerHaptic(.medium)
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentStep = 6
                    }
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.afterBurn)
                    .cornerRadius(12)
            }
                .disabled(userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
        }
    }
    
    private var completionStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.8), value: isAnimating)
            
            VStack(spacing: 10) {
                Text("Welcome, \(userName)!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                
                Text("You're all set to begin your journey to mental clarity and wellbeing.")
                    .font(.subheadline)
                    .foregroundColor(.wildMaple)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                triggerHaptic(.medium)
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentStep = 13
                }
            }) {
                Text("See Your Plan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.afterBurn)
                    .cornerRadius(12)
            }
        }
    }
    
    private func createUser() {
        let newUser = User(name: userName.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(newUser)
        
        // Initialize badges for the new user
        BadgeManager.shared.initializeBadgesForUser(newUser, context: modelContext)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
}

struct BenefitRow: View {
    let title: String
    let subtitle: String
    @State private var sparkleScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundColor(.yellow)
                .scaleEffect(sparkleScale)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: sparkleScale)
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                
                Text(subtitle)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
            }
            
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundColor(.yellow)
                .scaleEffect(sparkleScale)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: sparkleScale)
        }
        .onAppear {
            sparkleScale = 1.1
        }
    }
}

struct BreathingExerciseView: View {
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    private func triggerHaptic(_ type: HapticType) {
        switch type {
        case .light, .medium, .heavy:
            let impactFeedback = UIImpactFeedbackGenerator(style: type.impactStyle)
            impactFeedback.impactOccurred()
        case .success:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        case .selection:
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        }
    }
    
    @State private var breathingScale: CGFloat = 0.7
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var breathCount = 0
    @State private var isActive = false
    @State private var phaseText = String(localized: "Get Ready")
    @State private var showCompletionAnimation = false
    
    private let totalBreaths = 4 // 3 minutes ≈ 6 breaths for demo
    private let inhaleTime: Double = 5.0
    private let holdTime: Double = 2.0
    private let exhaleTime: Double = 5.0
    
    enum BreathingPhase {
        case inhale, hold, exhale, pause
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Fixed progress indicator position
                HStack {
                    ForEach(0..<totalBreaths, id: \.self) { index in
                        Circle()
                            .fill(index < breathCount ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == breathCount - 1 ? 1.2 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: breathCount)
                    }
                }
                .frame(height: 20)
                .padding(.bottom, 20)
                                
                // Fixed breathing circle position
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color.pharaohsSeas.opacity(0.3), lineWidth: 3)
                        .frame(width: 250, height: 250)
                    
                    // Inner animated circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.pharaohsSeas.opacity(0.6), Color.pharaohsSeas.opacity(0.2)],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 250, height: 250)
                        .scaleEffect(breathingScale)
                        .animation(.easeInOut(duration: getCurrentPhaseDuration()), value: breathingScale)
                    
                    // Breathing instruction text
                    VStack(spacing: 8) {
                        Text(phaseText)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.ambrosiaIvory)
                    }
                }.padding(.bottom, 40)
            
                
            }
            .offset(y: -80)

            // Instruction text (positioned below circle)
            if !isActive {
                Text("Follow the circle with your breath")
                    .font(.subheadline)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                    .opacity(!isActive ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isActive)
                    .offset(y: 80)
            }
            
            // Skip button during exercise
            if isActive && breathCount < totalBreaths {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        triggerHaptic(.light)
                        onSkip()
                    }) {
                        Text("Skip Exercise")
                            .font(.subheadline)
                            .foregroundColor(.ambrosiaIvory)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(20)
                    }
                    .opacity(isActive ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isActive)
                    .padding(.bottom, 20)
                }
            }

            
            // Overlaid content that can appear/disappear
            VStack {
                Spacer()
                Spacer()
                Spacer() // Push content down below the circle

                
                Spacer()
                
                // Start button (positioned at bottom)
                if !isActive && breathCount == 0 {
                    VStack(spacing: 15) {
                        Button(action: {
                            triggerHaptic(.medium)
                            startBreathing()
                        }) {
                            Text("Begin Breathing")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.afterBurn)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            triggerHaptic(.light)
                            onSkip()
                        }) {
                            Text("Skip Exercise")
                                .font(.subheadline)
                                .foregroundColor(.ambrosiaIvory)
                        }
                    }
                    .opacity(!isActive && breathCount == 0 ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isActive)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            if breathCount >= totalBreaths {
                completeExercise()
            }
        }
    }
    
    private func getCurrentPhaseDuration() -> Double {
        switch currentPhase {
        case .inhale: return inhaleTime
        case .hold: return holdTime
        case .exhale: return exhaleTime
        case .pause: return 1.0
        }
    }
    
    private func startBreathing() {
        isActive = true
        nextBreathingPhase()
    }
    
    private func nextBreathingPhase() {
        guard isActive && breathCount < totalBreaths else {
            completeExercise()
            return
        }
        
        switch currentPhase {
        case .inhale:
            phaseText = String(localized: "Breathe In")
            breathingScale = 1
            triggerHaptic(.light)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + inhaleTime) {
                currentPhase = .exhale
                nextBreathingPhase()
            }
            
        case .exhale:
            phaseText = String(localized: "Breathe Out")
            breathingScale = 0.7
            triggerHaptic(.light)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + exhaleTime) {
                currentPhase = .hold
                nextBreathingPhase()
            }
            
        case .hold:
            phaseText = String(localized: "Hold")
            triggerHaptic(.medium)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + holdTime) {
                currentPhase = .pause
                nextBreathingPhase()
            }
            
        case .pause:
            phaseText = String(localized: "Relax")
            breathingScale = 0.7
            breathCount += 1
            
            if breathCount < totalBreaths {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    currentPhase = .inhale
                    nextBreathingPhase()
                }
            } else {
                completeExercise()
            }
        }
    }
    
    private func completeExercise() {
        isActive = false
        phaseText = String(localized: "Complete!")
        breathingScale = 1.0
        triggerHaptic(.success)
        
        // Completion animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            showCompletionAnimation = true
        }
        
        // Auto-advance after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            onComplete()
        }
    }
    
}

struct WeekProgressView: View {
    let weekNumber: Int
    let title: String
    let description: String
    let icon: String
    let isVisible: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // Content
            VStack(alignment: .leading, spacing: 8) {
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.wildMaple)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()

            // Week indicator
            VStack(alignment: .trailing, spacing: 8) {
                Text(String(localized: "week_number", defaultValue: "Week \(weekNumber)"))
                    .font(.subheadline)
                    .foregroundColor(.ambrosiaIvory)

            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [Color.purpleCarolite, Color.afterBurn.opacity(0.7)], startPoint: .trailing, endPoint: .leading))
        )
        .shadow(radius: 8)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(x: isVisible ? 0 : 50)
        .animation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0), value: isVisible)
    }
}



#Preview {
    
    OnboardingView(isOnboardingComplete: .constant(false))
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
} 
