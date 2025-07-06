import Foundation
import StoreKit

// MARK: - Custom Subscription Error
enum SubscriptionError: Error, LocalizedError {
    case failedVerification
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Failed to verify purchase"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}

@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isSubscribed = false
    @Published var currentSubscription: Product?
    @Published var availableSubscriptions: [Product] = []
    @Published var purchaseState: PurchaseState = .notPurchased
    @Published var isInitialized = false
    
    // MARK: - Product IDs
    enum ProductID {
        static let yearlySubscription = "com.klarblick.yearly"
        static let monthlySubscription = "com.klarblick.monthly"
        
        static let allIDs = [yearlySubscription, monthlySubscription]
    }
    
    // MARK: - Purchase State
    enum PurchaseState: Equatable {
        case notPurchased
        case purchasing
        case purchased
        case failed(Error)
        case restored
        
        static func == (lhs: PurchaseState, rhs: PurchaseState) -> Bool {
            switch (lhs, rhs) {
            case (.notPurchased, .notPurchased),
                 (.purchasing, .purchasing),
                 (.purchased, .purchased),
                 (.restored, .restored):
                return true
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            // Don't automatically update subscription status - let the app control this
            
            await MainActor.run {
                isInitialized = true
            }
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        do {
            // Add a small delay to ensure StoreKit is ready
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            let products = try await Product.products(for: ProductID.allIDs)
            
            availableSubscriptions = products.sorted { product1, product2 in
                // Sort by price (yearly first, then monthly)
                if product1.id == ProductID.yearlySubscription {
                    return true
                } else if product2.id == ProductID.yearlySubscription {
                    return false
                } else {
                    return product1.price < product2.price
                }
            }
        } catch {
            // Silently handle product loading failures
        }
    }
    
    // MARK: - Purchase Methods
    func purchase(_ product: Product) async {
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try await checkVerified(verification)
                await updateSubscriptionStatus()
                await transaction.finish()
                purchaseState = .purchased
                
            case .userCancelled:
                purchaseState = .notPurchased
                
            case .pending:
                purchaseState = .notPurchased
                
            @unknown default:
                purchaseState = .notPurchased
            }
        } catch {
            purchaseState = .failed(error)
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            purchaseState = .restored
        } catch {
            purchaseState = .failed(error)
        }
    }
    
    // MARK: - Subscription Status
    func updateSubscriptionStatus() async {
        var activeSubscription: Product?
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try await checkVerified(result)
                
                // Check if the subscription is still active
                if transaction.revocationDate == nil {
                    if let product = availableSubscriptions.first(where: { $0.id == transaction.productID }) {
                        activeSubscription = product
                        break
                    }
                }
            } catch {
                // Silently handle verification failures
            }
        }
        
        currentSubscription = activeSubscription
        isSubscribed = activeSubscription != nil
    }
    
    // MARK: - Transaction Verification
    func checkVerified<T>(_ result: VerificationResult<T>) async throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    // Silently handle transaction verification failures
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    func getSubscriptionInfo(for product: Product) -> (title: String, description: String, price: String) {
        let priceString = product.displayPrice
        
        switch product.id {
        case ProductID.yearlySubscription:
            return (
                title: "Yearly Subscription",
                description: "Get full access with 3-day free trial",
                price: "\(priceString)/year"
            )
        case ProductID.monthlySubscription:
            return (
                title: "Monthly Subscription",
                description: "Get full access monthly",
                price: "\(priceString)/month"
            )
        default:
            return (
                title: "Subscription",
                description: "Get full access",
                price: priceString
            )
        }
    }
    
    // MARK: - Trial Information
    func hasActiveFreeTrial() async -> Bool {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try await checkVerified(result)
                if transaction.productID == ProductID.yearlySubscription {
                    // Check if this is within the trial period
                    let purchaseDate = transaction.purchaseDate
                    let trialEndDate = Calendar.current.date(byAdding: .day, value: 3, to: purchaseDate)
                    return Date() <= (trialEndDate ?? Date.distantPast)
                }
            } catch {
                print("Failed to check trial status: \(error)")
            }
        }
        return false
    }
} 