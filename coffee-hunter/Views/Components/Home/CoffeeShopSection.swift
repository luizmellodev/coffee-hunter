import SwiftUI
import MapKit

struct CoffeeShopSection: View {
    let viewModel: CoffeeHunterViewModel
    let title: String
    let icon: String
    let iconColor: Color
    let shops: [MKMapItem]
    @Binding var showContent: Bool
    @State private var showAll = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
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
                    ForEach(Array(shops.prefix(3)), id: \.self) { shop in
                        CoffeeCard(shop: shop, viewModel: viewModel)
                            .transition(.slide)
                    }
                }
                .padding(.horizontal)
            }
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .sheet(isPresented: $showAll) {
            NavigationView {
                List(shops, id: \.self) { shop in
                    CoffeeListItem(showAll: $showAll, shop: shop, viewModel: viewModel)
                }
                .navigationTitle("\(title)")
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
