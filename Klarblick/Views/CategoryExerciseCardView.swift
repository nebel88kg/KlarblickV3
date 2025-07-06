//
//  CategoryExerciseCardView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 04.07.25.
//

import SwiftUI

struct CategoryExerciseCardView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.ambrosiaIvory)
                    .multilineTextAlignment(.leading)
                
                Text(exercise.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray2)
                    .italic()
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
            
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    
    private var gradientColors: [Color] {
        switch exercise.category {
        case .awareness:
            return [Color.purpleCarolite.opacity(0.8), Color.afterBurn.opacity(0.6)]
        case .balance:
            return [Color.purpleCarolite.opacity(0.9), Color.purple.opacity(0.7)]
        case .reflect:
            return [Color.purpleCarolite.opacity(0.9), Color.afterBurn.opacity(0.8)]
        }
    }
}

#Preview {
    CategoryExerciseCardView(exercise: ExerciseLibrary.predefinedExercises[0])
        .padding()
        .background(Color.backgroundSecondary)
} 
