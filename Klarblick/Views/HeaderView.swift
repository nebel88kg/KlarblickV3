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
        .padding(20)
    }
}

#Preview {
    HeaderView()
        .padding()
        .background(Color.backgroundSecondary)
}
