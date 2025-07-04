//
//  HeaderView.swift
//  Klarblick
//
//  Created by Dominik Nebel on 01.07.25.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 4) {
                Text("Hey there, Dominik!")
                    .font(.title)
                    .fontWeight(.bold)
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
    }
}

#Preview {
    HeaderView()
        .padding()
        .background(Color.backgroundSecondary)
}
