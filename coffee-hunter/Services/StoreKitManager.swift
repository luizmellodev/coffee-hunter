//
//  StoreKitManager.swift
//  coffee-hunter
//
//  Created by Luiz Mello on 24/03/25.
//

import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    private var updateListenerTask: Task<Void, Error>?
    
    // Product IDs - These should match what you configure in App Store Connect
    enum ProductID: String, CaseIterable {
        // Tours
        case poaClassic1h = "com.cafeza.tour.poa.classic.1h"
        case poaMoinhos2h = "com.cafeza.tour.poa.moinhos.2h"
        case cwbCentro1h = "com.cafeza.tour.cwb.centro.1h"
        case cwbBatel3h = "com.cafeza.tour.cwb.batel.3h"
        
        // Guides
        case guideEquipment = "com.cafeza.guide.equipment"
        case guideGrinding = "com.cafeza.guide.grinding"
        case guideBrewing = "com.cafeza.guide.brewing"
        
        // Premium subscription (optional)
        case premiumMonthly = "com.cafeza.premium.monthly"
        case premiumYearly = "com.cafeza.premium.yearly"
        
        var displayName: String {
            switch self {
            case .poaClassic1h: return "Porto Alegre Classic Tour"
            case .poaMoinhos2h: return "Moinhos de Vento Explorer"
            case .cwbCentro1h: return "Curitiba Centro Tour"
            case .cwbBatel3h: return "Batel Complete Experience"
            case .guideEquipment: return "Guia do Setup Perfeito"
            case .guideGrinding: return "Guia de Moagem"
            case .guideBrewing: return "Métodos de Preparo - Guia Completo"
            case .premiumMonthly: return "Premium - Mensal"
            case .premiumYearly: return "Premium - Anual"
            }
        }
    }
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
            
        case .userCancelled, .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // Purchase by ID
    func purchaseProduct(withID productID: String) async throws -> Bool {
        guard let product = products.first(where: { $0.id == productID }) else {
            throw StoreError.productNotFound
        }
        
        let transaction = try await purchase(product)
        return transaction != nil
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Transaction Updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { @MainActor [weak self] in
            guard let self = self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
    }
    
    // MARK: - Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Helpers
    func isPurchased(productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
    
    func getProduct(forID productID: String) -> Product? {
        return products.first { $0.id == productID }
    }
    
    func getPrice(for productID: String) -> String? {
        return getProduct(forID: productID)?.displayPrice
    }
    
    enum StoreError: Error {
        case failedVerification
        case productNotFound
    }
}

// MARK: - Product Extensions
extension Product {
    var localizedPrice: String {
        return displayPrice
    }
}

