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
        .onAppear {
            viewModel.startLocationUpdates()
        }
        .onReceive(viewModel.locationManager.$userLocation) { location in
            if location != nil {
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
