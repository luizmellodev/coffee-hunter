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
                title: "Welcome to\nCoffee Hunter",
                description: "Your journey to discover amazing cafés begins. Get ready for a delightful adventure!",
                imageName: "cup.and.saucer.fill",
                customIcon: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.brown.opacity(0.2), .brown.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.brown, .brown.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .symbolEffect(.bounce, options: .repeating)
                        
                        Circle()
                            .strokeBorder(Color.brown.opacity(0.2), lineWidth: 2)
                            .frame(width: 120, height: 120)
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
                            .fill(
                                LinearGradient(
                                    colors: [.brown.opacity(0.2), .brown.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        ZStack {
                            Image(systemName: "map.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.brown, .brown.opacity(0.7)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.brown)
                                .offset(x: 15, y: -15)
                                .symbolEffect(.bounce, options: .repeating)
                        }
                        
                        Circle()
                            .strokeBorder(Color.brown.opacity(0.2), lineWidth: 2)
                            .frame(width: 120, height: 120)
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
                            .fill(
                                LinearGradient(
                                    colors: [.brown.opacity(0.2), .brown.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 45))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.brown, .brown.opacity(0.7)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .symbolEffect(.bounce, options: .repeating)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.brown)
                                        .symbolEffect(.bounce, options: .repeating)
                                        .opacity(currentPage == 2 ? 1 : 0)
                                        .animation(.easeInOut.delay(Double(index) * 0.1), value: currentPage)
                                }
                            }
                        }
                        
                        Circle()
                            .strokeBorder(Color.brown.opacity(0.2), lineWidth: 2)
                            .frame(width: 120, height: 120)
                    }
                }
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
