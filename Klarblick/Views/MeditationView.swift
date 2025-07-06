//
//  MeditationView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 04.07.25.
//

import SwiftUI

struct MeditationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDuration: Int = 5
    @State private var isTimerActive = false
    @State private var timeRemaining = 300
    @State private var timer: Timer?
    
    let durations = [5, 10, 15, 20, 30]
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Text("Meditation")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray2)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.gray2.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Timer Display
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.gray2.opacity(0.3), lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.yellow, lineWidth: 8)
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    VStack {
                        Text(timeString)
                            .font(.system(size: 36, weight: .light, design: .monospaced))
                            .foregroundColor(.ambrosiaIvory)
                        
                        if isTimerActive {
                            Text("Breathe deeply")
                                .font(.caption)
                                .foregroundColor(.gray2)
                                .italic()
                        }
                    }
                }
                .shadow(color: .yellow.opacity(0.5), radius: 20, x: 0, y: 0)
            }
            
            // Duration Selection
            if !isTimerActive {
                VStack(spacing: 15) {
                    Text("Select Duration")
                        .font(.headline)
                        .foregroundColor(.ambrosiaIvory)
                    
                    HStack(spacing: 10) {
                        ForEach(durations, id: \.self) { duration in
                            Button(action: {
                                selectedDuration = duration
                                timeRemaining = duration * 60
                            }) {
                                Text("\(duration) min")
                                    .font(.subheadline)
                                    .foregroundColor(selectedDuration == duration ? .backgroundSecondary : .gray2)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedDuration == duration ? Color.yellow : Color.gray2.opacity(0.2))
                                    )
                            }
                        }
                    }
                }
            }
            
            // Control Button
            Button(action: {
                if isTimerActive {
                    stopTimer()
                } else {
                    startTimer()
                }
            }) {
                Text(isTimerActive ? "Stop" : "Start")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.backgroundSecondary)
                    .frame(width: 120, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.yellow)
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            
            // Meditation Tips
            if !isTimerActive {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Meditation Tips:")
                        .font(.headline)
                        .foregroundColor(.ambrosiaIvory)
                    
                    Text("• Find a quiet, comfortable space")
                        .font(.subheadline)
                        .foregroundColor(.gray2)
                    
                    Text("• Close your eyes and focus on your breath")
                        .font(.subheadline)
                        .foregroundColor(.gray2)
                    
                    Text("• Let thoughts come and go without judgment")
                        .font(.subheadline)
                        .foregroundColor(.gray2)
                    
                    Text("• Start with shorter sessions and build up")
                        .font(.subheadline)
                        .foregroundColor(.gray2)
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .background(RadialGradient(
            colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
            center: .bottom,
            startRadius: 100,
            endRadius: 900
        ))
        .navigationBarHidden(true)
        .onDisappear {
            stopTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            stopTimer()
        }
    }
    
    private var progress: CGFloat {
        let totalTime = selectedDuration * 60
        return CGFloat(totalTime - timeRemaining) / CGFloat(totalTime)
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        isTimerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        isTimerActive = false
        timer?.invalidate()
        timer = nil
        timeRemaining = selectedDuration * 60
    }
}

#Preview {
    NavigationView {
        MeditationView()
    }
} 