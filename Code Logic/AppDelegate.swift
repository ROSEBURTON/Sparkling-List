// AppDelegate.swift + Speaks AI + Created by on 3/25/23.

import UIKit
import CoreData
import StoreKit
import AdSupport
import HealthKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.component(.day, from: now)

        if let lastDay = UserDefaults.standard.object(forKey: "lastDay") as? Int, currentDay != lastDay {
            UserDefaults.standard.set(0, forKey: "points")
            UserDefaults.standard.set(currentDay, forKey: "lastDay")
            let alert = UIAlertController(title: "New Day", message: "Points have been reset.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        completionHandler(.newData)
    }
    

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Speaks_AI")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
extension AppDelegate: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let context = persistentContainer.viewContext
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("You are now a customer 💳")
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                
                // Fetch the customer based on IDFA


            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Purchase did not go through")
                
                // Fetch the advertising identifier (IDFA)
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                
                // Fetch the customer based on IDFA


            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("You have paid in the past")

            default:
                print("You have not been requested to pay")
            }
        }
    }
}
