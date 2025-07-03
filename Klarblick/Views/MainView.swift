//
//  MainView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct MainView: View {
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
    }
}


#Preview {
    MainView()
}
