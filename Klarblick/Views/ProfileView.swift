//
//  ProfileView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Your Progress")
                .font(.largeTitle)

            // Placeholder data
            Text("XP: 100")
            Text("Level: 2")
            Text("Streak: 5 days")
        }
    }
}


#Preview {
    ProfileView()
} 
