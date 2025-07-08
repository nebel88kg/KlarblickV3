import SwiftUI
import StoreKit
import SwiftData

struct PaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Query private var users: [User]
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedProduct: Product?
    
    private var userName: String {
        return users.first?.name ?? "User"
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundSecondary
                .ignoresSafeArea()

                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Plan description
                        topSection

                        
                        // Subscription options
                        subscriptionOptionsSection
                                                
                        // Single purchase button
                        purchaseButtonSection
                        
                        // Footer
                        footerSection
                    }
                    .padding(20)
                }
        }
        .task {
            await subscriptionManager.loadProducts()
            // Auto-select yearly product after loading
            selectDefaultProduct()
        }
        .onAppear {
            // Auto-select yearly product if products are already loaded
            selectDefaultProduct()
        }
        .onChange(of: subscriptionManager.purchaseState) { _, newState in
            handlePurchaseStateChange(newState)
        }
        .onChange(of: subscriptionManager.availableSubscriptions) { _, newSubscriptions in
            // Auto-select the yearly product when products load
            if selectedProduct == nil && !newSubscriptions.isEmpty {
                selectedProduct = newSubscriptions.first { $0.id == SubscriptionManager.ProductID.yearlySubscription } ?? newSubscriptions.first
            }
        }
    }
        
    // MARK: - Subscription Options
    private var subscriptionOptionsSection: some View {
            HStack(spacing: 16) {
                
                if subscriptionManager.availableSubscriptions.isEmpty {
                    // Debug view when no products are available
                    VStack(spacing: 16) {
                        Text("No products available")
                            .font(.headline)
                            .foregroundColor(.ambrosiaIvory)
                        
                        Text("Products may be loading from StoreKit...")
                            .font(.caption)
                            .foregroundColor(.gray2)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry Loading") {
                            Task {
                                await subscriptionManager.loadProducts()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.pharaohsSeas)
                        .foregroundColor(.ambrosiaIvory)
                        .cornerRadius(8)
                    }
                    .padding(20)
                    .background(Color.mangosteenViolet.opacity(0.4))
                    .cornerRadius(16)
                } else {
                    ForEach(subscriptionManager.availableSubscriptions, id: \.id) { product in
                        subscriptionCard(for: product)
                    }
                }
            }
    }
    
    private func subscriptionCard(for product: Product) -> some View {
        let info = subscriptionManager.getSubscriptionInfo(for: product)
        let isYearly = product.id == SubscriptionManager.ProductID.yearlySubscription
        let isSelected = selectedProduct?.id == product.id
        
        return VStack(spacing: 8) {
                VStack(spacing: 4) {
                    Text(info.title)
                        .font(.subheadline)
                        .foregroundColor(.ambrosiaIvory)
                }
                                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(info.price)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mangosteenViolet.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.pharaohsSeas : (isYearly ? Color.pharaohsSeas.opacity(0.5) : Color.clear), lineWidth: 2)
                )
        )
        .onTapGesture {
            selectedProduct = product
        }
    }
    
    // MARK: - Plan Description
        private var topSection: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dear \(userName),")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.ambrosiaIvory)
                
                Text("Welcome to your mindfulness journey. We're excited to help you unlock your full potential.")
                    .font(.body)
                    .foregroundColor(.gray2)
            

            HStack() {
                if let selectedProduct = selectedProduct {
                    let isYearly = selectedProduct.id == SubscriptionManager.ProductID.yearlySubscription
                    
                    if isYearly {
                        Text("We're inviting you to a 3-day free trial. Cancel anytime, no strings attached.")
                            .font(.subheadline)
                            .foregroundColor(.gray2)
                        Spacer()
                        
                        
                    } else {
                        Text("Try Klarblick for one month. It costs less than a cocktail. No hidden costs, cancel anytime.")
                            .font(.subheadline)
                            .foregroundColor(.gray2)
                        Spacer()
                    }
                }
            }
        }
        } // Close the outer VStack for topSection
    }
    
    // MARK: - Single Purchase Button
    private var purchaseButtonSection: some View {
        VStack(spacing: 12) {
            if let selectedProduct = selectedProduct {
                let isYearly = selectedProduct.id == SubscriptionManager.ProductID.yearlySubscription
                let info = subscriptionManager.getSubscriptionInfo(for: selectedProduct)
                
                // Price description
                Text(isYearly ? "3 days free then \(info.price) per year • Cancel anytime" : "Test one month • It's less than a cocktail • Cancel anytime")
                    .font(.subheadline)
                    .foregroundColor(.gray2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    purchaseProduct(selectedProduct)
                }) {
                    Text(isYearly ? "Start Free Trial" : "Subscribe")
                        .font(.headline)
                        .foregroundColor(.mangosteenViolet)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.ambrosiaIvory)
                        .cornerRadius(50)
                }
                .disabled(isLoading)
            } else {
                Text("Select a plan above")
                    .font(.subheadline)
                    .foregroundColor(.gray2)
                    .padding(.vertical, 16)
            }
        }
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 16) {
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.afterBurn)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            VStack(spacing: 8) {
                Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.gray2)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button("Terms") {
                        if let url = URL(string: "https://sites.google.com/view/klarblick-terms-of-service/") {
                            openURL(url)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.pharaohsSeas)
                    
                    Button("Privacy") {
                        if let url = URL(string: "https://sites.google.com/view/klarblick-privacy-policy/") {
                            openURL(url)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.pharaohsSeas)
                    
                    Button("Restore") {
                        restorePurchases()
                    }
                    .font(.caption)
                    .foregroundColor(.pharaohsSeas)
                    .disabled(isLoading)
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .ambrosiaIvory))
                    .scaleEffect(1.2)
                
                Text("Processing...")
                    .font(.subheadline)
                    .foregroundColor(.ambrosiaIvory)
            }
            .padding(24)
            .background(Color.mangosteenViolet)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Actions
    private func selectDefaultProduct() {
        if selectedProduct == nil && !subscriptionManager.availableSubscriptions.isEmpty {
            selectedProduct = subscriptionManager.availableSubscriptions.first { $0.id == SubscriptionManager.ProductID.yearlySubscription } ?? subscriptionManager.availableSubscriptions.first
        }
    }
    
    private func purchaseProduct(_ product: Product) {
        isLoading = true
        errorMessage = nil
        
        Task {
            await subscriptionManager.purchase(product)
        }
    }
    
    private func restorePurchases() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await subscriptionManager.restorePurchases()
        }
    }
    
    private func handlePurchaseStateChange(_ state: SubscriptionManager.PurchaseState) {
        isLoading = false
        
        switch state {
        case .purchased:
            dismiss()
        case .restored:
            if subscriptionManager.isSubscribed {
                dismiss()
            } else {
                errorMessage = "No previous purchases found"
            }
        case .failed(let error):
            errorMessage = error.localizedDescription
        case .notPurchased, .purchasing:
            break
        }
    }
}

// MARK: - Preview
#Preview {
    PaywallView()
        .environmentObject(SubscriptionManager())
} 
