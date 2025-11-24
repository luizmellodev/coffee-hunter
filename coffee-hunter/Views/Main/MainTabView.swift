//
//  MainTabView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    
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
            
            DiscoverView(viewModel: viewModel)
                .tabItem {
                    Label("Discover", systemImage: "star.fill")
                }
                .tag(2)
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .tint(.brown)
    }
}
