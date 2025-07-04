//
//  KlarblickApp.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftData
import SwiftUI

@main
struct KlarblickApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [User.self, MoodEntry.self])
    }
}
