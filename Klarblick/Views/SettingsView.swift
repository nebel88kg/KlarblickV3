//
//  SettingsView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 04.07.25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var userName: String = ""
    @State private var showingNameEditor = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                ZStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.ambrosiaIvory)
                        }
                        
                        Spacer()
                    }
                }
                
                // Settings Content
                VStack(spacing: 20) {
                    // Profile Settings
                    VStack(spacing: 16) {
                        HStack {
                            Text("Profile")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ambrosiaIvory)
                            Spacer()
                        }
                        
                        // Edit Name
                        Button(action: { showingNameEditor = true }) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                                    .foregroundColor(.wildMaple)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Edit Name")
                                        .font(.body)
                                        .foregroundColor(.ambrosiaIvory)
                                    
                                    Text(users.first?.name ?? "User")
                                        .font(.caption)
                                        .foregroundColor(.wildMaple)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.wildMaple)
                            }
                            .padding(16)
                            .background(Color.backgroundSecondary.opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                    
                    // App Settings
                    VStack(spacing: 16) {
                        HStack {
                            Text("App")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ambrosiaIvory)
                            Spacer()
                        }
                        
                        // Notifications
                        HStack {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(.wildMaple)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notifications")
                                    .font(.body)
                                    .foregroundColor(.ambrosiaIvory)
                                
                                Text("Daily reminders")
                                    .font(.caption)
                                    .foregroundColor(.wildMaple)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: .constant(true))
                                .tint(.wildMaple)
                        }
                        .padding(16)
                        .background(Color.backgroundSecondary.opacity(0.3))
                        .cornerRadius(12)
                    }
                    
                    // About Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("About")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.ambrosiaIvory)
                            Spacer()
                        }
                        
                        // Version Info
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.wildMaple)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("App Version")
                                    .font(.body)
                                    .foregroundColor(.ambrosiaIvory)
                                
                                Text("1.0.0")
                                    .font(.caption)
                                    .foregroundColor(.wildMaple)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.backgroundSecondary.opacity(0.3))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingNameEditor) {
            NameEditorView(userName: $userName)
        }
        .onAppear {
            userName = users.first?.name ?? ""
        }
    }
}

struct NameEditorView: View {
    @Binding var userName: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Edit Your Name")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.ambrosiaIvory)
                    .padding(.top, 20)
                
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(16)
                    .background(Color.backgroundSecondary.opacity(0.3))
                    .cornerRadius(12)
                    .foregroundColor(.ambrosiaIvory)
                
                Button(action: saveUserName) {
                    Text("Save")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.afterBurn)
                        .cornerRadius(12)
                }
                .disabled(userName.isEmpty)
                
                Spacer()
            }
            .padding(20)
            .background(RadialGradient(
                colors: [Color.backgroundSecondary.opacity(1), Color.purpleCarolite.opacity(1)],
                center: .bottom,
                startRadius: 100,
                endRadius: 900
            ))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.ambrosiaIvory)
                }
            }
        }
    }
    
    private func saveUserName() {
        if let user = users.first {
            user.name = userName
        } else {
            let newUser = User(name: userName)
            modelContext.insert(newUser)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // Handle save errors
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [User.self, MoodEntry.self, Badge.self])
} 
