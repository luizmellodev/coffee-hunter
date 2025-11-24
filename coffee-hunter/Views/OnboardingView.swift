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
    
    private let totalPages = 7
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                // Page 0: Welcome + Site
                welcomePage.tag(0)
                
                // Page 1: Coffee of the Day
                dailyCoffeePage.tag(1)
                
                // Page 2: Discover & Track
                discoverPage.tag(2)
                
                // Page 3: Streak
                streakPage.tag(3)
                
                // Page 4: Tours
                toursPage.tag(4)
                
                // Page 5: Guides
                guidesPage.tag(5)
                
                // Page 6: Final CTA
                finalPage.tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Skip button
            VStack {
                HStack {
                    Spacer()
                    
                    if currentPage < totalPages - 1 {
                        Button {
                            hasSeenOnboarding = true
                        } label: {
                            Text("Skip")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    // MARK: - Pages
    
    private var welcomePage: some View {
        OnboardingPage(
            title: "Welcome to Cafeza! ☕️",
            description: "The perfect app to discover specialty coffee shops and track your coffee journey.\n\n💚 Companion to cafeza.club",
            imageName: "cup.and.saucer.fill",
            customIcon: {
                VStack(spacing: 20) {
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
                            .foregroundStyle(.brown)
                            .symbolEffect(.pulse.byLayer, options: .repeating)
                    }
                    
                    // Website badge
                    Link(destination: URL(string: "https://cafeza.club")!) {
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                                .font(.caption)
                            Text("cafeza.club")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.up.right")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
            }
        )
    }
    
    private var dailyCoffeePage: some View {
        OnboardingPage(
            title: "☀️ Coffee of the Day",
            description: "Every day a new special recommendation! Discover amazing coffee shops randomly.",
            imageName: "sun.max.fill",
            customIcon: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .yellow.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 45))
                            .foregroundStyle(.orange)
                            .symbolEffect(.pulse, options: .repeating)
                        
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 25))
                            .foregroundStyle(.brown)
                    }
                }
            }
        )
    }
    
    private var discoverPage: some View {
        OnboardingPage(
            title: "🗺️ Discover & Track",
            description: "Find specialty coffee shops near you and track all your visits.",
            imageName: "map.fill",
            customIcon: {
                ZStack {
                    Circle()
                        .fill(.brown.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.brown)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundStyle(.pink)
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
        )
    }
    
    private var streakPage: some View {
        OnboardingPage(
            title: "🔥 Keep Your Streak",
            description: "Visit coffee shops daily and build an amazing streak! Unlock exclusive badges.",
            imageName: "flame.fill",
            customIcon: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse, options: .repeating)
                        
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
        )
    }
    
    private var toursPage: some View {
        OnboardingPage(
            title: "🚶 Curated Tours",
            description: "Explore special routes in Porto Alegre and Curitiba! 1 to 3-hour tours through the best coffee shops.",
            imageName: "figure.walk",
            customIcon: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.2), .blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                        }
                        
                        Text("POA • CWB")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.brown)
                    }
                }
            }
        )
    }
    
    private var guidesPage: some View {
        OnboardingPage(
            title: "📚 Expert Guides",
            description: "Access guides about specialty coffee, equipment, brewing methods and more!\n\n✨ Free and premium content available",
            imageName: "book.fill",
            customIcon: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.2), .brown.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 10) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.brown)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text("Free + Premium")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.brown)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }
            }
        )
    }
    
    private var finalPage: some View {
        OnboardingPage(
            title: "All Set! 🎉",
            description: "Start your specialty coffee journey right now.\n\n💡 Visit cafeza.club for more free content!",
            imageName: "checkmark.circle.fill",
            isLast: true,
            hasSeenOnboarding: $hasSeenOnboarding,
            customIcon: {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.3), .green.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                            .symbolEffect(.bounce, options: .repeating)
                    }
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(.orange)
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.red)
                            Image(systemName: "map.fill")
                                .foregroundStyle(.blue)
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                            Image(systemName: "book.fill")
                                .foregroundStyle(.brown)
                        }
                        .font(.title3)
                        
                        Text("Everything in one place")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        )
    }
}
