//
//  MainView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showPaywall = false
    
    var body: some View {
        TabView {
            Group{
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                    }
                
                LibraryView()
                    .tabItem {
                        Image(systemName: "tray.fill")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                    }
            }
            .toolbarBackground(Color.tabBarBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
        .accentColor(.ambrosiaIvory)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(subscriptionManager)
                .interactiveDismissDisabled(true)
                .presentationDragIndicator(.hidden)
        }
        .onAppear {
            // Show paywall if not subscribed
            if !subscriptionManager.isSubscribed {
                showPaywall = true
            }
        }
        .onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
            if !isSubscribed {
                showPaywall = true
            } else {
                showPaywall = false
            }
        }
    }
}


#Preview {
    MainView()
    .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
    .environmentObject(SubscriptionManager())
}
