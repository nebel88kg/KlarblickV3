//
//  ExerciseCardView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct ExerciseCard {
    let title: String
    let caption: String
    let symbol: String
    let gradient: LinearGradient
}

struct ExerciseCardView: View {
    private let exercises = [
        ExerciseCard(
            title: "Awareness",
            caption: "Mindful moments to connect with your mind and body",
            symbol: "eye.fill",
            gradient: LinearGradient(
                colors: [Color.purpleCarolite, Color.afterBurn.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        ),
        ExerciseCard(
            title: "Balance",
            caption: "Simple actions that create order and stability",
            symbol: "scale.3d",
            gradient: LinearGradient(
                colors: [Color.purpleCarolite, Color.afterBurn.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        ),
        ExerciseCard(
            title: "Reflect",
            caption: "Process your experiences and emotions",
            symbol: "brain.head.profile",
            gradient: LinearGradient(
                colors: [Color.purpleCarolite, Color.afterBurn.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(exercises.indices, id: \.self) { index in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercises[index].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.ambrosiaIvory)
                        
                        Text(exercises[index].caption)
                            .font(.caption2)
                            .italic()
                            .foregroundColor(.gray2)
                    }
                    .padding(.trailing, 85)
                    
                    Spacer()
                    
                    Image(systemName: exercises[index].symbol)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .shadow(color: .yellow.opacity(0.6), radius: 8, x: 0, y: 0)
                        .shadow(color: .yellow.opacity(0.3), radius: 16, x: 0, y: 0)
                }
                .frame(height: 110)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .background(exercises[index].gradient)
                .cornerRadius(20)

            }
        }
    }
}

#Preview {
    ExerciseCardView()
        .padding()
        .padding(.leading, 20)
        .background(Color.gray.opacity(0.1))
} 
