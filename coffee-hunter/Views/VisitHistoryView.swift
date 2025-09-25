//
//  VisitHistoryView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import SwiftUI

struct VisitHistoryView: View {
    @ObservedObject var viewModel: CoffeeHunterViewModel
    @State private var showingClearConfirmation = false
    
    var body: some View {
        ScrollView {
            if !viewModel.hasVisitHistory {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.visitHistory) { visit in
                        VisitCard(visit: visit)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Visit History")
        .toolbar {
            if viewModel.hasVisitHistory {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingClearConfirmation = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .alert("Clear History", isPresented: $showingClearConfirmation) {
            Button("Clear", role: .destructive) {
                withAnimation {
                    viewModel.clearVisitHistory()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to clear your visit history? This action cannot be undone.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No visits yet")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Your coffee shop visits will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 100)
    }
}
