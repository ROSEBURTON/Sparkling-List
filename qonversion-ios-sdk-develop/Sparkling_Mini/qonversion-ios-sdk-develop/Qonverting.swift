import Foundation
import Qonversion

class QonversionManager {
    static let shared = QonversionManager()
    private let apiKey = "YOUR_API_KEY" // Replace with your actual API key

    func initializeQonversion() {
        Qonversion.launch(withKey: apiKey)
    }

    func checkSubscriptionStatus(for productID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Qonversion.checkPermissions(for: productID) { result in
            switch result {
            case .success(let permissions):
                if let permission = permissions[productID] {
                    completion(.success(permission.isActive))
                } else {
                    completion(.failure(QonversionError.permissionNotFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func restoreUserPurchases(completion: @escaping (Result<[String], Error>) -> Void) {
        Qonversion.restoreUserPurchases { result in
            switch result {
            case .success(let products, _):
                completion(.success(products))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func trackPurchaseEvent(productID: String, currency: String, value: Double) {
        let event = Qonversion.Event.purchase(productID: productID, currency: currency, value: value)
        Qonversion.track(event)
    }

    var userProperties: [String: Any] {
        return Qonversion.userProperties
    }

    var qonversionVersion: String {
        return Qonversion.version
    }
}

enum QonversionError: Error {
    case permissionNotFound
}
