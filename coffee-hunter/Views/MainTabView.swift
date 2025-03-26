//
//  MainTabView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var viewModel: CoffeeHunterViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            MapView(viewModel: viewModel)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(1)
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .tint(.brown)
    }
}
