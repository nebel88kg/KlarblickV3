//
//  BadgeNotificationView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 05.07.25.
//

import SwiftUI

struct BadgeNotificationView: View {
    let badges: [Badge]
    @Binding var isShowing: Bool
    @State private var animationOffset: CGFloat = -200
    @State private var animationOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.5
    @State private var backgroundScale: CGFloat = 0.8
    
    var body: some View {
        if isShowing {
            ZStack {
                // Background overlay
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: isShowing)
                
                VStack(spacing: 20) {
                    ForEach(badges, id: \.id) { badge in
                        BadgeCard(badge: badge)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.backgroundSecondary)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .scaleEffect(backgroundScale)
                .offset(y: animationOffset)
                .opacity(animationOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                        animationOffset = 0
                        animationOpacity = 1
                        backgroundScale = 1.0
                    }
                    
                    // Auto-dismiss after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        dismissNotification()
                    }
                }
                .onTapGesture {
                    dismissNotification()
                }
            }
        }
    }
    
    private func dismissNotification() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
            animationOffset = -200
            animationOpacity = 0
            backgroundScale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    @State private var iconScale: CGFloat = 0.5
    @State private var sparkleOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge icon with celebration effect
            ZStack {
                // Background glow
                Circle()
                    .fill(rarityColor.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .scaleEffect(iconScale * 1.2)
                    .opacity(sparkleOpacity)
                
                // Main icon background
                Circle()
                    .fill(rarityColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                // Icon
                Image(systemName: badge.iconName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(rarityColor)
                    .scaleEffect(iconScale)
            }
            
            // Badge details
            VStack(spacing: 4) {
                // "Badge Earned!" text
                Text("Badge Earned!")
                    .font(.caption)
                    .foregroundColor(.wildMaple)
                    .opacity(0.8)
                
                // Badge name
                Text(badge.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.center)
                
                // Badge description
                Text(badge.badgeDescription)
                    .font(.caption)
                    .foregroundColor(.gray2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                // Rarity indicator
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(rarityColor)
                    
                    Text(badge.rarity.capitalized)
                        .font(.caption2)
                        .foregroundColor(rarityColor)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(rarityColor.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backgroundSecondary.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(rarityColor.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            // Animate icon appearance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0).delay(0.2)) {
                iconScale = 1.0
            }
            
            // Animate sparkle effect
            withAnimation(.easeInOut(duration: 1.0).delay(0.4)) {
                sparkleOpacity = 1.0
            }
            
            // Fade out sparkle
            withAnimation(.easeInOut(duration: 0.8).delay(1.2)) {
                sparkleOpacity = 0.0
            }
        }
    }
    
    private var rarityColor: Color {
        switch badge.badgeRarity {
        case .common:
            return .gray
        case .rare:
            return .blue
        case .epic:
            return .purple
        case .legendary:
            return .yellow
        }
    }
}

#Preview {
    BadgeNotificationView(
        badges: [
            Badge(
                id: "test_badge",
                name: "Test Badge",
                description: "This is a test badge for preview",
                category: .streak,
                rarity: .rare,
                iconName: "flame.fill",
                isEarned: true
            )
        ],
        isShowing: .constant(true)
    )
} 