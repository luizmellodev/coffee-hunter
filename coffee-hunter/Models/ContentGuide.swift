//
//  ContentGuide.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation

struct ContentGuide: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let category: GuideCategory
    let isPremium: Bool
    let price: Double?
    let estimatedReadingTime: Int // in minutes
    let content: String
    let coverImage: String? // Asset name or URL
    let author: String
    let publishedDate: Date
    let tags: [String]
    
    enum GuideCategory: String, Codable, CaseIterable {
        case basics = "Basics"
        case equipment = "Equipment"
        case brewing = "Brewing"
        case roasting = "Roasting"
        case grinding = "Grinding"
        
        var icon: String {
            switch self {
            case .basics: return "book.fill"
            case .equipment: return "wrench.and.screwdriver.fill"
            case .brewing: return "cup.and.saucer.fill"
            case .roasting: return "flame.fill"
            case .grinding: return "gearshape.fill"
            }
        }
        
        var color: String {
            switch self {
            case .basics: return "blue"
            case .equipment: return "purple"
            case .brewing: return "brown"
            case .roasting: return "orange"
            case .grinding: return "gray"
            }
        }
    }
}

// Sample guides
extension ContentGuide {
    static let sampleGuides: [ContentGuide] = [
        // Free guides
        ContentGuide(
            id: "what-is-specialty-coffee",
            title: "What is Specialty Coffee?",
            description: "Understand what makes coffee special and why it's different from regular coffee.",
            category: .basics,
            isPremium: false,
            price: nil,
            estimatedReadingTime: 5,
            content: """
                # What is Specialty Coffee?

                Specialty coffee is high-quality coffee that has been evaluated by certified professionals and scored 80 or more points on a scale of 100.

                ## Characteristics of Specialty Coffee

                - **Traceability**: You know exactly where the coffee comes from
                - **Superior quality**: No significant defects
                - **Freshness**: Usually recently roasted
                - **Unique flavor profile**: Each coffee has its own characteristics

                ## Why is it more expensive?

                Specialty coffee involves more care throughout the entire production chain, from planting to cup. Producers receive fair prices, and the result is coffee with unique flavors and aromas.

                ## How to start?

                1. Visit a specialized coffee shop
                2. Try different origins
                3. Talk to the baristas
                4. Appreciate the unique flavors

                Welcome to the world of specialty coffee! ☕️
            """,
            coverImage: nil,
            author: "Cafeza Team",
            publishedDate: Date(),
            tags: ["beginner", "basics", "introduction"]
        ),
        
        ContentGuide(
            id: "roasting-guide-free",
            title: "Coffee Roasting Guide",
            description: "Learn about different roast levels and how they affect coffee flavor.",
            category: .roasting,
            isPremium: false,
            price: nil,
            estimatedReadingTime: 8,
            content: """
            # Coffee Roasting Guide

            Roasting is one of the most important processes in coffee production. It transforms green beans into roasted beans, developing the flavors and aromas we love.
            
            ## Roast Levels
            
            ### Light Roast
            - Preserves original bean characteristics
            - More pronounced acidity
            - Floral and fruity flavors
            
            ### Medium Roast
            - Balance between acidity and body
            - Moderate caramelization
            - Versatile for different brewing methods
            
            ### Dark Roast
            - Fuller body
            - Chocolate and caramel flavors
            - Less acidity
            
            ## How to choose?
            
            Try different roasts and discover your preference! There's no right or wrong, just what you enjoy most.
            """,
            coverImage: nil,
            author: "Cafeza Team",
            publishedDate: Date(),
            tags: ["roasting", "processing", "intermediate"]
        ),
        
        // Premium guides
        ContentGuide(
            id: "equipment-setup-guide",
            title: "The Perfect Setup Guide",
            description: "Everything you need to know to build your home coffee setup, from basic to advanced equipment.",
            category: .equipment,
            isPremium: true,
            price: 12.90,
            estimatedReadingTime: 15,
            content: """
            # The Perfect Setup Guide
            
            *This is a premium guide with detailed equipment content*
            
            ## Beginner Setup ($50-150)
            
            ### Grinder
            - Specific recommendations
            - Where to buy
            - Ideal settings
            
            ### Brewing method
            - Aeropress
            - Hario V60
            - French Press
            
            ## Intermediate Setup ($150-500)
            
            ### Premium grinders
            - Hand grinders vs Electric
            - Burr types explained
            - Maintenance tips
            
            ### Scale importance
            - Why precision matters
            - Digital scale features
            - Best practices
            
            ## Advanced Setup ($500+)
            
            ### Professional equipment
            - Espresso machines
            - High-end grinders
            - Water filtration
            
            [... full content available after purchase]
            """,
            coverImage: nil,
            author: "Cafeza Team",
            publishedDate: Date(),
            tags: ["equipment", "setup", "premium"]
        ),
        
        ContentGuide(
            id: "grinding-masterclass",
            title: "Grinding Masterclass",
            description: "Master the art of grinding and understand how it affects your coffee extraction.",
            category: .grinding,
            isPremium: true,
            price: 8.90,
            estimatedReadingTime: 12,
            content: """
            # Grinding Masterclass
            
            *Premium guide about coffee grinding*
            
            ## Why grinding matters?
            
            Grinding is crucial for perfect extraction. The particle size directly affects:
            
            - **Extraction time**: Finer = slower, Coarser = faster
            - **Flavor profile**: Uniformity creates balance
            - **Consistency**: Key to repeatable results
            
            ## Grind sizes explained
            
            ### Extra Fine (Espresso)
            - Turkish coffee texture
            - 15-20 seconds extraction
            - High pressure brewing
            
            ### Fine (Espresso, Moka Pot)
            - Sugar-like texture
            - 25-30 seconds for espresso
            - Essential for pressure brewing
            
            ### Medium-Fine (Pour Over)
            - Sand-like texture
            - 2.5-3.5 minutes total brew
            - Balanced extraction
            
            ### Medium (Drip, Aeropress)
            - Table salt texture
            - 3-4 minutes brew time
            - Versatile for most methods
            
            ### Coarse (French Press, Cold Brew)
            - Sea salt texture
            - 4+ minutes steep
            - Prevents over-extraction
            
            [... full content available after purchase]
            """,
            coverImage: nil,
            author: "Cafeza Team",
            publishedDate: Date(),
            tags: ["grinding", "technique", "premium"]
        ),
        
        ContentGuide(
            id: "brewing-methods-complete",
            title: "Complete Brewing Methods Guide",
            description: "Learn all specialty coffee brewing methods: recipes, techniques and professional tips.",
            category: .brewing,
            isPremium: true,
            price: 15.90,
            estimatedReadingTime: 20,
            content: """
            # Complete Brewing Methods Guide
            
            *The most complete guide about brewing methods*
            
            ## V60 Pour Over
            
            **Equipment needed:**
            - Hario V60 dripper
            - V60 paper filters
            - Gooseneck kettle
            - Scale
            
            **Recipe (15g coffee, 250ml water)**
            1. Rinse filter with hot water
            2. Add ground coffee (medium-fine)
            3. Bloom: 30ml water, wait 30-45s
            4. Pour in circles up to 250ml
            5. Total time: 2:30-3:00
            
            ## Chemex
            
            Beautiful and delicious results...
            
            [... full content available after purchase]
            """,
            coverImage: nil,
            author: "Cafeza Team",
            publishedDate: Date(),
            tags: ["brewing", "methods", "recipes", "premium"]
        ),
        
        ContentGuide(
            id: "coffee-beginner",
            title: "Getting Started with Specialty Coffee",
            description: "The definitive guide for anyone starting their specialty coffee journey.",
            category: .basics,
            isPremium: false,
            price: nil,
            estimatedReadingTime: 10,
            content: """
            # Getting Started with Specialty Coffee
            
            Starting in the world of specialty coffee might seem intimidating, but it doesn't have to be!
            
            ## Step 1: Visit Specialized Coffee Shops
            
            Use this app to find coffee shops near you that serve specialty coffee.
            
            ## Step 2: Try Different Methods
            
            Each brewing method highlights different coffee characteristics:
            - **Espresso**: Intense and full-bodied
            - **Pour Over**: Clean and delicate
            - **French Press**: Body and texture
            
            ## Step 3: Learn to Taste
            
            Take your time. Notice:
            - Aroma
            - Acidity
            - Body
            - Flavor
            - Finish
            
            ## Step 4: Invest Gradually
            
            You don't need to buy everything at once. Start with the basics and evolve.
            
            ## Additional Resources
            
            - Follow baristas on Instagram
            - Attend coffee events
            - Use our app to track your experiences
            - Visit cafeza.club for more free content
            
            Enjoy the journey! ☕️
            """,
            coverImage: nil,
            author: "Cafeza Team",
            publishedDate: Date(),
            tags: ["beginner", "guide", "start"]
        )
    ]
    
    static var freeGuides: [ContentGuide] {
        sampleGuides.filter { !$0.isPremium }
    }
    
    static var premiumGuides: [ContentGuide] {
        sampleGuides.filter { $0.isPremium }
    }
}

