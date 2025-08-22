//
//  StreakEncouragementView.swift
//  Klarblick
//
//  Created by Assistant on 26.12.24.
//

import RiveRuntime
import SwiftUI


struct StreakEncouragementView: View {
    let oldStreak: Int
    let newStreak: Int
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    
    @State private var animationPhase: AnimationPhase = .initial
    @State private var celebrationText: String = " "
    @State private var currentDisplayedStreak: Int = 0
    @State private var pressedButton: String? = nil
    
    private var numberColor: Color {
        switch animationPhase {
        case .initial:
            return .gray.opacity(0.5)
        case .showOldStreak:
            return .gray.opacity(0.5)
        case .transformToNew, .celebration:
            return .orange
        }
    }
    
    private enum AnimationPhase {
        case initial
        case showOldStreak
        case transformToNew
        case celebration
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            
            RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            )
            .ignoresSafeArea()
            .onTapGesture {
                dismissView()
            }
            
            VStack(spacing: 70) {
                Spacer()
                Spacer()
                    VStack(spacing: 0) {
                        // Fire emoji
                        Text("🔥")
                            .font(.system(size: 100))
                            .opacity(animationPhase != .initial ? 1 : 0)
                            .animation(.bouncy(duration: 0.6).delay(0.3), value: animationPhase)
                        
                                                 // Rolling streak number
                        Text("\(currentDisplayedStreak)")
                            .font(.system(size: 120, weight: .bold, design: .rounded))
                            .foregroundColor(numberColor)
                            .opacity(animationPhase != .initial ? 1 : 0)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.8), value: currentDisplayedStreak)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animationPhase)
                        
                        // "Day Streak" text
                        Text("day streak")
                            .font(.system(size: 32, weight: .medium, design: .rounded))
                            .foregroundColor(.orange)
                            .opacity(animationPhase == .celebration ? 1 : 0)
                            .animation(.easeInOut(duration: 0.4).delay(0.5), value: animationPhase)
                    
                }
                .frame(width: 250, height: 250)
                                
                // Encouragement message
                ZStack() {
                    
                    // Celebration text
                    Text(celebrationText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.ambrosiaIvory)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.ambrosiaIvory, lineWidth: 2)
                        .frame(width: .infinity, height: 50)
                        .padding(.horizontal, 20)
                    

                }
                .opacity(animationPhase == .celebration ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(1.5), value: animationPhase)
                
                Spacer()
                
                // Continue button
                ExerciseButton(
                    title: "Continue",
                    backgroundColor: .afterBurn,
                    foregroundColor: .ambrosiaIvory,
                    buttonId: "streak_continue",
                    pressedButton: $pressedButton
                ) {
                    dismissView()
                }
                .opacity(animationPhase == .celebration ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(2.5), value: animationPhase)
            }
            .padding()
            
            
        }
        .onAppear {
            currentDisplayedStreak = oldStreak
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1: Show old streak
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                animationPhase = .showOldStreak
            }
        }
        
        // Phase 2: Transform to new streak with rolling animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                animationPhase = .transformToNew
            }
            withAnimation(.easeInOut(duration: 0.8)) {
                currentDisplayedStreak = newStreak
            }
        }
        
        // Phase 3: Celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation {
                animationPhase = .celebration
                celebrationText = getCelebrationText()
            }
        }
    }
    

    
    private func getCelebrationText() -> String {
        switch newStreak {
        case 1:
            return "Great start!"
        case 2:
            return "Building momentum!"
        case 3:
            return "Three in a row!"
        case 7:
            return "One week strong!"
        case 14:
            return "Two weeks amazing!"
        case 30:
            return "One month incredible!"
        case 50:
            return "Fifty days legendary!"
        case 100:
            return "One hundred days epic!"
        default:
            if newStreak < 7 {
                return "Keep it up!"
            } else if newStreak < 30 {
                return "You're unstoppable!"
            } else {
                return "Absolutely incredible!"
            }
        }
    }
    
    private func dismissView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isPresented = false
            onDismiss()
        }
    }
}


// MARK: - Preview
#Preview {
    StreakEncouragementView(
        oldStreak: 231,
        newStreak: 232,
        isPresented: .constant(true),
        onDismiss: {}
    )
}
