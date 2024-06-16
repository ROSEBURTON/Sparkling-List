import UIKit
import SwiftUI
import CoreText
import StoreKit
import CoreData
import Foundation
import MessageUI
import AVFoundation

import TipKit

// Scroll Views:
//MEMORIZE FROM MAIN LIST:
// scroll view at 0 , 0 , 0 , 0. Add 4 constraints (SCROLL VIEW 4)
// mini view contraints 0 , 0 , 0 , 0, specify height of SHOP. Add 5 constraints (MINI 5)
// mini view control drag to main view , equal widths, equal heights (MINI DRAG)
// 1800

class Shopping_Cells: UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.textLabel?.text = "This is a preview of your list (Test me)"
        self.textLabel?.adjustsFontSizeToFitWidth = true
        if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
            let customFont = UIFont(name: selectedFont, size: 15.0)
            self.textLabel?.font = customFont
        } else {
            self.textLabel?.font = UIFont(name: "Chalkduster", size: 15.0)
        }
    }
}

var paying_customer: Bool {
    get {
        if let payingCustomer = KeychainService.loadPayingCustomerStatus() {
            return payingCustomer
        }
        return UserDefaults.standard.bool(forKey: "paying_customer")
    }
    set {
        KeychainService.savePayingCustomerStatus(newValue)
    }
}

var selectedFontIndex: Int = 0
var selectedDeletionIndex: Int = 0
var deleteSoundOptions = ["@*!+-R", "Bakin' Dat Pizza", "Pink Gladiate Soda", "Rainbow Chromium Finish","Chalkboard", "Coming Near You", "Cybernetic Models", "👁️‍🗨️ Exploit URF", "Fart", "Wine Glass", "Gold for Galactic Drinks", "Gyat Chonki-Lonki Party Butt Bounce", "Laser", "Loading Productive Ammo", "Miss Computer Email", "Missile Hit", "Nuclear Ending", "Pleased Observing Mantid", "Productive Prep", "Ready for Takeoff", "Soda Sea Mine", "Sparkling Status Signal", "Green Lime, Sour Pink Splash", "Type Ship", "I eat grass", "Water Lurk", "Double Foam Root Beers", "Click Back", "Building Computer Power Down", "DJ Black Pizza", "Dolphin Signal", "Bubbles", "Boxing", "Dissolved", "Loaded", "Wetter", "Occult", "Task Down", "Controlled Boomerang", "Conversation", "Registered In", "Violated", "Berry Pie", "Female", "Distress Call In The Distance", "Moist", "Owl", "Drop", "Card Handle", "Window Shatter", "Sword Hit", "Slash", "Stumble", "Curious", "Glurped", "Static Boing", "Dizi Sunlight", "Time Begins", "Early Riser", "Wet Rocks", "Coin Spill", "Syrup Slushie Splash", "Zip Up", "Powering Up", "Party Horn", "Thunder Shock", "Well Thunder Hit", "Game Laser", "Telegraph", "Transmitting", "Vibrens", "Target Hit", "Triple Fire", "Loading Down", "XliNo RED", "Very Hitting", "Blue Warpings", "Pouring Cake Batter", "Fried Chicken", "Both Sides Please", "A Good Heating", "Whole Egg Consumption", "Ultra Moist Bite", "Inner Soundwave", "Hungry Chaos", "Bad Denial", "Rocky Water Run", "Hot and Ready Kebab", "Digging Up Mess", "Cook Burn","Sonic Whistle", "Dawg In Me", "Turning Up", "Ethoric", "Backwards", "Well-Aimed", "Flipped In", "Superping", "In Click", "Bionic Dolphin Snort", "Tri Ten", "Selection", "Nasal Honk", "Bubble Gum", "Mating Dance", "RigNut", "White Interior Craft Communication", "Possession", "EurickEurick", "DJ Trippin'", "Mixing Space Cake Batter", "Laughing", "Fast Chain", "NO", "Chicago Corporation", "Throwing It Back Along The Way", "Get To Blastin'", "Hit", "Smelling Spray", "BackTrack"].sorted()

//Scroll Store:
// scroll view at 0 , 0 , 0 , 0. Add 4 constraints
// mini view contraints 0 , 0 , 0 , 0, specify height of SHOP. Add 5 constraints
// mini view control drag to main view , equal widths, equal heights
// 1300

