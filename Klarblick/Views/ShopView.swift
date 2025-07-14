//
//  ShopView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 04.07.25.
//

import SwiftUI
import SwiftData

struct ShopView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    var body: some View {
        let user = users.first

        NavigationView {
            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text("Shop")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.ambrosiaIvory)
                        }
                        
                        Spacer()
                        
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Scrollable Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                    // My Items Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("My Items")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ambrosiaIvory)
                            Spacer()
                        }
                        
                        // Horizontal Slider
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                // Sample Items
                                ShopItemCard(
                                    imageName: "snowflake",
                                    itemName: "Streak Freeze",
                                    itemCount: 3,
                                    iconColor: .cyan
                                )
                                
                                ShopItemCard(
                                    imageName: "bolt.fill",
                                    itemName: "XP Boost",
                                    itemCount: 1,
                                    iconColor: .orange
                                )
                                
                                ShopItemCard(
                                    imageName: "shield.fill",
                                    itemName: "Streak Shield",
                                    itemCount: 0,
                                    iconColor: .green
                                )
                                
                                ShopItemCard(
                                    imageName: "clock.arrow.circlepath",
                                    itemName: "Time Warp",
                                    itemCount: 2,
                                    iconColor: .purple
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, -20)
                    }
                        
                        // Streak Protection Category
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Streak Protection")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ambrosiaIvory)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            HorizontalItemCard(
                                imageName: "snowflake",
                                itemName: "1-day",
                                price: 325,
                                available: true,
                                iconColor: .cyan
                            )
                            
                            HorizontalItemCard(
                                imageName: "snowflake",
                                itemName: "2-day",
                                price: 650,
                                available: false,
                                iconColor: .green
                            )
                        }
                    }

                    
                    // XP Boosters Category
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("XP Boosters")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ambrosiaIvory)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            HorizontalItemCard(
                                imageName: "bolt.fill",
                                itemName: "XP Boost",
                                price: 50,
                                available: true,
                                iconColor: .orange
                            )
                            
                            HorizontalItemCard(
                                imageName: "star.fill",
                                itemName: "XP Multiplier",
                                price: 120,
                                available: true,
                                iconColor: .yellow
                            )
                        }
                    }
                                        
                    // Time Manipulation Category
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Time Manipulation")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ambrosiaIvory)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            HorizontalItemCard(
                                imageName: "clock.arrow.circlepath",
                                itemName: "Time Warp",
                                price: 200,
                                available: true,
                                iconColor: .purple
                            )
                            
                            HorizontalItemCard(
                                imageName: "hourglass.tophalf.filled",
                                itemName: "Time Extender",
                                price: 180,
                                available: true,
                                iconColor: .blue
                            )
                        }
                    }
                    
                    // Power Items Category
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Power Items")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ambrosiaIvory)
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            HorizontalItemCard(
                                imageName: "flame.fill",
                                itemName: "Energy Burst",
                                price: 80,
                                available: true,
                                iconColor: .red
                            )
                            
                            HorizontalItemCard(
                                imageName: "sparkles",
                                itemName: "Magic Booster",
                                price: 250,
                                available: false,
                                iconColor: .pink
                            )
                        }
                    }
                    
                    // Bottom padding for scroll content
                    Spacer()
                        .frame(height: 50)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(RadialGradient(
            colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
            center: .bottom,
            startRadius: 100,
            endRadius: 900
        ))
        }
        .navigationBarHidden(true)
    }
}

struct HorizontalItemCard: View {
    let imageName: String
    let itemName: String
    let price: Int
    let available: Bool
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: imageName)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(available ? iconColor : Color.gray)
                .frame(width: 50, height: 50)
            
            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                Text(itemName)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(available ? .ambrosiaIvory : Color.gray)
            }
            
            Spacer()
            
            // Purchase Button
            Button(action: {
                // Purchase action
            }) {
                HStack(spacing: 4) {
                    Text("\(price)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(available ? .pharaohsSeas : Color.gray)
                    
                    Image(systemName: "suit.diamond.fill")
                        .foregroundColor(available ? .pharaohsSeas : Color.gray)
                        .font(.caption)
                }
            }
            .disabled(!available)
        }
        .frame(maxWidth: .infinity, maxHeight: 82)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundSecondary.opacity(0.2))
                .strokeBorder(available ? Color.mangosteenViolet : Color.gray, lineWidth: 1)
        )
    }
}

struct ShopItemCard: View {
    let imageName: String
    let itemName: String
    let itemCount: Int
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Logo
            Image(systemName: imageName)
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(iconColor)
                .frame(width: 60, height: 60)
            
            // Item Name
            Text(itemName)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.ambrosiaIvory)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
                        // Item Count

            Text("x\(itemCount)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(itemCount == 0 ? .red : .pharaohsSeas)

            
        }
        .frame(width: 157, height: 169)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.backgroundSecondary.opacity(0.2))
                .strokeBorder(Color.mangosteenViolet, lineWidth: 2)
        )
        
    }
}

#Preview {
    ShopView()
        .background(Color.backgroundSecondary)
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
} 
