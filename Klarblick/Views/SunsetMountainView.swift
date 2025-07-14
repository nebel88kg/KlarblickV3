//
//  SunsetMountainView.swift
//  Klarblick
//
//  Created by Assistant on 01.07.25.
//

import SwiftUI

struct SunsetMountainView: View {
    @State private var cloudOffset1: CGFloat = -100
    @State private var cloudOffset2: CGFloat = -500
    @State private var cloudOffset3: CGFloat = -250
    @State private var birdOffset1: CGFloat = -150
    @State private var birdOffset2: CGFloat = -100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient Sky Background
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.8, blue: 0.6), // Light peach
                        Color(red: 1.0, green: 0.6, blue: 0.7), // Coral pink
                        Color(red: 0.9, green: 0.4, blue: 0.6), // Rose
                        Color(red: 0.7, green: 0.3, blue: 0.8), // Purple
                        Color(red: 0.4, green: 0.2, blue: 0.6)  // Dark purple
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                
                
                // Mountain Layers (back to front)
                MountainLayer(color: Color.purple.opacity(0.5))
                    .offset(x: 150, y: geometry.size.height * 0.3)

                
                MountainLayer(color: Color.purpleCarolite.opacity(1))
                    .offset(x: -180, y: geometry.size.height * 0.5)
                
                // Clouds
                CloudShape()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 120, height: 40)
                    .offset(x: cloudOffset1, y: geometry.size.height * -0.15)
                
                CloudShape()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 80, height: 25)
                    .offset(x: cloudOffset2, y: geometry.size.height * -0.25)
                
                CloudShape()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 100, height: 30)
                    .offset(x: cloudOffset3, y: geometry.size.height * -0.35)
                
                // Flying Birds
                BirdShape()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 20, height: 8)
                    .offset(x: birdOffset1, y: geometry.size.height * -0.2)
                
                BirdShape()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 15, height: 6)
                    .offset(x: birdOffset2, y: geometry.size.height * -0.3)

            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Cloud animations
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            cloudOffset1 = UIScreen.main.bounds.width + 100
        }
        
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            cloudOffset2 = UIScreen.main.bounds.width + 500
        }
        
        withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
            cloudOffset3 = UIScreen.main.bounds.width + 250
        }
        
        // Bird animations
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            birdOffset1 = UIScreen.main.bounds.width + 50
        }
        
        withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
            birdOffset2 = UIScreen.main.bounds.width + 30
        }
    }
}

// Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create a cloud-like shape with rounded bumps
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.6))
        path.addQuadCurve(to: CGPoint(x: width * 0.4, y: height * 0.2), 
                         control: CGPoint(x: width * 0.2, y: height * 0.2))
        path.addQuadCurve(to: CGPoint(x: width * 0.6, y: height * 0.3), 
                         control: CGPoint(x: width * 0.5, y: height * 0.1))
        path.addQuadCurve(to: CGPoint(x: width * 0.8, y: height * 0.6), 
                         control: CGPoint(x: width * 0.8, y: height * 0.2))
        path.addQuadCurve(to: CGPoint(x: width * 0.2, y: height * 0.6), 
                         control: CGPoint(x: width * 0.5, y: height * 0.8))
        
        return path
    }
}

// Bird Shape (simple V shape)
struct BirdShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Left wing
        path.move(to: CGPoint(x: 0, y: height * 0.3))
        path.addLine(to: CGPoint(x: width * 0.4, y: 0))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.2))
        
        // Right wing
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.2))
        path.addLine(to: CGPoint(x: width * 0.6, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.3))
        
        return path
    }
}

// Mountain Layer
struct MountainLayer: View {
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                path.move(to: CGPoint(x: -150, y: height * 0.9))
                path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.4))
                path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.3))
                path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.17))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.15))
                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.1))
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.13))
                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.25))
                path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.28))
                path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.4))
                path.addLine(to: CGPoint(x: width * 1.6, y: height))
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

#Preview {
    SunsetMountainView()
} 
