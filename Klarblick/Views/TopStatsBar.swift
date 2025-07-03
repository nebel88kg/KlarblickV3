//
//  TopStatsBar.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct TopStatsBar: View {
    let streakCount: Int
    let xpCount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Streak Counter (Left)
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.afterBurn)
                        .font(.body)
                    
                        Text("\(streakCount)")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.afterBurn)
                }
                
                Spacer()
                
                // XP Counter (Right)
                HStack(spacing: 8) {
                    Text("\(xpCount)")
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
    TopStatsBar(streakCount: 7, xpCount: 1250)
        .background(Color.backgroundSecondary)
} 
