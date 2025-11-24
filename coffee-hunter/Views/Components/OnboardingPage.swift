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
        VStack(spacing: 40) {
            Spacer()
            
            icon
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary.opacity(0.9))
                    .offset(y: showContent ? 0 : 10)
                    .opacity(showContent ? 1 : 0)
                    .accessibility(identifier: title)
                
                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
                    .offset(y: showContent ? 0 : 10)
                    .opacity(showContent ? 1 : 0)
                    .accessibilityIdentifier("\(title)Description")
            }
            
            Spacer()
            
            if isLast {
                startButton
                    .offset(y: showContent ? 0 : 20)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.brown
                .opacity(0.05)
                .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showContent = true
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                hasSeenOnboarding?.wrappedValue = true
            }
        }) {
            HStack(spacing: 12) {
                Text("Get Started")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.semibold)
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
            }
            .foregroundColor(.white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.brown, .brown.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .brown.opacity(0.3), radius: 12, x: 0, y: 6)
            .accessibility(identifier: "getStartedButton")
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
        .accessibilityIdentifier("getStartedButton")
    }
}
