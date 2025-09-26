//
//  OnboardingPage.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct OnboardingPage: View {
    let title: String
    let description: String
    let imageName: String
    var isLast: Bool = false
    var hasSeenOnboarding: Binding<Bool>?
    let icon: AnyView
    @State private var showContent = false
    
    init(
        title: String,
        description: String,
        imageName: String,
        isLast: Bool = false,
        hasSeenOnboarding: Binding<Bool>? = nil,
        customIcon: (() -> some View)? = nil
    ) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.isLast = isLast
        self.hasSeenOnboarding = hasSeenOnboarding
        
        if let customIcon = customIcon {
            self.icon = AnyView(customIcon())
        } else {
            self.icon = AnyView(
                Image(systemName: imageName)
                    .font(.system(size: 80))
                    .foregroundColor(.brown)
            )
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top Wave
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 100))
                    path.addCurve(
                        to: CGPoint(x: geometry.size.width, y: 50),
                        control1: CGPoint(x: geometry.size.width * 0.3, y: 150),
                        control2: CGPoint(x: geometry.size.width * 0.7, y: 0)
                    )
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                }
                .fill(
                    LinearGradient(
                        colors: [Color.brown.opacity(0.2), Color.brown.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                Spacer()
                
                // Content
                VStack(spacing: 30) {
                    icon
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)
                    
                    VStack(spacing: 16) {
                        Text(title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .offset(y: showContent ? 0 : 20)
                            .opacity(showContent ? 1 : 0)
                        
                        Text(description)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                            .offset(y: showContent ? 0 : 15)
                            .opacity(showContent ? 1 : 0)
                    }
                    
                    if isLast {
                        startButton
                            .offset(y: showContent ? 0 : 30)
                            .opacity(showContent ? 1 : 0)
                    }
                }
                .padding(.bottom, 100)
                
                Spacer()
                
                // Bottom Wave
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - 100))
                    path.addCurve(
                        to: CGPoint(x: geometry.size.width, y: geometry.size.height - 50),
                        control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height - 150),
                        control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height)
                    )
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                }
                .fill(
                    LinearGradient(
                        colors: [Color.brown.opacity(0.1), Color.brown.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            withAnimation {
                hasSeenOnboarding?.wrappedValue = true
            }
        }) {
            Text("Start Hunting")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.brown, .brown.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .brown.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .padding(.horizontal, 40)
        .padding(.top, 20)
    }
}
