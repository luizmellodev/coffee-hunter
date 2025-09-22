//
//  OnboardingView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    
    var body: some View {
        TabView {
            OnboardingPage(
                title: "Welcome Coffee Hunter",
                description: "Your quest for the perfect cup begins here",
                imageName: "arrow.through.heart.fill",
                customIcon: {
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 60))
                        Image(systemName: "arrow.through.heart.fill")
                            .font(.system(size: 40))
                    }
                }
            )
            
            OnboardingPage(
                title: "Track Your Hunts",
                description: "Mark conquered coffee spots and rate your discoveries",
                imageName: "map.fill",
                customIcon: {
                    ZStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 70))
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 30))
                            .offset(x: 10, y: -10)
                    }
                    .foregroundColor(.brown)
                }
            )
            
            OnboardingPage(
                title: "Become a Legend",
                description: "Build your collection of conquered cafes",
                imageName: "trophy.fill",
                isLast: true,
                hasSeenOnboarding: $hasSeenOnboarding,
                customIcon: {
                    VStack {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                        HStack(spacing: 8) {
                            ForEach(0..<3) { _ in
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .foregroundColor(.brown)
                }
            )
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
