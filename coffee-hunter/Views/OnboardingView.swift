//
//  OnboardingView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPage(
                title: "Welcome to Cafeza App!",
                description: "Your journey to discover amazing cafés begins. Get ready for a delightful adventure!",
                imageName: "cup.and.saucer.fill",
                customIcon: {
                    ZStack {
                        Circle()
                            .fill(.brown.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.brown)
                            .symbolEffect(.pulse.byLayer, options: .repeating)
                    }
                }
            )
            .tag(0)
            
            OnboardingPage(
                title: "Discover & Track",
                description: "Find the best coffee spots around and keep track of your coffee adventures.",
                imageName: "map.fill",
                customIcon: {
                    ZStack {
                        Circle()
                            .fill(.brown.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.brown)
                    }
                }
            )
            .tag(1)
            
            OnboardingPage(
                title: "Earn Achievements",
                description: "Become a true Coffee Hunter! Collect badges and unlock special rewards.",
                imageName: "trophy.fill",
                isLast: true,
                hasSeenOnboarding: $hasSeenOnboarding,
                customIcon: {
                    ZStack {
                        Circle()
                            .fill(.brown.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 35))
                                .foregroundStyle(.brown)
                                .symbolEffect(.pulse, options: .repeating)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.brown)
                                        .opacity(currentPage == 2 ? 1 : 0)
                                        .scaleEffect(currentPage == 2 ? 1 : 0.5)
                                        .animation(.easeInOut.delay(Double(index) * 0.1), value: currentPage)
                                }
                            }
                        }
                    }
                }
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
