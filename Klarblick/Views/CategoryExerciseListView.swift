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
    @State private var pressedExerciseId: UUID? = nil
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
                            performHapticFeedback(.medium)
                            selectedExercise = exercise
                        }) {
                            CategoryExerciseCardView(exercise: exercise)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .scaleEffect(pressedExerciseId == exercise.id ? 0.95 : 1.0)
                        .shadow(color: .black.opacity(0.2), radius: pressedExerciseId == exercise.id ? 2 : 5, x: 0, y: pressedExerciseId == exercise.id ? 1 : 2)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressedExerciseId)
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                pressedExerciseId = pressing ? exercise.id : nil
                            }
                        }, perform: {})
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
    
    private func performHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    NavigationView {
        CategoryExerciseListView(category: .awareness)
    }
} 
