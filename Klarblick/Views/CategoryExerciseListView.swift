//
//  CategoryExerciseListView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 04.07.25.
//

import SwiftUI

struct CategoryExerciseListView: View {
    let category: ExerciseCategory
    let exercises: [Exercise]
    @State private var selectedExercise: Exercise?
    @Environment(\.dismiss) private var dismiss
    
    init(category: ExerciseCategory) {
        self.category = category
        self.exercises = ExerciseLibrary.exercisesByCategory(category)
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.gray2)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.gray2.opacity(0.2))
                        )
                }
                
                Spacer()
                
                Text(category.rawValue)
                    .font(.largeTitle)
                    .foregroundColor(.ambrosiaIvory)
                
                Spacer()
                
                // Empty space for symmetry
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Exercise List
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(exercises) { exercise in
                        Button(action: {
                            selectedExercise = exercise
                        }) {
                            CategoryExerciseCardView(exercise: exercise)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .background(RadialGradient(
            colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
            center: .bottom,
            startRadius: 100,
            endRadius: 900
        ))
        .navigationBarHidden(true)
        .fullScreenCover(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
    }
}

#Preview {
    NavigationView {
        CategoryExerciseListView(category: .awareness)
    }
} 
