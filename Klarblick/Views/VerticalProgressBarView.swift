//
//  VerticalProgressBarView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct VerticalProgressBarView: View {
    let progress: Double // Value between 0.0 and 1.0
    let height: CGFloat
    
    init(progress: Double, height: CGFloat = 200) {
        self.progress = max(0.0, min(1.0, progress)) // Clamp between 0 and 1
        self.height = height
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.backgroundSecondary)
                .frame(width: 10, height: height)
            
            // Progress fill
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color.pharaohsSeas, Color.pharaohsSeas.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 10, height: height * progress)
            
            // White highlight on the left edge
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 3, height: height * progress)
                .offset(x: -2.5) // Position on the left side
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 15) {
            VerticalProgressBarView(progress: 0.2, height: 150)
            VerticalProgressBarView(progress: 0.5, height: 150)
            VerticalProgressBarView(progress: 0.8, height: 150)
            VerticalProgressBarView(progress: 1.0, height: 150)
        }
        
        Text("Vertical Progress Bars")
            .foregroundColor(.ambrosiaIvory)
    }
    .padding()
    .background(
        RadialGradient(
            colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
            center: .bottom,
            startRadius: 10,
            endRadius: 200
        )
    )
} 
