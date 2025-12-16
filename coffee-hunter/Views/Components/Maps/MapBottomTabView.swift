//
//  MapBottomTabView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct MapBottomTabView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedCoffeeShop) {
            ForEach(viewModel.sortedCoffeeShopsByDistance) { shop in
                ShopBottomCard(shop: shop)
                    .tag(shop as CoffeeShop?)
            }
        }
        .frame(height: 180)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
