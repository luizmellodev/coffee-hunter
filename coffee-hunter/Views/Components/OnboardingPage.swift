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
        VStack(spacing: 20) {
            
            icon
            
            Text(title)
                .font(.title)
                .bold()
            
            Text(description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if isLast {
                Button(action: {
                    hasSeenOnboarding?.wrappedValue = true
                }) {
                    Text("Start Hunting")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.brown, .brown.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 40)
            }
            
            Spacer()
                .frame(height: 60)
        }
        .padding()
    }
}
