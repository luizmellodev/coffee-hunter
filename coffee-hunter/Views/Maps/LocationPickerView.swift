//
//  LocationPickerView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 25/09/25.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var searchText = ""
    @State private var position: MapCameraPosition
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    init(viewModel: CoffeeHunterViewModel) {
        self.viewModel = viewModel
        let initialLocation = viewModel.selectedLocation ?? CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333)
        self._position = State(initialValue: .region(MKCoordinateRegion(
            center: initialLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position) {
                    if let location = selectedLocation {
                        Marker("Selected Location", coordinate: location)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .onTapGesture { _ in
                    selectedLocation = position.region?.center
                }
                
                VStack {
                    if isSearching {
                        searchResultsList
                    }
                    Spacer()
                    bottomButton
                }
            }
            .searchable(text: $searchText, prompt: "Search location")
            .onChange(of: searchText) { _, newValue in
                if !newValue.isEmpty {
                    searchLocation(query: newValue)
                } else {
                    searchResults = []
                }
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var searchResultsList: some View {
        List(searchResults, id: \.self) { item in
            Button {
                selectSearchResult(item)
            } label: {
                VStack(alignment: .leading) {
                    Text(item.name ?? "Unknown Location")
                        .font(.headline)
                    if let address = item.placemark.title {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .background(.thinMaterial)
    }
    
    private var bottomButton: some View {
        Button {
            if let location = selectedLocation {
                viewModel.updateLocation(location)
                dismiss()
            }
        } label: {
            Text("Use This Location")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedLocation != nil ? Color.brown : Color.gray)
                .cornerRadius(12)
        }
        .disabled(selectedLocation == nil)
        .padding()
    }
    
    private func searchLocation(query: String) {
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: position.region?.center ?? CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                return
            }
            
            searchResults = response?.mapItems ?? []
        }
    }
    
    private func selectSearchResult(_ item: MKMapItem) {
        selectedLocation = item.placemark.coordinate
        position = .region(MKCoordinateRegion(
            center: item.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        searchText = ""
        isSearching = false
    }
    
    // Removed unused coordinate computation method as we're using the map's center directly
}
