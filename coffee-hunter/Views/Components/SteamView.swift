//
//  SteamView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//


import SwiftUI

struct SteamView: View {
    let offset: CGFloat
    @State private var animating = false
    
    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 20, height: 20)
            .offset(x: offset, y: animating ? -50 : -30)
            .animation(
                Animation
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...0.5)),
                value: animating
            )
            .onAppear {
                animating = true
            }
    }
}