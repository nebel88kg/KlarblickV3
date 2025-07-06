//
//  TopStatsBar.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData

struct TopStatsBar: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    var body: some View {
        let user = users.first
        
        VStack(spacing: 0) {
            HStack {
                // Streak Counter (Left)
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.afterBurn)
                        .font(.body)
                    
                    Text("\(user?.currentStreak ?? 0)")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.afterBurn)
                }
                
                Spacer()

                // XP Counter (Right)
                HStack(spacing: 8) {
                    Text("\(user?.currentXp ?? 0)")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.pharaohsSeas)
                    
                    Image(systemName: "suit.diamond.fill")
                        .foregroundColor(.pharaohsSeas)
                        .font(.body)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            // Bottom Divider Line
            Rectangle()
                .fill(Color.gray2.opacity(0.3))
                .frame(height: 2)
        }
        .background(Color.backgroundSecondary.opacity(0.3))
    }
}

#Preview {
    TopStatsBar()
        .background(Color.backgroundSecondary)
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
}
