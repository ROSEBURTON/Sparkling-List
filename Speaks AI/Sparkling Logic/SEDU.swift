import UIKit

class SEDUViewController: UIViewController {
    private var blurEffectView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func subscribeButtonTapped(_ sender: UIButton) {
        if !paying_customer {
            SubscriptionView().purchaseSubscription()
            
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
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
