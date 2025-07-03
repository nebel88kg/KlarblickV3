//
//  MoodEmojiSelector.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct MoodEmojiSelector: View {
    @Binding var selectedMood: Int?
    
    private let moods: [(imageName: String, label: String)] = [
        ("smiley1", "Sehr gut"),
        ("smiley2", "Gut"),
        ("smiley3", "Neutral"),
        ("smiley4", "Schlecht"),
        ("smiley5", "Sehr schlecht")
    ]
    
    var body: some View {
        VStack{
            HStack {
                ForEach(0..<moods.count, id: \.self) { index in
                    if index > 0 {
                        Spacer()
                    }
                    MoodPill(
                        imageName: moods[index].imageName,
                        label: moods[index].label,
                        isSelected: selectedMood == index
                    ) {
                        selectedMood = index
                    }
                }
            }
            HStack {
                Text("Very Happy")
                    .font(.caption)
                    .foregroundColor(.wildMaple)
                
                Spacer()
                
                Text("Stressed")
                    .font(.caption)
                    .foregroundColor(.wildMaple)
            }
        }.padding(.horizontal, 20)
    }
}

struct MoodPill: View {
    let imageName: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            .frame(width: 63, height: 86)
            .background(
                RoundedRectangle(cornerRadius: 100)
                    .fill(
                        isSelected ? 
                        LinearGradient(
                            colors: [Color.afterBurn.opacity(0.8), Color.mangosteenViolet.opacity(1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.backgroundSecondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(
                        Color.mangosteenViolet, lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        Text("Mood Selector")
            .font(.title2)
            .fontWeight(.semibold)
        
        MoodEmojiSelector(selectedMood: .constant(2))
        
        Text("No Selection")
            .font(.caption)
            .foregroundColor(.secondary)
        
        MoodEmojiSelector(selectedMood: .constant(nil))
    }
    .padding()
} 
