//
//  ExerciseDetailView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 02.07.25.
//

import SwiftUI
import SwiftData
import CoreHaptics

// MARK: - Custom Button Component
struct ExerciseButton: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let isDisabled: Bool
    let buttonId: String
    @Binding var pressedButton: String?
    let action: () -> Void
    
    init(
        title: String,
        backgroundColor: Color,
        foregroundColor: Color = .white,
        isDisabled: Bool = false,
        buttonId: String,
        pressedButton: Binding<String?>,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.isDisabled = isDisabled
        self.buttonId = buttonId
        self._pressedButton = pressedButton
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isDisabled ? .gray : backgroundColor)
                .cornerRadius(10)
        }
        .disabled(isDisabled)
        .scaleEffect(pressedButton == buttonId ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.3), radius: pressedButton == buttonId ? 2 : 8, x: 0, y: pressedButton == buttonId ? 2 : 4)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressedButton)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                pressedButton = pressing ? buttonId : nil
            }
        }, perform: {})
    }
}

// MARK: - Secondary Button Component
struct SecondaryExerciseButton: View {
    let title: String
    let foregroundColor: Color
    let buttonId: String
    @Binding var pressedButton: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(foregroundColor)
        }
        .scaleEffect(pressedButton == buttonId ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressedButton)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                pressedButton = pressing ? buttonId : nil
            }
        }, perform: {})
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    let isFromCardView: Bool
    let onCompletion: (() -> Void)?
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
    @State private var pressedButton: String? = nil
    @State private var hapticEngine: CHHapticEngine?
    @State private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    @State private var earnedBadges: [Badge] = []
    @State private var showBadgeNotification = false
    @State private var showShareSheet = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    init(exercise: Exercise, isFromCardView: Bool = false, onCompletion: (() -> Void)? = nil) {
        self.exercise = exercise
        self.isFromCardView = isFromCardView
        self.onCompletion = onCompletion
    }
    
    var currentStep: ExerciseInstruction {
        exercise.instructions[currentStepIndex]
    }
    
    var progress: Double {
        Double(currentStepIndex + 1) / Double(exercise.instructions.count)
    }
    
    var isLastStep: Bool {
        currentStepIndex == exercise.instructions.count - 1
    }
    
    var shareText: String {
        let duration = exercise.duration != nil ? "\(exercise.duration!/60)" : "1"
        return """
        🎉 Just completed a \(exercise.category.rawValue) exercise!
        
        📖 \(exercise.title)
        ⏱️ \(duration) minutes
        ✨ +10 XP earned
        
        Taking care of my mental wellness one step at a time! 🌱
        
        #Mindfulness #MentalHealth #Klarblick
        """
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
            
            // Badge notification overlay
            BadgeNotificationView(badges: earnedBadges, isShowing: $showBadgeNotification)
        }
        .onAppear {
            setupExercise()
            setupHapticEngine()
        }
        .onDisappear {
            stopTimer()
            stopContinuousHapticFeedback()
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
                .cornerRadius(20)
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
                    ExerciseButton(
                        title: isLastStep ? String(localized: "COMPLETE EXERCISE") : String(localized: "CONTINUE"),
                        backgroundColor: .orange,
                        foregroundColor: .white,
                        buttonId: "timer_complete",
                        pressedButton: $pressedButton
                    ) {
                        performHapticFeedback(.medium)
                        continueToNextStep()
                    }
                } else {
                    // Timer not completed - show timer control button
                    ExerciseButton(
                        title: isTimerRunning ? String(localized: "PAUSE TIMER") : String(localized: "START TIMER"),
                        backgroundColor: isTimerRunning ? .red : .cyan,
                        foregroundColor: .white,
                        buttonId: "timer_control",
                        pressedButton: $pressedButton
                    ) {
                        performHapticFeedback(.medium)
                        toggleTimer()
                    }
                }
            } else {
                // Regular continue button for non-timer steps
                ExerciseButton(
                    title: isLastStep ? String(localized: "COMPLETE EXERCISE") : String(localized: "CONTINUE"),
                    backgroundColor: .afterBurn,
                    foregroundColor: .ambrosiaIvory,
                    isDisabled: !canContinue,
                    buttonId: "continue",
                    pressedButton: $pressedButton
                ) {
                    performHapticFeedback(.medium)
                    continueToNextStep()
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
                        Text(exercise.duration != nil ? "\(exercise.duration!/60)" : "1")
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
                        Image(systemName: categoryIconName)
                            .font(.largeTitle)
                            .foregroundColor(.cyan)
                        
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
                ExerciseButton(
                    title: String(localized: "CONTINUE"),
                    backgroundColor: .afterBurn,
                    foregroundColor: .ambrosiaIvory,
                    buttonId: "completion_continue",
                    pressedButton: $pressedButton
                ) {
                    performHapticFeedback(.medium)
                    dismiss()
                }
                
                SecondaryExerciseButton(
                    title: String(localized: "Share Progress"),
                    foregroundColor: .afterBurn,
                    buttonId: "share_progress",
                    pressedButton: $pressedButton
                ) {
                    performHapticFeedback(.light)
                    showShareSheet = true
                }
            }
            .scaleEffect(showBottomButtons ? 1.0 : 0.0)
            .opacity(showBottomButtons ? 1.0 : 0.0)
        }
        .padding(.horizontal, 24)
        .onAppear {
            startCompletionAnimation()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareText])
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
            resetInteractiveElements()
        } else {
            // Exercise completed
            print("🎯 Exercise completed: \(exercise.title)")
            withAnimation(.easeInOut(duration: 2)) {
                isCompleted = true
            }
            awardXp(10)
            incrementStreakIfNeeded()
            
            // Create ExerciseCompletion record
            let completion = ExerciseCompletion(date: Date(), category: exercise.category, source: "library")
            modelContext.insert(completion)
            print("📝 Created ExerciseCompletion record: category=\(exercise.category.rawValue), date=\(completion.date), source=library")
            
            // Save the context to persist all changes (streak, XP, completion record)
            do {
                try modelContext.save()
                print("💾 Successfully saved model context after exercise completion")
            } catch {
                print("❌ Failed to save exercise completion: \(error)")
            }
            
            // Cancel today's mindfulness reminder since an exercise was completed
            NotificationManager.shared.checkAndCancelTodaysNotifications(context: modelContext)
            
            // Call completion handler if from card view
            if isFromCardView {
                onCompletion?()
            }
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
            
            // Check for new badges after XP award
            let newBadges = BadgeChecker.shared.checkForNewBadges(for: user, context: modelContext)
            if !newBadges.isEmpty {
                earnedBadges = newBadges
                showBadgeNotification = true
            }
        }
    }
    
    private func incrementStreak(){
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            let oldStreak = user.currentStreak
            user.currentStreak += 1
            print("📈 Incremented streak: \(oldStreak) → \(user.currentStreak)")
            
            // Check for new badges after streak increment
            let newBadges = BadgeChecker.shared.checkForNewBadges(for: user, context: modelContext)
            if !newBadges.isEmpty {
                earnedBadges = newBadges
                showBadgeNotification = true
                print("🏆 Earned new badges: \(newBadges.map { $0.name })")
            }
        } else {
            print("❌ Could not find user to increment streak")
        }
    }
    
    private func incrementStreakIfNeeded(){
        let descriptor = FetchDescriptor<User>()
        if let user = try? modelContext.fetch(descriptor).first {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            print("🔍 Checking if streak increment needed (using ExerciseCompletion records):")
            print("   Today: \(today)")
            print("   Current streak: \(user.currentStreak)")
            
            // Check if any exercises were completed today
            let todayDescriptor = FetchDescriptor<ExerciseCompletion>(
                predicate: #Predicate<ExerciseCompletion> { completion in
                    completion.date >= today && completion.date < tomorrow
                }
            )
            
            do {
                let todayCompletions = try modelContext.fetch(todayDescriptor)
                print("   Found \(todayCompletions.count) exercise completions today")
                
                for completion in todayCompletions {
                    print("     - Category: \(completion.category), Date: \(completion.date), Source: \(completion.source)")
                }
                
                // Only increment streak if no exercises completed today yet
                if todayCompletions.isEmpty {
                    print("✅ No exercises completed today yet, incrementing streak")
                    incrementStreak()
                } else {
                    print("⏭️ Exercise already completed today, not incrementing streak")
                }
                
            } catch {
                print("❌ Failed to check today's exercise completions: \(error)")
                // In case of error, fall back to incrementing (safer than not incrementing)
                incrementStreak()
            }
        } else {
            print("❌ Could not find user to check streak increment")
        }
    }
    
    private func startCompletionAnimation() {
        // Reset all animation states
        showSuccessIcon = false
        showSuccessMessage = false
        showSessionSummary = false
        showBottomButtons = false
        
        // Start continuous haptic feedback for celebration
        startContinuousHapticFeedback()
        
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
    
    private func performHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine failed to start: \(error.localizedDescription)")
        }
    }
    
    private func startContinuousHapticFeedback() {
        guard let hapticEngine = hapticEngine else {
            setupHapticEngine()
            return
        }
        
        // Create a continuous haptic pattern for celebration
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        
        // Create continuous haptic event (2 seconds duration)
        let continuousEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: 2.0
        )
        
        // Add some dynamic parameter changes for more interesting feedback
        let intensityParameter = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.2),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.5, value: 0.3),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.0, value: 0.4),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.5, value: 0.8),
                CHHapticParameterCurve.ControlPoint(relativeTime: 2.0, value: 0.2)
            ],
            relativeTime: 0
        )
        
        let sharpnessParameter = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: [
                CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0.8),
                CHHapticParameterCurve.ControlPoint(relativeTime: 0.7, value: 0.3),
                CHHapticParameterCurve.ControlPoint(relativeTime: 1.4, value: 0.9),
                CHHapticParameterCurve.ControlPoint(relativeTime: 2.0, value: 0.1)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [continuousEvent], parameterCurves: [intensityParameter, sharpnessParameter])
            continuousPlayer = try hapticEngine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: 0)
        } catch {
            print("Failed to create continuous haptic feedback: \(error.localizedDescription)")
        }
    }
    
    private func stopContinuousHapticFeedback() {
        do {
            try continuousPlayer?.stop(atTime: 0)
        } catch {
            print("Failed to stop continuous haptic feedback: \(error.localizedDescription)")
        }
        continuousPlayer = nil
    }

    
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exercise: ExerciseLibrary.predefinedExercises[4])
    }
} 
