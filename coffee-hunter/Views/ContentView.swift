//
//  ContentView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var viewModel = CoffeeHunterViewModel()
    
    var body: some View {
        Group {
            if !appState.hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $appState.hasSeenOnboarding)
            } else if appState.isLoading {
                LoadingView()
            } else {
                MainTabView(viewModel: viewModel)
            }
        }
        .onReceive(viewModel.locationManager.$userLocation) { location in
            if let location = location {
                viewModel.updateLocation(location)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    appState.hasLocation = true
                    appState.isLoading = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
