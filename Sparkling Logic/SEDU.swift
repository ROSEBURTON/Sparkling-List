import UIKit
import StoreKit
import AVFAudio

class SEDUViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _ = UserDefaults.standard.data(forKey: "Top_selected_Background")
        _ = UserDefaults.standard.data(forKey: "Bottom_selected_Background")
        return 4
    }
    
    var colorProgress: CGFloat = 0.0

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Enticing_tableview.dequeueReusableCell(withIdentifier: "EnticingID", for: indexPath) as! Shopping_Cells
        cell.layer.cornerRadius = 20
        cell.textLabel?.numberOfLines = 0
        cell.layer.masksToBounds = true
        cell.textLabel?.adjustsFontSizeToFitWidth = true

        var colorProgress: CGFloat = 0.0
        let progress = (CGFloat(indexPath.row) / CGFloat(4) + colorProgress).truncatingRemainder(dividingBy: 1.3)
        if let topColorData = UserDefaults.standard.data(forKey: "topColor"),
           let bottomColorData = UserDefaults.standard.data(forKey: "bottomColor"),
           let Top_Background_Color_Data = UserDefaults.standard.data(forKey: "Top_selected_Background"),
           let Bottom_Background_Color_Data = UserDefaults.standard.data(forKey: "Bottom_selected_Background"),
            let topColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(topColorData) as? UIColor,
           let bottomColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(bottomColorData) as? UIColor {
            setColors()
            let textColor = topColor.InterpolateColorTo(bottomColor, fraction: progress)
            cell.textLabel?.textColor = textColor
            let topBackgroundColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Top_Background_Color_Data) as? UIColor
            let bottomBackgroundColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Bottom_Background_Color_Data) as? UIColor
            if let topBackgroundColor = topBackgroundColor, let bottomBackgroundColor = bottomBackgroundColor {
                let Gradient_Changing_Background_Cells = topBackgroundColor.InterpolateColorTo(bottomBackgroundColor, fraction: progress)
                cell.backgroundColor = Gradient_Changing_Background_Cells
            }
        } else {
            cell.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.0, alpha: 1.0)
            cell.textLabel?.textColor = UIColor.white
        }
        return cell
    }
    
    @IBAction func Privacy_Policy(_ sender: UIButton) {
        Selection()
        guard let privacyPolicyURL = URL(string: "https://docs.google.com/document/d/1xwWv_7OzP-w5mnaCtva0HRoaC81AXQ7DT4c6GCvA0yk/edit?usp=sharing") else {
            return
        }
        UIApplication.shared.open(privacyPolicyURL, options: [:], completionHandler: nil)
    }
    
    @IBAction func Terms_of_Use_EULA(_ sender: UIButton) {
        Selection()
        guard let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") else {
            return
        }
        UIApplication.shared.open(termsOfUseURL, options: [:], completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        heavy_haptic.impactOccurred()
        if let mp3URL = Bundle.main.url(forResource: list_sound, withExtension: "mp3") {
            do {
                list_deletion_sound = try AVAudioPlayer(contentsOf: mp3URL)
                   list_deletion_sound?.prepareToPlay()
                   list_deletion_sound?.volume = 0.3
                   list_deletion_sound?.rate = Float.random(in: 0.1...2.0)
                   list_deletion_sound?.enableRate = true
                   list_deletion_sound?.play()
            } catch {
            }
        } else if let wavURL = Bundle.main.url(forResource: list_sound, withExtension: "wav") {
            do {
                   list_deletion_sound = try AVAudioPlayer(contentsOf: wavURL)
                   list_deletion_sound?.prepareToPlay()
                   list_deletion_sound?.volume = 0.3
                   list_deletion_sound?.rate = Float.random(in: 0.1...2.0)
                   list_deletion_sound?.enableRate = true
                   list_deletion_sound?.play()
            } catch {
            }
        }
        Enticing_tableview.deselectRow(at: indexPath, animated: true)
    }

    
    
    @IBOutlet weak var Enticing_tableview: UITableView!
    var startColor: UIColor = .systemCyan
    var endColor: UIColor = .systemPurple
    
    func PlaySound() {
        medium_haptic.impactOccurred()
        guard let soundURL = Bundle.main.url(forResource: "Card Handle", withExtension: "wav") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
        } catch {
        }
    }
    
    func saveRandomColor(forKey key: String) {
        let randomColor = randomUIColor()
        if let encodedColorData = try? NSKeyedArchiver.archivedData(withRootObject: randomColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedColorData, forKey: key)
        }
    }

    func saveRandomBackgroundColor(forKey key: String) {
        let randomColor = randomUIColor()
        if let encodedColorData = try? NSKeyedArchiver.archivedData(withRootObject: randomColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedColorData, forKey: key)
        }
    }
    
    func randomUIColor(alpha: CGFloat = 1.0) -> UIColor {
        let randomRed = CGFloat(Float.random(in: 0.0...1.0))
        let randomGreen = CGFloat(Float.random(in: 0.0...1.0))
        let randomBlue = CGFloat(Float.random(in: 0.0...1.0))
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1)
    }
    
    func saveRandomSound() {
        let randomIndex = Int(arc4random_uniform(UInt32(deleteSoundOptions.count)))
        let list_sound = deleteSoundOptions[randomIndex]
        UserDefaults.standard.set(list_sound, forKey: "list_sound")
        UserDefaults.standard.set(randomIndex, forKey: "selectedDeleteSoundIndex")
    }

    func selectRandomFont() {
        if let fontNames = UIFont.familyNames as? [String], !fontNames.isEmpty {
            let randomFontIndex = Int.random(in: 0..<fontNames.count)
            let randomFontName = fontNames[randomFontIndex]
            UserDefaults.standard.set(randomFontName, forKey: "SelectedFont")
            UserDefaults.standard.set(randomFontIndex, forKey: "selectedFontIndex")
        }
    }
    
    // Declare a Timer property
    var timer: Timer?


    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            self?.executeCode()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @IBOutlet weak var Bubbly: UILabel!
    @IBOutlet weak var BubblyN: UILabel!
    @IBOutlet weak var BubblyTap: UILabel!
    
    func executeCode() {
        PlaySound()
        saveRandomColor(forKey: "topColor")
        saveRandomColor(forKey: "bottomColor")
        saveRandomBackgroundColor(forKey: "Top_selected_Background")
        saveRandomBackgroundColor(forKey: "Bottom_selected_Background")
        saveRandomSound()
        selectRandomFont()
    if Combined_missions.count > 1 {
        Combined_missions.shuffle()
    }
        Enticing_tableview.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        Bubbly.font = UIFont(name: "Namecat", size: 35.0)
        BubblyN.font = UIFont(name: "Namecat", size: 35.0)
        BubblyTap.font = UIFont(name: "Namecat", size: 35.0)
        
        Enticing_tableview.layer.cornerRadius = 25
        Enticing_tableview.clipsToBounds = true
        Enticing_tableview.separatorStyle = .singleLine
        Enticing_tableview.delegate = self
        Enticing_tableview.dataSource = self
        Enticing_tableview.backgroundColor = UIColor.clear
    }
    
    func setColors() {
        if let storedStartColorData = UserDefaults.standard.data(forKey: "startColor"),
           let storedEndColorData = UserDefaults.standard.data(forKey: "endColor"),
           let storedStartColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedStartColorData),
           let storedEndColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedEndColorData) {
            self.startColor = storedStartColor
            self.endColor = storedEndColor
            Enticing_tableview.reloadData()
        }
    }

    @IBAction func subscribeButtonTapped(_ sender: UIButton) {
        Selection()
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
    
    func Selection() {
        guard let soundURL = Bundle.main.url(forResource: "Selection", withExtension: "wav") else { return }
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
        Selection()
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

    @IBAction func IgnoreButtonTapped(_ sender: UIButton) {
        Selection()
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
