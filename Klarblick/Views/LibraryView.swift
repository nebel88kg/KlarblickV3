//
//  LibraryView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Library")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("This is the Library view")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Library")
        }
    }
}

#Preview {
    LibraryView()
} 