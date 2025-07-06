//
//  LibraryView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct LibraryView: View {
    @State private var showMeditation = false
    
    var body: some View {
        NavigationView {
            VStack {
                TopStatsBar()

                Text("Library")
                    .font(.title)
                    .foregroundColor(.ambrosiaIvory)
                    .padding(.vertical, 10)

                // Cards Grid
                VStack(spacing: 5) {
                    // Top row with Reflect and Balance/Meditation
                    HStack(spacing: 5) {
                        // Reflect Card (larger)
                        NavigationLink(destination: CategoryExerciseListView(category: .reflect)) {
                            ReflectCard()
                                .frame(width: 180, height: 353)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Right column with Balance and Meditation
                        VStack(spacing: 5) {
                            NavigationLink(destination: CategoryExerciseListView(category: .balance)) {
                                BalanceCard()
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                showMeditation = true
                            }) {
                                MeditationCard()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(height: 353)
                    }
                    
                    // Bottom Awareness card (full width)
                    NavigationLink(destination: CategoryExerciseListView(category: .awareness)) {
                        AwarenessCard()
                            .frame(height: 220)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))
        }
        .fullScreenCover(isPresented: $showMeditation) {
            MeditationView()
        }
    }
}

// MARK: - Individual Card Views

struct ReflectCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reflect")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Process your experiences and emotions")
                .font(.caption2)
                .foregroundColor(.gray2)
                .italic()
                .multilineTextAlignment(.leading)
                .padding(.trailing)
            
            Spacer()
            
            // Meditation figure icon
            HStack {
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .yellow, radius: 15, x: 0, y: 0)
                    .shadow(color: .yellow.opacity(0.8), radius: 30, x: 0, y: 0)
                    .shadow(color: .yellow.opacity(0.6), radius: 45, x: 0, y: 0)
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.purpleCarolite.opacity(0.9), Color.afterBurn.opacity(1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

struct BalanceCard: View {
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Balance")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Simple actions that create order and stability")
                    .font(.caption2)
                    .foregroundColor(.gray2)
                    .italic()
                    .multilineTextAlignment(.leading)
            
                Spacer()
            }
            .padding(20)
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [Color.purpleCarolite.opacity(0.9), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

struct MeditationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Meditation")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Longer sessions to give your mind a real break")
                .font(.caption2)
                .foregroundColor(.gray2)
                .italic()
                .multilineTextAlignment(.leading)
                .padding(.trailing)

            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.purpleCarolite.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

struct AwarenessCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Awareness")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Mindful moments to connect with your mind and body")
                    .font(.caption2)
                    .foregroundColor(.gray2)
                    .italic()
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 40)
                
                Spacer()
            }
            
            Spacer()
            
            // Meditation figure icon
            VStack {
                Spacer()
                Image(systemName: "figure.mind.and.body")
                    .font(.system(size: 120))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .yellow, radius: 15, x: 0, y: 0)
                    .shadow(color: .yellow.opacity(0.8), radius: 30, x: 0, y: 0)
                    .shadow(color: .yellow.opacity(0.6), radius: 45, x: 0, y: 0)
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.purpleCarolite.opacity(0.8), Color.afterBurn.opacity(1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

#Preview {
    LibraryView()
} 
