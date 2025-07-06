//
//  HomeView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                TopStatsBar()
                
                HeaderView()

                MoodEmojiSelector()
                
                HStack() {
                    Text("Today's Exercises")
                        .font(.title)
                        .foregroundColor(.ambrosiaIvory)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                HStack() {
                    VerticalProgressBarView(progress: 0.6, height: 277)
                        .padding(.leading, 15)
                        .padding(.trailing, 7)
                    ExerciseCardView()
                        .padding(.trailing, 20)
                }

                
                Spacer()
            }
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))

        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
}
