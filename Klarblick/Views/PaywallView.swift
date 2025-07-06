import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundSecondary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Benefits section
//                        benefitsSection
                        
                        // Subscription options
                        subscriptionOptionsSection
                        
                        // Footer
                        footerSection
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .overlay {
            if isLoading {
                loadingOverlay
            }
        }
        .task {
            await subscriptionManager.loadProducts()
        }
        .onChange(of: subscriptionManager.purchaseState) { _, newState in
            handlePurchaseStateChange(newState)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button("✕") {
                    dismiss()
                }
                .font(.title2)
                .foregroundColor(.ambrosiaIvory)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Text("Unlock Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.ambrosiaIvory)
                .padding(.top, 8)
            
            Text("Get full access to all Klarblick features")
                .font(.subheadline)
                .foregroundColor(.gray2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Benefits Section
    private var benefitsSection: some View {
        VStack(spacing: 16) {
            benefitRow(icon: "🧘‍♀️", title: "Unlimited Exercises", description: "Access all meditation and mindfulness exercises")
            benefitRow(icon: "📊", title: "Advanced Analytics", description: "Track your progress with detailed insights")
            benefitRow(icon: "🏆", title: "Achievement System", description: "Unlock badges and maintain streaks")
            benefitRow(icon: "☁️", title: "Cloud Sync", description: "Sync your data across all devices")
        }
    }
    
    private func benefitRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.purpleCarolite.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.ambrosiaIvory)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.mangosteenViolet.opacity(0.3))
        .cornerRadius(12)
    }
    
    // MARK: - Subscription Options
    private var subscriptionOptionsSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.ambrosiaIvory)
                .padding(.bottom, 8)
            
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
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(info.title)
                        .font(.headline)
                        .foregroundColor(.ambrosiaIvory)
                    
                    if isYearly {
                        Text("3-day free trial")
                            .font(.caption)
                            .foregroundColor(.pharaohsSeas)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.pharaohsSeas.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(info.price)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.ambrosiaIvory)
                    
                    if isYearly {
                        Text("Save 58%")
                            .font(.caption)
                            .foregroundColor(.afterBurn)
                    }
                }
            }
            
            Text(info.description)
                .font(.subheadline)
                .foregroundColor(.gray2)
            
            Button(action: {
                purchaseProduct(product)
            }) {
                Text(isYearly ? "Start Free Trial" : "Subscribe")
                    .font(.headline)
                    .foregroundColor(.mangosteenViolet)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.ambrosiaIvory)
                    .cornerRadius(8)
            }
            .disabled(isLoading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mangosteenViolet.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isYearly ? Color.pharaohsSeas : Color.clear, lineWidth: 2)
                )
        )
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 16) {
            Button("Restore Purchases") {
                restorePurchases()
            }
            .font(.subheadline)
            .foregroundColor(.pharaohsSeas)
            .disabled(isLoading)
            
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
                        // Handle terms action
                    }
                    .font(.caption)
                    .foregroundColor(.pharaohsSeas)
                    
                    Button("Privacy") {
                        // Handle privacy action
                    }
                    .font(.caption)
                    .foregroundColor(.pharaohsSeas)
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
