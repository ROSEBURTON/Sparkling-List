import UIKit
import StoreKit
import AVFAudio

class SEDUViewController: UIViewController {
    private var blurEffectView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func subscribeButtonTapped(_ sender: UIButton) {
        Clicky()
        if !paying_customer {
            SubscriptionView().purchaseSubscription()
        }
    }
    
    func Clicky() {
        guard let soundURL = Bundle.main.url(forResource: "Fart", withExtension: "mp3") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
        } catch {
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    @IBAction func Restore_Purchases(_ sender: UIButton) {
        Clicky()
        // if !paying_customer {
        if KeychainService.loadPayingCustomerStatus() == nil {
            let alert = UIAlertController(title: "Unable to Restore Purchases", message: "You have not made any purchases", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        if KeychainService.loadPayingCustomerStatus() != nil {
            restorePurchases()
            KeychainService.savePayingCustomerStatus(true)
            
            let alert = UIAlertController(title: "Restoring Subscription", message: "Your subscription has been restored", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            print("Unable to load paying_customer status from Keychain")
            let alert = UIAlertController(title: "Unable to Restore Purchases", message: "Unable to load subscription status", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        Clicky()
        navigateToShop()
    }
    
    func navigateToShop() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shopViewController = storyboard.instantiateViewController(withIdentifier: "Shop")
        present(shopViewController, animated: true)

        let allFourUserDefaultsNil = UserDefaults.standard.data(forKey: "topColor") == nil &&
                                      UserDefaults.standard.data(forKey: "bottomColor") == nil &&
                                      UserDefaults.standard.data(forKey: "Top_selected_Background") == nil &&
                                      UserDefaults.standard.data(forKey: "Bottom_selected_Background") == nil
        
        if allFourUserDefaultsNil {
            let alertController = UIAlertController(title: "To Activate Colored Lists", message: "Ensure you initially select 4 colors for your list to see your gradient between your selected 2 colors for both text and task backgrounds", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            shopViewController.present(alertController, animated: true, completion: nil)
        }
    }


}
