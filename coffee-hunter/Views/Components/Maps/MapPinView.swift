//
//  MapPinView.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//


import MapKit
import CoreLocation
import SwiftUI

struct MapPinView: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.brown : Color.gray)
                .frame(width: 40, height: 40)
                .shadow(radius: 3)
            
            Image(systemName: "cup.and.saucer.fill")
                .foregroundColor(.white)
                .font(.system(size: 20))
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}