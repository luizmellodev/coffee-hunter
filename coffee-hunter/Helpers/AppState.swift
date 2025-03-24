//
//  AppState.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation

class AppState: ObservableObject {
    @Published var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }
    @Published var isLoading = true
    @Published var hasLocation = false
    
    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
}
