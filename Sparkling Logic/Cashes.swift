import SwiftUI
import PassKit
import StoreKit

struct SubscriptionView: View {
    @State private var subscriptionStatus: String = ""
    var cancelAction: (() -> Void)?
    
    var body: some View {
        VStack {
            Text("Subscription Status: \(subscriptionStatus)")
                .padding()
            
            Button("Purchase Subscription to Shop") {
                purchaseSubscription()
            }
            .padding()
            
            Button("Look Around in Shop") {
                cancelAction?()
            }
            .padding()
        }
        .navigationBarTitle("Subscription")
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    

    
    func purchaseSubscription() {
        restorePurchases()
        if !paying_customer {
            if !SKPaymentQueue.canMakePayments() {
                subscriptionStatus = "In-app purchases are not enabled on this device."
                return
            }
            let productID = "Ecocapsule5K"
            if let product = getProduct(withIdentifier: productID) {
                print("Product ID \(productID) found.")
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            } else {
                print("Product ID \(productID) not found.")
                subscriptionStatus = "Subscription product not found."
            }
        }
    }
    
    func cancelSubscription() {
        print("User cancelled subscription")
        if !hasRenewedSubscription() {
            paying_customer = false
            KeychainService.savePayingCustomerStatus(false)
            subscriptionStatus = "Subscription cancelled due to non-renewal"
        }
    }

    func hasRenewedSubscription() -> Bool {
        // Retrieve the user's subscription renewal date from local storage or server
        guard let renewalDate = UserDefaults.standard.object(forKey: "SubscriptionRenewalDate") as? Date else {
            return false
        }
        
        // Compare the current date with the subscription renewal date
        let currentDate = Date()
        if currentDate > renewalDate {
            // Renewal date has passed
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            print("Subscription renewal date passed on: \(dateFormatter.string(from: renewalDate))")
            return false
        } else {
            // Renewal date has not passed
            let timeRemaining = renewalDate.timeIntervalSince(currentDate)
            let daysRemaining = Int(timeRemaining / (24 * 3600))
            print("Subscription renewal date will pass on: \(renewalDate), \(daysRemaining) days remaining")
            return true
        }
    }





    func getProduct(withIdentifier productID: String) -> SKProduct? {
        for product in StoreManager.shared.availableProducts {
            if product.productIdentifier == productID {
                return product
            }
        }
        return nil
    }
}

class StoreManager: NSObject, ObservableObject, SKPaymentTransactionObserver {
    static let shared = StoreManager()
    @Published var availableProducts: [SKProduct] = []
    
    override private init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let productIDs: Set<String> = ["Ecocapsule5K"]
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error fetching products: \(error.localizedDescription)")
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                print("You are a customer")
                SKPaymentQueue.default().finishTransaction(transaction)
                paying_customer = true
                KeychainService.savePayingCustomerStatus(true)
                
            case .failed:
                print("Transaction failed")
                SKPaymentQueue.default().finishTransaction(transaction)
                paying_customer = false
                KeychainService.savePayingCustomerStatus(false)
                
            case .deferred, .purchasing:
                print("Transaction in progress or deferred")
            @unknown default:
                print("Unknown transaction state")
            }
        }
    }


}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.availableProducts = response.products
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
