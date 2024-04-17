import SwiftUI
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
    
    func purchaseSubscription() {
        print("Paying customer status: \(paying_customer)")
        if !paying_customer {
            if !SKPaymentQueue.canMakePayments() {
                subscriptionStatus = "In-app purchases are not enabled on this device."
                return
            }
            
            let productID = "Ecocapsule5K" //  // VAE5K // SparklingChromeProductID Ecocapsule5K AUser
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
            case .failed:
                print("You are NOT a customer")
                SKPaymentQueue.default().finishTransaction(transaction)
                paying_customer = false
            case .deferred, .purchasing:
                print("You deferred payment")
                break
            @unknown default:
                break
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
