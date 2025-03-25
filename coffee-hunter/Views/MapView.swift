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
    @State private var showSearch = false
    @State private var selectedIndex = 0
    @State private var showRandomPicker = false
    @State private var showCoffeeRoute = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CoffeeMapView(viewModel: viewModel, selectedIndex: $selectedIndex)
                
                VStack(spacing: 0) {
                    if showSearch {
                        MapSearchBar(searchText: $searchText, showSearch: $showSearch) { query in
                            searchLocation(query, viewModel: viewModel)
                        }
                        .transition(.move(edge: .top))
                    }
                    
                    Spacer()
                    
                    if !viewModel.coffeeShopService.coffeeShops.isEmpty {
                        HStack {
                            Button(action: { showRandomPicker = true }) {
                                Label("Escolha pra mim", systemImage: "dice")
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: { showCoffeeRoute = true }) {
                                Label("Rota do Café", systemImage: "map")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        
                        MapBottomSheet(viewModel: viewModel, selectedIndex: $selectedIndex)
                            .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Find Cafes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { withAnimation { showSearch.toggle() } }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showRandomPicker) {
                RandomCoffeePickerView(viewModel: viewModel)
            }
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
