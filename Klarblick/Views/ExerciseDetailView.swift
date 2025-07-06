//
//  ExerciseDetailView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 02.07.25.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var currentStepIndex = 0
    @State private var isCompleted = false
    @State private var textInputs: [String] = []
    @State private var longTextInput = ""
    @State private var timerSeconds = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    @State private var isBreathing = false
    @State private var isAnimatingToCompletion = false
    @State private var showSuccessIcon = false
    @State private var showSuccessMessage = false
    @State private var showSessionSummary = false
    @State private var showBottomButtons = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var currentStep: ExerciseInstruction {
        exercise.instructions[currentStepIndex]
    }
    
    var progress: Double {
        Double(currentStepIndex + 1) / Double(exercise.instructions.count)
    }
    
    var isLastStep: Bool {
        currentStepIndex == exercise.instructions.count - 1
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            )
            .ignoresSafeArea()
            
            if isCompleted {
                completionView
            } else {
                exerciseView
            }
        }
        .onAppear {
            setupExercise()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var exerciseView: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            // Content
            ScrollView {
                VStack(spacing: 32) {
                    // Exercise info
                    exerciseInfo
                    
                    // Current step
                    currentStepView
                    
                    // Interactive element
                    if currentStep.hasInteractiveElement {
                        interactiveElement
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            
            // Bottom button
            bottomButton
        }
    }
    
    private var header: some View {
        ZStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(Color.ambrosiaIvory)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.afterBurn)
                            .frame(width: max(0, CGFloat(progress) * geometry.size.width), height: 12)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 60)
                
            }
            .padding(.top, 8)
        
    }
    
    private var exerciseInfo: some View {
        VStack(spacing: 4) {
            // Category icon and label
            if currentStep.hasInteractiveElement == false {
                VStack(spacing: 12) {
                    categoryIcon
                        .padding(.top, 60)
                    
                    Text(exercise.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.cyan.opacity(0.2))
                        .cornerRadius(16)
                        .padding(.bottom, 20)
                }
            }
            
            // Title
            Text(exercise.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Description
            Text(exercise.shortDescription)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(Color.cyan.opacity(0.3))
                .frame(width: 80, height: 80)
            
            Image(systemName: categoryIconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.cyan)
        }
    }
    
    private var categoryIconName: String {
        switch exercise.category {
        case .awareness:
            return "eye"
        case .balance:
            return "scale.3d"
        case .reflect:
            return "brain.head.profile"
        }
    }
    
    private var currentStepView: some View {
            // Step content
            VStack(alignment: .leading, spacing: 16) {
                // Step indicator

                HStack {
                    Text("Step \(currentStepIndex + 1)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.cyan.opacity(0.2))
                        .cornerRadius(12)
                    
                    Spacer()
                }
                Text(currentStep.text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }

    
    private var interactiveElement: some View {
        VStack(spacing: 24) {
            switch currentStep.interactiveElementType {
            case .timer:
                timerView
            case .singleWordField:
                singleWordFieldsView
            case .longTextArea:
                longTextAreaView
            default:
                EmptyView()
            }
        }
    }
    
    private var timerView: some View {
        VStack(spacing: 24) {
            // Timer display
            VStack(spacing: 8) {
                Text(formatTime(timerSeconds))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 168)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
    }
    
    private var singleWordFieldsView: some View {
        VStack(spacing: 16) {
            ForEach(0..<(exercise.textFieldCount ?? 1), id: \.self) { index in
                TextField("Type", text: Binding(
                    get: { textInputs.indices.contains(index) ? textInputs[index] : "" },
                    set: { value in
                        if textInputs.indices.contains(index) {
                            textInputs[index] = value
                        }
                    }
                ))
                .textFieldStyle(PlainTextFieldStyle())
                .padding(16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange, lineWidth: textInputs.indices.contains(index) && !textInputs[index].isEmpty ? 2 : 0)
                )
                .foregroundColor(.white)
            }
        }
    }
    
    private var longTextAreaView: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 200)
                
                if longTextInput.isEmpty {
                    Text("Type")
                        .foregroundColor(.white.opacity(0.5))
                        .padding(16)
                }
                
                TextEditor(text: $longTextInput)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .padding(12)
            }
        }
    }
    
    private var bottomButton: some View {
        VStack(spacing: 16) {
            if currentStep.hasInteractiveElement && currentStep.interactiveElementType == .timer {
                // Timer-specific button
                if timerSeconds == 0 {
                    // Timer completed - show continue/complete button
                    Button(action: continueToNextStep) {
                        Text(isLastStep ? "COMPLETE EXERCISE" : "CONTINUE")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                } else {
                    // Timer not completed - show timer control button
                    Button(action: toggleTimer) {
                        Text(isTimerRunning ? "PAUSE TIMER" : "START TIMER")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isTimerRunning ? Color.red : Color.cyan)
                            .cornerRadius(12)
                    }
                }
            } else {
                // Regular continue button for non-timer steps
                ZStack {
                    Button(action: continueToNextStep) {
                        Text(isLastStep ? "COMPLETE EXERCISE" : "CONTINUE")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.ambrosiaIvory)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canContinue ? Color.afterBurn : .gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canContinue)
                    .background(
                        // Background that extends 4px below the button with mangosteen violet
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.mangosteenViolet)
                            .offset(y: 4)
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
    
    private var canContinue: Bool {
        guard currentStep.hasInteractiveElement else { return true }
        
        switch currentStep.interactiveElementType {
        case .timer:
            return timerSeconds == 0 // Timer completed
        case .singleWordField:
            return textInputs.allSatisfy { !$0.isEmpty }
        case .longTextArea:
            return !longTextInput.isEmpty
        default:
            return true
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isBreathing ? 1.7 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isBreathing)
                
                Circle()
                    .fill(Color.cyan.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isBreathing ? 1.5 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isBreathing)
                
                Circle()
                    .fill(Color.cyan.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isBreathing ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.2), value: isBreathing)
                
                Circle()
                    .fill(Color.cyan)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(showSuccessIcon ? 1.0 : 0.0)
            .opacity(showSuccessIcon ? 1.0 : 0.0)
            .onAppear {
                isBreathing = true
            }
            
            // Success message
            VStack(spacing: 12) {
                Text("Exercise Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Great job!")
                    .font(.title2)
                    .foregroundColor(.orange)
            }
            .scaleEffect(showSuccessMessage ? 1.0 : 0.0)
            .opacity(showSuccessMessage ? 1.0 : 0.0)
            
            // Session summary
            VStack(spacing: 20) {
                Text("Session Summary")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                
                HStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text(exercise.duration != nil ? "\(exercise.duration!/60)" : "5")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text("minutes")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 50)
                    
                    VStack(spacing: 8) {
                        Text("+10")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("XP")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 50)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text(exercise.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            .scaleEffect(showSessionSummary ? 1.0 : 0.0)
            .opacity(showSessionSummary ? 1.0 : 0.0)
            
            Spacer()
            
            // Bottom buttons
            VStack(spacing: 16) {
                Button(action: { dismiss() }) {
                    Text("CONTINUE")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.afterBurn)
                        .cornerRadius(12)
                }
                .background(
                    // Background that extends 4px below the button with mangosteen violet
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.mangosteenViolet)
                        .offset(y: 4)
                )

                
                Button(action: {}) {
                    Text("Share Progress")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            .scaleEffect(showBottomButtons ? 1.0 : 0.0)
            .opacity(showBottomButtons ? 1.0 : 0.0)
        }
        .padding(.horizontal, 24)
        .onAppear {
            startCompletionAnimation()
        }
    }
    
    // MARK: - Helper Functions
    
    private func setupExercise() {
        // Initialize text inputs array
        if let textFieldCount = exercise.textFieldCount {
            textInputs = Array(repeating: "", count: textFieldCount)
        }
        
        // Set timer duration if this is a timed exercise
        if let duration = exercise.duration {
            timerSeconds = duration
        }
    }
    
    private func continueToNextStep() {
        if currentStepIndex < exercise.instructions.count - 1 {
            currentStepIndex += 1
            // Reset interactive elements for new step
            resetInteractiveElements()
        } else {
            // Exercise completed - animate to completion screen
            withAnimation(.easeInOut(duration: 2)) {
                isCompleted = true
            }
            awardXp(10)
            incrementStreakIfNeeded()
        }
    }
    
    private func resetInteractiveElements() {
        stopTimer()
        
        // Set timer for new step if needed
        if let duration = exercise.duration,
           currentStep.hasInteractiveElement,
           currentStep.interactiveElementType == .timer {
            timerSeconds = duration
        }
        
        // Clear text inputs if needed
        if currentStep.hasInteractiveElement {
            if currentStep.interactiveElementType == .singleWordField {
                textInputs = Array(repeating: "", count: exercise.textFieldCount ?? 1)
            } else if currentStep.interactiveElementType == .longTextArea {
                longTextInput = ""
            }
        }
    }
    
    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timerSeconds > 0 {
                timerSeconds -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func awardXp(_ amount: Int) {
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            user.currentXp += amount
        }
    }
    
    private func incrementStreak(){
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            user.currentStreak += 1
        }
    }
    
    private func incrementStreakIfNeeded(){
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            let today = Calendar.current.startOfDay(for: Date())
            let lastExerciseDate = user.lastExerciseDate ?? Date.distantPast
            let lastExerciseDay = Calendar.current.startOfDay(for: lastExerciseDate)
            
            // Check if no exercise has been completed today
            if lastExerciseDay < today {
                incrementStreak()
                user.lastExerciseDate = Date()
            }
        }
    }
    
    private func startCompletionAnimation() {
        // Reset all animation states
        showSuccessIcon = false
        showSuccessMessage = false
        showSessionSummary = false
        showBottomButtons = false
        
        // Animate items sequentially from top to bottom
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
            showSuccessIcon = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showSuccessMessage = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showSessionSummary = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
                showBottomButtons = true
            }
        }
    }

    
}

// MARK: - Preview
struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exercise: ExerciseLibrary.predefinedExercises[4])
    }
} 
