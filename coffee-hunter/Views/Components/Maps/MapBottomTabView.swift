//
//  MapBottomTabView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct MapBottomTabView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Binding var selectedIndex: Int
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(viewModel.sortedCoffeeShopsByDistance) { shop in
                ShopBottomCard(shop: shop)
                    .tag(viewModel.getShopIndex(shop))
            }
        }
        .frame(height: 180)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: selectedIndex) { _, newIndex in
            let sortedShops = viewModel.sortedCoffeeShopsByDistance
            if newIndex < sortedShops.count {
                viewModel.selectedCoffeeShop = sortedShops[newIndex]
            }
        }
    }
}
