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
        // Main content - this should be first to establish proper layout
        VStack(spacing: 4) {
            // Plan description
            topSection

            Spacer()
            // Subscription options
            subscriptionOptionsSection
                                    
            // Single purchase button
            purchaseButtonSection
            
            // Footer
            footerSection
        }
        .padding(20)
        .background(
            // Background with image and fade effect
            ZStack {
                // Solid background color for areas not covered by image
                Color.backgroundSecondary
                    .ignoresSafeArea()
                
                // Background image with fade effect
                VStack {
                    ZStack {
                        // PaywallPic background image
                        Image("PaywallPic")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: UIScreen.main.bounds.height * 0.5)
                            .clipped()
                        
                        // Gradient overlay for fade effect
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.clear, location: 0.0),
                                .init(color: Color.clear, location: 0.5),
                                .init(color: Color.backgroundSecondary.opacity(0.1), location: 0.7),
                                .init(color: Color.backgroundSecondary, location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: UIScreen.main.bounds.height * 0.5)
                    }
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
            }
        )
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
                    VStack(alignment: .leading){
                                Text("✓  Build inner calm & self-trust.")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.ambrosiaIvory)
                                    .padding(.bottom, 4)
                                    .multilineTextAlignment(.leading)
                                
                                Text("✓  Become present in every moment.")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.ambrosiaIvory)
                                    .padding(.bottom, 4)
                                    .multilineTextAlignment(.leading)
                                
                                Text("✓  Feel more grounded and balanced.")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.ambrosiaIvory)
                                    .padding(.bottom, 4)
                                    .multilineTextAlignment(.leading)
                                
                                Text("✓  Establish a sustainable mindfulness habit.")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.ambrosiaIvory)
                                    .padding(.bottom, 10)
                                    .multilineTextAlignment(.leading)

                        HStack(spacing: 14) {
                            ForEach(subscriptionManager.availableSubscriptions, id: \.id) { product in
                                subscriptionCard(for: product)
                            }
                        }
                    }
                }
            }
    }
    
    private func subscriptionCard(for product: Product) -> some View {
        let info = subscriptionManager.getSubscriptionInfo(for: product)
        let isYearly = product.id == SubscriptionManager.ProductID.yearlySubscription
        let isSelected = selectedProduct?.id == product.id
        
        // Calculate monthly price for display
        let monthlyPrice: String = {
            if isYearly {
                // For yearly subscription, divide by 12 to get monthly equivalent
                let yearlyPrice = product.price
                let monthlyEquivalent = yearlyPrice / 12
                
                // Format as currency using the current locale
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = Locale.current
                return formatter.string(from: monthlyEquivalent as NSDecimalNumber) ?? product.displayPrice
            } else {
                // For monthly subscription, use the display price directly
                return product.displayPrice
            }
        }()
        
        return ZStack{
            VStack(spacing: 6) {
            Text(info.title)
                .font(.subheadline)
                .foregroundColor(.ambrosiaIvory)
            
            HStack(alignment: .bottom, spacing: 4){
                Text(monthlyPrice)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.ambrosiaIvory)
                Text("/mo")
                    .font(.caption)
                    .foregroundColor(.gray2)
                    .padding(.bottom, 1)
            }
            
            Text("Billed \(info.title.lowercased())")
                .font(.caption)
                .foregroundColor(.gray2)
            
            
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mangosteenViolet.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.pharaohsSeas : Color.gray.opacity(0.5), lineWidth: 2)
                )
        )
        .onTapGesture {
            selectedProduct = product
        }
        
            if isYearly{
                Text("-20%")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .fontWeight(.bold)
                    .padding(2)
                    .padding(.horizontal, 6)
                    .background(Color.backgroundSecondary.opacity(0.7))
                    .background(Color.green)
                    .cornerRadius(20)
                    .padding(.bottom, 100)

            }
        }
    }
    
    // MARK: - Plan Description
        private var topSection: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text("Dear \(userName),")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.purpleCarolite)
                
                Text("Welcome to your mindfulness journey. We're excited to help you unlock your full potential.")
                    .foregroundColor(.mangosteenViolet)
                    .font(.callout)
            }
            .padding(12)
            .background(.ultraThinMaterial.opacity(0.8))
            .cornerRadius(10)
    }
    
    // MARK: - Single Purchase Button
    private var purchaseButtonSection: some View {
        VStack(spacing: 12) {
            if let selectedProduct = selectedProduct {
                let isYearly = selectedProduct.id == SubscriptionManager.ProductID.yearlySubscription
//                let info = subscriptionManager.getSubscriptionInfo(for: selectedProduct)
                
                // Price description
//                Text(isYearly ? "3 days free then \(info.price) per year • Cancel anytime" : "Test one month • It's less than a cocktail • Cancel anytime")
//                    .font(.subheadline)
//                    .foregroundColor(.gray2)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 20)
                
                Button(action: {
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
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
                        if let url = URL(string: "https://sites.google.com/view/klarblick-app/terms-of-service") {
                            openURL(url)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.pharaohsSeas)
                    
                    Button("Privacy") {
                        if let url = URL(string: "https://sites.google.com/view/klarblick-app/privacy-policy") {
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
        .padding(.top, 12)
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
