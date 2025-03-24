//
//  LoadingView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//


import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var steamOpacity = 0.0
    @State private var coffeeFill = 0.0
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Coffee cup
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.brown)
                
                // Steam
                ForEach(0..<3) { i in
                    SteamView(offset: CGFloat(i * 10))
                        .opacity(steamOpacity)
                }
                
                // Coffee fill animation
                Rectangle()
                    .fill(Color.brown)
                    .frame(width: 60, height: 60 * coffeeFill)
                    .offset(y: 30 * (1 - coffeeFill))
                    .mask(
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 80))
                    )
            }
            
            Text("Brewing your coffee shops...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
            ) {
                steamOpacity = 0.6
            }
            
            withAnimation(
                Animation
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                coffeeFill = 1.0
            }
        }
    }
}
