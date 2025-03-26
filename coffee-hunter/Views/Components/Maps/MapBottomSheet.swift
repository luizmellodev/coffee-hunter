//
//  MapBottomSheet.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//


import SwiftUI

struct MapBottomSheet: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @Binding var selectedIndex: Int
    
    var body: some View {
        MapBottomTabView(viewModel: viewModel, selectedIndex: $selectedIndex)
    }
}