public class SHOP: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, SKRequestDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var Preview_List: UITableView!
    @IBOutlet weak var Top_List_Background_Color: UIColorWell!
    @IBOutlet weak var Bottom_List_Background_Color: UIColorWell!
    @IBOutlet weak var Text_Top_Color: UIColorWell!
    @IBOutlet weak var Text_Bottom_Color: UIColorWell!
    @IBOutlet weak var TagurLogo: UIImageView!
    @IBOutlet weak var SketchesLogo: UIImageView!
    var selectedDeleteSoundIndex = 0
    var Shop_deletion_sound: AVAudioPlayer?
    weak var delegate: ColorChangeDelegate?
    var colorProgress: CGFloat = 0.0
    var gradientEntity: Gradient?
    var onColorSelection: ((UIColor, UIColor) -> Void)?
    weak var colorChangeDelegate: ColorChangeDelegate?
    var timer: Timer?
    @IBOutlet weak var Request: UIButton!
    static let shared = AppDelegate()
    weak var fontSelectionDelegate: FontSelectionDelegate?
    var selectedFont: String?
    var selected_Background: String?
    var selectedEntity: String?
    var managedObjectContext: NSManagedObjectContext!
    var shop_deletion_sound: AVAudioPlayer?
    var fonts: [String] = []
    @IBOutlet weak var FontSelection: UIPickerView!
    @IBOutlet weak var DeleteSound: UIPickerView!
    var subscriptionProduct: SKProduct?

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _ = UserDefaults.standard.data(forKey: "Top_selected_Background")
        _ = UserDefaults.standard.data(forKey: "Bottom_selected_Background")
        return 4
    }
    
    @IBAction func Contact_Support(_ sender: UIButton) {
        Selection()
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients(["cosmonautEBE@gmail.com"])
            mailComposeViewController.setSubject("Request Support 🛎️")
            mailComposeViewController.setMessageBody("I would like some support with this app.\n\nDescribe your concern:\n>\n\n Bug Issue:\n>\n\nSuggestion and Feedback:\n>\n\nApp Like and Dislike:\n>\n\nOther:\n>", isHTML: false)
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Unable to Send Email for support", message: "Your device is not configured to send emails.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
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
    
    func getProduct(withIdentifier productID: String) -> SKProduct? {
        for product in StoreManager.shared.availableProducts {
            if product.productIdentifier == productID {
                return product
            }
        }
        return nil
    }
    
    @IBAction func Cancel_Subscription(_ sender: UIButton) {
        Selection()

        let alert = UIAlertController(title: "Cancel Subscription", message: "To cancel your subscription follow these steps:\n\n1. Open the App Store app on your device.\n2. Tap your profile icon in the top right corner.\n3. Tap 'Subscriptions'.\n4. Find the subscription for the app Sparkling List and tap on it.\n5. Follow the on-screen instructions to cancel the subscription.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let AppStoreSubscriptions = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                UIApplication.shared.open(AppStoreSubscriptions, options: [:], completionHandler: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)

        if paying_customer {
            SubscriptionView().cancelSubscription()
        }
        print("User cancelled subscription")
        for transaction in SKPaymentQueue.default().transactions {
            if transaction.payment.productIdentifier == "Ecocapsule5K" {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    func configurePickerView(with options: [String], for pickerView: UIPickerView) {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = options.hashValue
        pickerView.userInfo = ["options": options]
        if let firstOption = options.first {
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    var startColor: UIColor = .systemCyan
    var endColor: UIColor = .systemPurple
    
    func setColors() {
        if let storedStartColorData = UserDefaults.standard.data(forKey: "startColor"),
           let storedEndColorData = UserDefaults.standard.data(forKey: "endColor"),
           let storedStartColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedStartColorData),
           let storedEndColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedEndColorData) {
            self.startColor = storedStartColor
            self.endColor = storedEndColor
            Preview_List.reloadData()
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        heavy_haptic.impactOccurred()
        UserDefaults.standard.set(selectedDeleteSoundIndex, forKey: "selectedDeleteSoundIndex")
        var soundURL: URL?
        if let wav_type = Bundle.main.url(forResource: list_sound, withExtension: "wav") {
            soundURL = wav_type
             UserDefaults.standard.set(list_sound, forKey: "list_sound")
        } else if let mp3_type = Bundle.main.url(forResource: list_sound, withExtension: "mp3") {
            soundURL = mp3_type
            UserDefaults.standard.set(list_sound, forKey: "list_sound")
        }
        if let sound_to_use = soundURL {
            do {
                shop_deletion_sound = try AVAudioPlayer(contentsOf: sound_to_use)
                shop_deletion_sound?.prepareToPlay()
                shop_deletion_sound?.volume = 0.7
                shop_deletion_sound?.enableRate = true
                shop_deletion_sound?.rate = Float.random(in: 0.1...2.0)
                shop_deletion_sound?.play()
            } catch {
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewID", for: indexPath) as! Shopping_Cells
        let progress = (CGFloat(indexPath.row) / CGFloat(4) + colorProgress).truncatingRemainder(dividingBy: 1.3)
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        if let topColorData = UserDefaults.standard.data(forKey: "topColor"),
           let topColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(topColorData) as? UIColor {
            if let bottomColorData = UserDefaults.standard.data(forKey: "bottomColor"),
               let bottomColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(bottomColorData) as? UIColor {
                let textColor = topColor.InterpolateColorTo(bottomColor, fraction: progress)
                
                cell.textLabel?.textColor = textColor
            } else {
                cell.textLabel?.textColor = topColor
            }
        }

        if let topBackgroundColorData = UserDefaults.standard.data(forKey: "Top_selected_Background") {
            let topBackgroundColor = NSKeyedUnarchiver.unarchiveObject(with: topBackgroundColorData) as? UIColor
            if let bottomBackgroundColorData = UserDefaults.standard.data(forKey: "Bottom_selected_Background") {
                let bottomBackgroundColor = NSKeyedUnarchiver.unarchiveObject(with: bottomBackgroundColorData) as? UIColor
                if indexPath.row == 0 {
                    cell.backgroundColor = topBackgroundColor
                } else if indexPath.row == 1 {
                    cell.backgroundColor = bottomBackgroundColor
                }
            } else {
                cell.backgroundColor = topBackgroundColor
            }
        } else if let bottomBackgroundColorData = UserDefaults.standard.data(forKey: "Bottom_selected_Background") {
            let bottomBackgroundColor = NSKeyedUnarchiver.unarchiveObject(with: bottomBackgroundColorData) as? UIColor
            cell.backgroundColor = bottomBackgroundColor
        } else {
            print("Background Colors not found in UserDefaults")
        }
        
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

    @objc func List_Gradient_Changing(_ sender: UIColorWell) {
        guard let soundURL = Bundle.main.url(forResource: "Fart", withExtension: "mp3") else { return }
        do {
            self.shop_deletion_sound = try AVAudioPlayer(contentsOf: soundURL)
            self.shop_deletion_sound?.prepareToPlay()
            self.shop_deletion_sound?.volume = 0.3
            self.shop_deletion_sound?.play()
        } catch {
        }

        let senderToUserDefaultsKey: [UIView: String] = [
            Text_Top_Color: "topColor",
            Text_Bottom_Color: "bottomColor",
            Top_List_Background_Color: "Top_selected_Background",
            Bottom_List_Background_Color: "Bottom_selected_Background"
        ]

        if let key = senderToUserDefaultsKey[sender] {
            let selectedColor = sender.selectedColor
            if selectedColor != nil {
                saveColorToUserDefaults(color: selectedColor!, forKey: key)
                print("\(sender.accessibilityLabel ?? "") Color: \(String(describing: selectedColor))")
            } else {
                print("Selected color is nil.")
            }
        }
            Preview_List.reloadData()
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }


    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let options = pickerView.userInfo?["options"] as? [String] {
            return options.count
        }
        return 0
    }
    
    var flashingColors: [UIColor] = [.red, .blue, .green, .yellow, .systemMint, .systemOrange]

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        var title: String?
        if pickerView == DeleteSound {
            title = deleteSoundOptions[row]
        } else if let options = pickerView.userInfo?["options"] as? [String] {
            title = options[row]
        }
        let fontName = title ?? "Chalkduster"
        let fontSize: CGFloat = 47
        if let font = UIFont(name: fontName, size: fontSize) {
            label.font = UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor, size: fontSize)
        } else {
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
        }
        label.text = title
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        let flashingColor = flashingColors[row % flashingColors.count]
        label.attributedText = NSAttributedString(string: title ?? "", attributes: [
            .foregroundColor: flashingColor
        ])
        return label
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == DeleteSound {
            return deleteSoundOptions[row]
        } else if let options = pickerView.userInfo?["options"] as? [String] {
            return options[row]
        }
        return nil
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        medium_haptic.impactOccurred()
        if pickerView == DeleteSound {
            selectedDeleteSoundIndex = row
            UserDefaults.standard.set(selectedDeleteSoundIndex, forKey: "selectedDeleteSoundIndex")
            UserDefaults.standard.synchronize()
        } else if let options = pickerView.userInfo?["options"] as? [String], row < options.count {
        }
        selectedFontIndex = row
        UserDefaults.standard.set(selectedFontIndex, forKey: "selectedFontIndex")
        
        Preview_List.reloadData()
        if let options = pickerView.userInfo?["options"] as? [String], row < options.count {
            let selectedOption = options[row]
            print("Selected option: \(selectedOption)")

            if UIFont.familyNames.contains(selectedOption) {
                Clicky()
            }
            
            if UIFont(name: selectedOption, size: 17) != nil {
                UserDefaults.standard.set(selectedOption, forKey: "SelectedFont")
                UserDefaults.standard.synchronize()
            }
            
            func playAudio() {
                guard let index = deleteSoundOptions.firstIndex(of: selectedOption) else {
                    print("Selected option not found in deleteSoundOptions")
                    return
                }
                let list_sound = selectedOption
                var soundURL: URL?
                if let wav_type = Bundle.main.url(forResource: list_sound, withExtension: "wav") {
                    soundURL = wav_type
                    print("Playing: \(list_sound)\nOf type: wav")
                    UserDefaults.standard.set(list_sound, forKey: "list_sound")
                } else if let mp3_type = Bundle.main.url(forResource: list_sound, withExtension: "mp3") {
                    soundURL = mp3_type
                    print("Playing: \(list_sound)\nOf type: mp3")
                    UserDefaults.standard.set(list_sound, forKey: "list_sound")
                }
                if let sound_to_use = soundURL {
                    do {
                        shop_deletion_sound = try AVAudioPlayer(contentsOf: sound_to_use)
                        shop_deletion_sound?.volume = 0.7
                        shop_deletion_sound?.prepareToPlay()
                        shop_deletion_sound?.play()
                    } catch {
                        print("Error playing audio: \(error)")
                    }
                }
            }
                playAudio()

                func top_background_color(_ sender: UIColorWell) {
                    if let selectedColor = sender.selectedColor {
                        var red: CGFloat = 0
                        var green: CGFloat = 0
                        var blue: CGFloat = 0
                        var alpha: CGFloat = 0
                        selectedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                        print("Red: \(red), Green: \(green), Blue: \(blue), Alpha: \(alpha)")
                        UserDefaults.standard.set(selectedColor, forKey: "Top_selected_Background")
                        print("Selected Top Background Color: \(selectedColor)")
                    }
                }
                
                func bottom_background_color(_ sender: UIColorWell) {
                    if let selectedColor = sender.selectedColor {
                        var red: CGFloat = 0
                        var green: CGFloat = 0
                        var blue: CGFloat = 0
                        var alpha: CGFloat = 0
                        selectedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                        print("Red: \(red), Green: \(green), Blue: \(blue), Alpha: \(alpha)")
                        UserDefaults.standard.set(selectedColor, forKey: "Bottom_selected_Background")
                        print("Selected Bottom Background Color: \(selectedColor)")
                    }
                }
        }
    }
    
    @IBAction func illuminate_Selection(_ sender: UIButton) {
        Clicky()
        let selectedEntity = "Starship & TORQ"
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
            guard let soundURL = Bundle.main.url(forResource: "Gyat Chonki-Lonki", withExtension: "wav") else { return }
            do {
                Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
                Extra_sounds?.prepareToPlay()
                Extra_sounds?.volume = 0.7
                Extra_sounds?.play()
            } catch {
            }
        }
        self.selectedEntity = selectedEntity
    }

    @IBAction func ASTRAL_Selection(_ sender: UIButton) {
        let selectedEntity = "ASTRAL"
            UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
            if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
                print("Selected AI Entity: \(selectedEntity)")
                guard let soundURL = Bundle.main.url(forResource: "Bionic Dolphin Snort", withExtension: "wav") else { return }
                do {
                    Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
                    Extra_sounds?.prepareToPlay()
                    Extra_sounds?.volume = 0.7
                    Extra_sounds?.play()
                } catch {
                }
            }
            self.selectedEntity = selectedEntity
    }
    
    @IBAction func Sketches_Selection(_ sender: UIButton) {
        let selectedEntity = "Sketches"
        Clicky()
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
            guard let soundURL = Bundle.main.url(forResource: "Ethoric", withExtension: "wav") else { return }
            do {
                Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
                Extra_sounds?.prepareToPlay()
                Extra_sounds?.volume = 0.7
                Extra_sounds?.play()
            } catch {
            }
        }
        self.selectedEntity = selectedEntity
    }
    
    @IBAction func Disco_Selection(_ sender: UIButton) {
        let selectedEntity = "Disco"
        Clicky()
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
            guard let soundURL = Bundle.main.url(forResource: "Chicago Corporation", withExtension: "wav") else { return }
            do {
                Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
                Extra_sounds?.prepareToPlay()
                Extra_sounds?.volume = 0.7
                Extra_sounds?.play()
            } catch {
            }
        }
        self.selectedEntity = selectedEntity
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
    
    func List_Gradient(startColor: UIColor, endColor: UIColor) {
        onColorSelection?(startColor, endColor)
        print((startColor, endColor))
        dismiss(animated: true, completion: nil)
        delegate?.startColor = startColor
        delegate?.endColor = endColor
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Gradient> = Gradient.fetchRequest()
        request.fetchLimit = 1
        do {
            let results = try context.fetch(request)
            if let gradientEntity = results.first {
                try context.save()
                print("New gradient saved to Core Data with start color \(gradientEntity.currentStartColor!) and end color \(gradientEntity.currentEndColor!)")
            }
        } catch {
            print("Error saving gradient: \(error.localizedDescription)")
        }
    }

public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
        guard let self = self else { return }
        self.colorProgress += 0.01
        if self.colorProgress > 1.0 {
            self.colorProgress = 0.0
        }
    }
}

    func saveColorToUserDefaults(color: UIColor?, forKey key: String) {
        guard let color = color else {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
            UserDefaults.standard.set(colorData, forKey: key)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            DispatchQueue.main.async {
                let gradientView = SodaGradientView(frame: self.view.bounds)
                gradientView.layer.zPosition = -2
                gradientView.isUserInteractionEnabled = false
                self.view.addSubview(gradientView)
            }
            FontSelection.selectRow(selectedFontIndex, inComponent: 0, animated: false)
            selectedFontIndex = UserDefaults.standard.integer(forKey: "selectedFontIndex")
        selectedDeletionIndex = UserDefaults.standard.integer(forKey: "selectedDeleteSoundIndex")
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    }
    @IBOutlet weak var NEW_Fonts: UILabel!
    @IBOutlet weak var NEW_Deletions: UILabel!
    @IBOutlet weak var Gloss: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let fontsV = UIFont.familyNames.sorted()
        NEW_Fonts.text = "\(fontsV.count) NEW Fonts!"
        NEW_Deletions.text = "\(deleteSoundOptions.count) NEW Deletion Sounds!"
        if let payingCustomer = KeychainService.loadPayingCustomerStatus() {
            print("Restored Purchase Status from Keychain: \(payingCustomer)")
        } else {
            print("Unable to load restored purchase status from Keychain")
        }
        FontSelection.delegate = self
        FontSelection.dataSource = self
        DeleteSound.delegate = self
        DeleteSound.dataSource = self
        Preview_List.dataSource = self
        Preview_List.delegate = self
        
        let gradientView = SodaGradientView(frame: view.bounds)
        gradientView.layer.opacity = Float(100)
        gradientView.layer.zPosition = -2
        self.view.addSubview(gradientView)
        
        gradientView.layer.zPosition = -1
        view.addSubview(gradientView)
        gradientView.isUserInteractionEnabled = false
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Gradient> = Gradient.fetchRequest()
        request.fetchLimit = 1
        GifPlayer().PlayGif(named: "Astral_Logo", within: TagurLogo)
        
        Preview_List.backgroundColor = UIColor.clear
        if let storedDeleteSoundIndex = UserDefaults.standard.value(forKey: "selectedDeleteSoundIndex") as? Int {
            selectedDeleteSoundIndex = storedDeleteSoundIndex
        }
        if let topColorData = UserDefaults.standard.data(forKey: "topColor"),
           let bottomColorData = UserDefaults.standard.data(forKey: "bottomColor"),
           let topColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(topColorData) as? UIColor,
           let bottomColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(bottomColorData) as? UIColor {
            Text_Top_Color.selectedColor = topColor
            Text_Bottom_Color.selectedColor = bottomColor
        }
        if let Top_Background_Color = UserDefaults.standard.data(forKey: "Top_selected_Background"),
           let Top_Background_Color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Top_Background_Color) as? UIColor {
            Top_List_Background_Color.selectedColor = Top_Background_Color
            print(Top_Background_Color)
        }
        if let Bottom_Background_Color = UserDefaults.standard.data(forKey: "Bottom_selected_Background"),
           let Bottom_Background_Color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Bottom_Background_Color) as? UIColor {
            Bottom_List_Background_Color.selectedColor = Bottom_Background_Color
            print(Bottom_Background_Color)
        }
        Top_List_Background_Color.addTarget(self, action: #selector(List_Gradient_Changing(_:)), for: .valueChanged)
        Bottom_List_Background_Color.addTarget(self, action: #selector(List_Gradient_Changing(_:)), for: .valueChanged)
        Text_Top_Color.addTarget(self, action: #selector(List_Gradient_Changing(_:)), for: .valueChanged)
        Text_Bottom_Color.addTarget(self, action: #selector(List_Gradient_Changing(_:)), for: .valueChanged)
        
        configurePickerView(with: deleteSoundOptions, for: DeleteSound)
        DeleteSound.selectRow(selectedDeleteSoundIndex, inComponent: 0, animated: false)
        
        func loadFontsFromFolder(folderName: String) -> [String] {
            var fontFamilies = [String]()
            if let folderURL = Bundle.main.url(forResource: folderName, withExtension: nil) {
                do {
                    let fontURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [])
                    for fontURL in fontURLs {
                        if let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
                           let font = CGFont(fontDataProvider) {
                            if let fontName = font.postScriptName as String? {
                                fontFamilies.append(fontName)
                            }
                        } else {
                            print("Error loading font from URL:", fontURL)
                        }
                    }
                } catch {
                    print("Error loading fonts from folder:", error)
                }
            }
            return fontFamilies
        }

        let fonts = UIFont.familyNames.sorted()
        print(fonts, fonts.count)
        print("Fonts are at count", fonts.count)
        print("Deletion sounds are at count", deleteSoundOptions.count)

        selectedDeletionIndex = UserDefaults.standard.integer(forKey: "selectedDeleteSoundIndex")
        configurePickerView(with: fonts, for: FontSelection)
        FontSelection.selectRow(selectedFontIndex, inComponent: 0, animated: false)
        selectedFontIndex = UserDefaults.standard.integer(forKey: "selectedFontIndex")
    }
}

extension UIColor {
    func interpolateColorToShop(_ endColor: UIColor, fraction: CGFloat) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        endColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let r = (1 - f) * r1 + f * r2
        let g = (1 - f) * g1 + f * g2
        let b = (1 - f) * b1 + f * b2
        let a = (1 - f) * a1 + f * a2
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension NSTextAlignment {
    func toCATextLayerAlignmentMode() -> CATextLayerAlignmentMode {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        case .justified:
            return .justified
        case .natural:
            return .natural
        @unknown default:
            fatalError("Unexpected NSTextAlignment value.")
        }
    }
}

protocol FontSelectionDelegate: AnyObject {
    func didSelectFont(_ font: String)
}

extension UIPickerView {
    struct AssociatedKeys {
        static var userInfo = "userInfo"
    }
    
    var userInfo: [String: Any]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.userInfo) as? [String: Any]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.userInfo, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

extension UIColor {
    func Background_interpolateColorTo(_ endColor: UIColor, fraction: CGFloat) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        endColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let r = (1 - f) * r1 + f * r2
        let g = (1 - f) * g1 + f * g2
        let b = (1 - f) * b1 + f * b2
        let a = (1 - f) * a1 + f * a2
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
} 
