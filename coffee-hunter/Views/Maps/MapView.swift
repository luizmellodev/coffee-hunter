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
            CoffeeMapView(viewModel: viewModel)
                .navigationTitle("Find Cafes")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(action: { showRandomPicker = true }) {
                                Label("Random Coffee", systemImage: "dice")
                            }
                            
                            Button(action: { showCoffeeRoute = true }) {
                                Label("Coffee Route", systemImage: "map")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .sheet(isPresented: $showRandomPicker) {
                    RandomCoffeePickerView(viewModel: viewModel)
                }
                .sheet(isPresented: $showCoffeeRoute) {
                    Text("Coffee Route") // TODO: Implement this view
                }
        }
    }
}
