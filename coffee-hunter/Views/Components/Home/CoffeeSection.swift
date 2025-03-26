//
//  CoffeeSection.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 26/03/25.
//


import SwiftUI

struct CoffeeSection: View {
    let title: String
    let icon: String
    let shops: any Sequence<CoffeeShop>
    let viewModel: CoffeeHunterViewModel
    @Binding var showAll: Bool
    let allShops: any Sequence<CoffeeShop>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.brown)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Button("See All") {
                    showAll = true
                }
                .font(.subheadline)
                .foregroundColor(.brown)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(shops)) { shop in
                        CoffeeCard(shop: shop, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showAll) {
            NavigationView {
                List(Array(allShops)) { shop in
                    CoffeeListItem(showAll: $showAll, shop: shop, viewModel: viewModel)
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showAll = false
                        }
                    }
                }
            }
        }
    }
}
