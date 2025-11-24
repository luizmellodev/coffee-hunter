//
//  DiscoverView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI
import SafariServices

struct DiscoverView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var selectedSegment = 0
    @State private var showingSafari = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Featured cafeza.club button
                    cafezaClubButton
                    
                    // Segmented picker
                    Picker("Content Type", selection: $selectedSegment) {
                        Text("Tours").tag(0)
                        Text("Guides").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content
                    if selectedSegment == 0 {
                        toursSection
                    } else {
                        guidesSection
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Discover")
            .background(Color(.systemBackground))
            .sheet(isPresented: $showingSafari) {
                SafariView(url: URL(string: "https://cafeza.club")!)
            }
        }
    }
    
    private var cafezaClubButton: some View {
        Button {
            showingSafari = true
        } label: {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.brown, Color.brown.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "globe.americas.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Visit cafeza.club")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Much more free content on our website")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.brown)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        Color.brown.opacity(0.15),
                        Color.brown.opacity(0.08)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.brown.opacity(0.3), Color.brown.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .brown.opacity(0.15), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Explore the Coffee World")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Curated tours and specialized guides")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.brown)
            }
        }
        .padding(.horizontal)
    }
    
    private var toursSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Cities list
            ForEach(availableCities) { city in
                NavigationLink(destination: CityToursView(city: city, viewModel: viewModel)) {
                    cityCard(city: city)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Request tour card
            requestTourCard
            
            // Info about supporting the project
            supportInfoCard
        }
        .padding(.horizontal)
    }
    
    private var availableCities: [CoffeeCity] {
        let allTours = viewModel.getAvailableTours()
        let grouped = Dictionary(grouping: allTours, by: { $0.city })
        
        return grouped.map { city, tours in
            CoffeeCity(
                id: city.lowercased().replacingOccurrences(of: " ", with: "-"),
                name: city,
                country: tours.first?.country ?? "Brazil",
                tourCount: tours.count,
                emoji: cityEmoji(for: city)
            )
        }.sorted { $0.name < $1.name }
    }
    
    private func cityEmoji(for city: String) -> String {
        switch city {
        case "Porto Alegre": return "🌆"
        case "Curitiba": return "🌲"
        case "São Paulo": return "🏙️"
        case "Rio de Janeiro": return "🏖️"
        default: return "☕️"
        }
    }
    
    private func cityCard(city: CoffeeCity) -> some View {
        HStack(spacing: 16) {
            // Emoji
            Text(city.emoji)
                .font(.system(size: 50))
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(city.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(city.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "map.fill")
                        .font(.caption)
                    Text("\(city.tourCount) tour\(city.tourCount == 1 ? "" : "s")")
                        .font(.caption)
                }
                .foregroundColor(.brown)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var requestTourCard: some View {
        Button {
            openEmailComposer()
        } label: {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Don't see your city?")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Request a tour for your area")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.12), Color.blue.opacity(0.06)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func openEmailComposer() {
        let email = "contato@luizmello.dev"
        let subject = "New tour for my city!"
        let body = "Hi!\n\nI would love to have a coffee tour in my city.\n\nCity: [Your city name]\nCountry: [Your country]\n\nHere are some amazing specialty coffee shops I recommend:\n\n1. [Coffee shop name] - [Why it's great]\n2. [Coffee shop name] - [Why it's great]\n3. [Coffee shop name] - [Why it's great]\n\nThank you!"
        
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private var guidesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Free guides
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Free Guides")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Image(systemName: "gift.fill")
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
                
                ForEach(viewModel.getFreeGuides()) { guide in
                    NavigationLink(destination: GuideDetailView(guide: guide, viewModel: viewModel)) {
                        GuideCard(guide: guide, isPurchased: true)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            Divider()
                .padding(.vertical)
            
            // Premium guides
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Premium Guides")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                
                ForEach(viewModel.getPremiumGuides()) { guide in
                    NavigationLink(destination: GuideDetailView(guide: guide, viewModel: viewModel)) {
                        GuideCard(guide: guide, isPurchased: viewModel.hasPurchasedGuide(guide))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Info about supporting the project
            supportInfoCard
        }
        .padding(.horizontal)
    }
    
    private var supportInfoCard: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                
                Text("Support the Project")
                    .font(.headline)
            }
            
            Text("Tours and guides are a way to support the app's continued development. Each purchase helps keep Cafeza active and free for everyone!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.pink.opacity(0.3), lineWidth: 1)
        )
    }
    
}

