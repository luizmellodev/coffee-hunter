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
    @State private var showRandomPicker = false
    @State private var showCoffeeRoute = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CoffeeMapView(viewModel: viewModel)
                VStack(spacing: 0) {
                    Spacer()
                    if !viewModel.coffeeShops.isEmpty {
                        MapBottomTabView(viewModel: viewModel)
                            .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Find Cafes")
        }
    }
}
