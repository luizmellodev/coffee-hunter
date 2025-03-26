//
//  MapView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import MapKit
import CoreLocation
import SwiftUI

struct MapView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @State private var showRandomPicker = false
    @State private var showCoffeeRoute = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CoffeeMapView(viewModel: viewModel, selectedIndex: $selectedIndex)
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    if !viewModel.coffeeShopService.coffeeShops.isEmpty {
                        MapBottomSheet(viewModel: viewModel, selectedIndex: $selectedIndex)
                            .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Find Cafes")
            .sheet(isPresented: $showCoffeeRoute) {
                CoffeeRouteView(viewModel: viewModel)
            }
            .overlay {
                if viewModel.showAchievementAlert,
                   let achievement = viewModel.lastAchievement {
                    AchievementOverlay(mission: achievement)
                        .animation(.easeInOut, value: viewModel.showAchievementAlert)
                }
            }
        }
    }
}
