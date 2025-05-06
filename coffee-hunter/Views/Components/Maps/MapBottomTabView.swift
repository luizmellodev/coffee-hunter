//
//  MapBottomTabView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//


import SwiftUI

//struct MapBottomTabView: View {
//    @ObservedObject var viewModel: CoffeeHunterViewModel
//    @Binding var selectedIndex: Int
//    
//    var body: some View {
//        TabView(selection: $selectedIndex) {
//            ForEach(viewModel.coffeeShopService.coffeeShops
//                .sorted { $0.distance < $1.distance }
//            ) { shop in
//                ShopBottomCard(shop: shop)
//                    .tag(viewModel.coffeeShopService.coffeeShops.sorted { $0.distance < $1.distance }.firstIndex(of: shop) ?? 0)
//            }
//        }
//        .frame(height: 180)
//        .tabViewStyle(.page(indexDisplayMode: .never))
//        .onChange(of: selectedIndex) { _, newIndex in
//            let sortedShops = viewModel.coffeeShopService.coffeeShops.sorted { $0.distance < $1.distance }
//            if newIndex < sortedShops.count {
//                let shop = sortedShops[newIndex]
//                viewModel.selectedCoffeeShop = shop
//            }
//        }
//    }
//}
