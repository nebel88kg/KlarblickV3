//
//  HeaderView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI
import SwiftData

struct HeaderView: View {
    @Query private var users: [User]
    @State private var currentDate = Date()
    
    private var userName: String {
        return users.first?.name ?? "Default User"
    }
    
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        
        switch hour {
        case 0..<12:
            return String(localized: "Good morning")
        case 12..<17:
            return String(localized: "Good afternoon")
        case 17..<21:
            return String(localized: "Good evening")
        default:
            return String(localized:"Good night")
        }
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 4) {
                Text("\(timeBasedGreeting), \(userName)!")
                    .font(.title)
                    .foregroundColor(.ambrosiaIvory)

                
                Text("How are you feeling today?")
                    .font(.callout)
                    .foregroundColor(.wildMaple)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .padding(.bottom, 10)
        .onAppear {
            updateCurrentDate()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            updateCurrentDate()
        }
    }
    
    private func updateCurrentDate() {
        currentDate = Date()
    }
}

#Preview {
    HeaderView()
        .padding()
        .background(Color.backgroundSecondary)
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
}
