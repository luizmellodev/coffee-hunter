//
//  Achievement.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//


import Foundation

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}