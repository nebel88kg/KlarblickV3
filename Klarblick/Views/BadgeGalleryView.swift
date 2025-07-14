//
//  BadgeGalleryView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 05.07.25.
//

import SwiftUI
import SwiftData

struct BadgeGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    private var earnedBadges: [Badge] {
        guard let user = users.first else { return [] }
        return user.badges.filter { $0.isEarned }.sorted { lhs, rhs in
            // Sort by earn date (most recent first)
            (lhs.earnedDate ?? Date.distantPast) > (rhs.earnedDate ?? Date.distantPast)
        }
    }
    
    private var unearnedBadges: [Badge] {
        guard let user = users.first else { return [] }
        return user.badges.filter { !$0.isEarned }.sorted { lhs, rhs in
            // Sort by progress (highest first)
            lhs.progress > rhs.progress
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Header stats
                    headerStats
                    
                    // Earned badges section
                    if !earnedBadges.isEmpty {
                        BadgeSection(title: "Earned Badges", badges: earnedBadges, isEarned: true)
                    }
                    
                    // Unearned badges section
                    if !unearnedBadges.isEmpty {
                        BadgeSection(title: "Upcoming Badges", badges: unearnedBadges, isEarned: false)
                    }
                }
                .padding()
            }
            .background(
                RadialGradient(
                    colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                    center: .bottom,
                    startRadius: 100,
                    endRadius: 900
                )
            )
            .navigationTitle("Badge Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.ambrosiaIvory)
                }
            }
        }
    }
    
    private var headerStats: some View {
        VStack(spacing: 12) {
            // Badge count
            Text("\(earnedBadges.count)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.ambrosiaIvory)
            
            Text("Badges Earned")
                .font(.title2)
                .foregroundColor(.wildMaple)
            
            // Progress bar
            if let user = users.first {
                let totalBadges = user.badges.count
                let progress = totalBadges > 0 ? Double(earnedBadges.count) / Double(totalBadges) : 0
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Collection Progress")
                            .font(.caption)
                            .foregroundColor(.gray2)
                        
                        Spacer()
                        
                        Text("\(earnedBadges.count)/\(totalBadges)")
                            .font(.caption)
                            .foregroundColor(.gray2)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.backgroundSecondary)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [Color.afterBurn, Color.pharaohsSeas],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: CGFloat(progress) * geometry.size.width, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.backgroundSecondary.opacity(0.3))
        .cornerRadius(16)
    }
}

struct BadgeSection: View {
    let title: String
    let badges: [Badge]
    let isEarned: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                
                Spacer()
                
                Text("\(badges.count)")
                    .font(.title3)
                    .foregroundColor(.wildMaple)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(badges, id: \.id) { badge in
                    BadgeGalleryCard(badge: badge, isEarned: isEarned)
                }
            }
        }
    }
}

struct BadgeGalleryCard: View {
    let badge: Badge
    let isEarned: Bool
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: {
            showingDetails = true
        }) {
            VStack(spacing: 12) {
                // Badge icon
                ZStack {
                    Circle()
                        .fill(rarityColor.opacity(isEarned ? 0.3 : 0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isEarned ? rarityColor : .gray)
                }
                
                // Badge name
                Text(badge.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isEarned ? .ambrosiaIvory : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Rarity indicator
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(isEarned ? rarityColor : .gray)
                    
                    Text(badge.rarity.capitalized)
                        .font(.caption2)
                        .foregroundColor(isEarned ? rarityColor : .gray)
                }
                
                // Progress indicator for unearned badges
                if !isEarned {
                    VStack(spacing: 4) {
                        Text("Progress: \(badge.progress)/\(targetValue)")
                            .font(.caption2)
                            .foregroundColor(.gray2)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.backgroundSecondary)
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(rarityColor.opacity(0.6))
                                    .frame(width: progressWidth(geometry.size.width), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
                
                // Earned date for earned badges
                if isEarned, let earnedDate = badge.earnedDate {
                    Text("Earned \(earnedDate.formatted(.dateTime.month(.abbreviated).day()))")
                        .font(.caption2)
                        .foregroundColor(.wildMaple)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.backgroundSecondary.opacity(isEarned ? 0.8 : 0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(rarityColor.opacity(isEarned ? 0.6 : 0.2), lineWidth: 1)
                    )
            )
            .opacity(isEarned ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            BadgeDetailView(badge: badge)
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
    
    private var targetValue: Int {
        let definition = BadgeManager.shared.getBadgeDefinition(by: badge.id)
        
        switch definition?.requirement {
        case .streak(let target):
            return target
        case .totalXP(let target):
            return target
        case .categoryCount(_, let target):
            return target
        case .moodStreak(let target):
            return target
        case .moodVariety(let target):
            return target
        case .perfectDay:
            return 1
        case .none:
            return 0
        }
    }
    
    private func progressWidth(_ maxWidth: CGFloat) -> CGFloat {
        let target = targetValue
        if target == 0 { return 0 }
        let progress = Double(badge.progress) / Double(target)
        return CGFloat(progress) * maxWidth
    }
}

struct BadgeDetailView: View {
    let badge: Badge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // Large badge icon
                ZStack {
                    Circle()
                        .fill(rarityColor.opacity(0.3))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: badge.iconName)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(rarityColor)
                }
                
                // Badge details
                VStack(spacing: 16) {
                    Text(badge.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                        .multilineTextAlignment(.center)
                    
                    Text(badge.badgeDescription)
                        .font(.body)
                        .foregroundColor(.gray2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Rarity
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(rarityColor)
                        
                        Text(badge.rarity.capitalized)
                            .font(.headline)
                            .foregroundColor(rarityColor)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(rarityColor.opacity(0.2))
                    .cornerRadius(12)
                    
                    // Earned status
                    if badge.isEarned, let earnedDate = badge.earnedDate {
                        VStack(spacing: 4) {
                            Text("Earned on")
                                .font(.caption)
                                .foregroundColor(.wildMaple)
                            
                            Text(earnedDate.formatted(.dateTime.month(.wide).day().year()))
                                .font(.subheadline)
                                .foregroundColor(.ambrosiaIvory)
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RadialGradient(
                    colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                    center: .bottom,
                    startRadius: 100,
                    endRadius: 900
                )
            )
            .navigationTitle("Badge Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.ambrosiaIvory)
                }
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
    BadgeGalleryView()
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
} 
