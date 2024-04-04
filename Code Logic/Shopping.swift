import UIKit
import StoreKit
import CoreData
import Foundation
import AVFoundation

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

var selectedFontIndex: Int = 0
var selectedDeletionIndex: Int = 0
var deleteSoundOptions = ["@*!+-R", "Bakin' Dat Pizza", "Pink Gladiate Soda", "Audio Interference", "Beyond the Lies", "Big Purr", "Blasted", "Buzzed Up", "Chalkboard", "Coming Near You", "Cybernetic Models", "Dealt With", "Dented Metal", "Fart", "Glass Shatter", "Gold", "Gyat Chonki-Lonki", "Laser", "Loading Productive Ammo", "Miss Computer Email", "Missile Hit", "Nuclear Ending", "PB & J", "Pleased Observing Mantid", "Productive Prep", "Ready for Takeoff", "Sea Mine", "Signal", "Submerge", "Toxic Combo Book burning discrediting lying gaslighters", "Type Ship", "Pizza Deluxe", "W.A.S.P", "Water Lurk", "Within the void"].sorted()

//Scroll Store:
// scroll view at 0 , 0 , 0 , 0. Add 4 constraints
// mini view contraints 0 , 0 , 0 , 0, specify height of SHOP. Add 5 constraints
// mini view control drag to main view , equal widths, equal heights
// 1750

public class SHOP: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, SKRequestDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
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
    
    // MARK: - PAYMENTS
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func AutoPaymentSuggest() {
        if let product = subscriptionProduct {
            let priceFormatter = NumberFormatter()
            priceFormatter.numberStyle = .currency
            priceFormatter.locale = product.priceLocale
            let formattedPrice = priceFormatter.string(from: product.price) ?? "$3.99"
            let alertController = UIAlertController(title: "Subscribe", message: "Subscribe for \(formattedPrice) a month and gain access to benefits such as \nCustom List Gradient Colors for both Text and Task Background\nThis supports the creator, keeping the sparkling carbonation flowing as well", preferredStyle: .alert)
            let subscribeAction = UIAlertAction(title: "Subscribe", style: .default) { _ in
                self.purchaseSubscription(product: product)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(subscribeAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else {
            let genericAlertController = UIAlertController(title: "Cannot Connect to Store", message: "Please check your internet connection and try shopping later.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            genericAlertController.addAction(okAction)
            present(genericAlertController, animated: true, completion: nil)
        }
        if SKPaymentQueue.canMakePayments() {
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()
        } else {
            showSubscriptionAlert(message: "In-app purchases are disabled on this device.")
        }
    }

    func fetchSubscriptionProduct() {
        let productIdentifiers: Set<String> = ["SparklingChromeProductID"]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    var isSubscribed = false

    func isUserSubscribed() -> Bool {
        if !isSubscribed {
            //showSubscriptionAlert(message: "For customers only. Subscribe to access customizable list colors, fonts, and deletion sounds.")
        }
        return isSubscribed
    }

    public func requestDidFinish(_ request: SKRequest) {
        isUserSubscribed()
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Receipt refresh request failed with error: \(error.localizedDescription)")
    }
    
    
    func ReceiptValidator() {
    }
    
    func updateSubscriptionStatus() {

    }


    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                validateReceipt(for: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                // Update subscription status here
                updateSubscriptionStatus()
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                fatalError("Unknown payment transaction state.")
            }
        }
    }


    private func validateReceipt(for transaction: SKPaymentTransaction) {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return
        }

        guard let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
            return
        }
        
        let appSpecificSharedSecret = "7208390e598445d4aee9637d4e6d008b"

        let receiptValidationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"
        guard let receiptValidationURL = URL(string: receiptValidationURLString) else {
            return
        }
        
        var request = URLRequest(url: receiptValidationURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["receipt-data": receiptData.base64EncodedString(), "password": appSpecificSharedSecret])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
            }
        }.resume()
    }

    func purchaseSubscription(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    @objc(productsRequest:didReceiveResponse:) public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            subscriptionProduct = product
        }
    }

    func showSubscriptionAlert(message: String) {
//        let alert = UIAlertController(title: "Subscription Required", message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alert.addAction(okAction)
//        present(alert, animated: true, completion: nil)
    }
    // MARK: - PAYMENTS



    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _ = UserDefaults.standard.data(forKey: "Top_selected_Background")
        _ = UserDefaults.standard.data(forKey: "Bottom_selected_Background")
        return 2
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
        let progress = (CGFloat(indexPath.row) / CGFloat(Combined_missions.count) + colorProgress).truncatingRemainder(dividingBy: 1.0)
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        if let topColorData = UserDefaults.standard.data(forKey: "topColor"),
           let bottomColorData = UserDefaults.standard.data(forKey: "bottomColor"),
           let Top_Background_Color_Data = UserDefaults.standard.data(forKey: "Top_selected_Background"),
           let Bottom_Background_Color_Data = UserDefaults.standard.data(forKey: "Bottom_selected_Background"),
           let topColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(topColorData) as? UIColor,
           let bottomColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(bottomColorData) as? UIColor {
            let textColor = topColor.interpolateColorTo(bottomColor, fraction: progress)
            cell.textLabel?.textColor = textColor
            let topBackgroundColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Top_Background_Color_Data) as? UIColor
            let bottomBackgroundColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Bottom_Background_Color_Data) as? UIColor
            if let topBackgroundColor = topBackgroundColor, let bottomBackgroundColor = bottomBackgroundColor {
                if indexPath.row == 0 {
                    if let topBackgroundColorData = UserDefaults.standard.data(forKey: "Top_selected_Background") {
                        let topBackgroundColor = NSKeyedUnarchiver.unarchiveObject(with: topBackgroundColorData) as? UIColor
                        cell.backgroundColor = topBackgroundColor
                    }
                } else if indexPath.row == 1 {
                    if let bottomBackgroundColorData = UserDefaults.standard.data(forKey: "Bottom_selected_Background") {
                        let bottomBackgroundColor = NSKeyedUnarchiver.unarchiveObject(with: bottomBackgroundColorData) as? UIColor
                        cell.backgroundColor = bottomBackgroundColor
                    }
                }
            } else {
                print("Background Colors not found in UserDefaults")
            }
        } else {
            print("Colors not found in UserDefaults")
        }
        if indexPath.row == 0 {
            if let topColorData = UserDefaults.standard.data(forKey: "topColor"),
               let topColor = NSKeyedUnarchiver.unarchiveObject(with: topColorData) as? UIColor {
                   cell.textLabel?.textColor = topColor
               } else {
                   cell.textLabel?.textColor = UIColor.green
               }
        } else {
            if let bottomColorData = UserDefaults.standard.data(forKey: "bottomColor"),
               let bottomColor = NSKeyedUnarchiver.unarchiveObject(with: bottomColorData) as? UIColor {
                   cell.textLabel?.textColor = bottomColor
               } else {
                   cell.textLabel?.textColor = UIColor.red
               }
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

        if !isUserSubscribed() {
            showSubscriptionAlert(message: "List gradient customization requires a subscription. Subscribe to access this feature.")
            AutoPaymentSuggest()
            return
        } else {
            if sender == Text_Top_Color {
                let topColor = sender.selectedColor
                saveColorToUserDefaults(color: topColor, forKey: "topColor")
                print("Top Text Color: \(String(describing: topColor))")
            } else if sender == Text_Bottom_Color {
                let bottomColor = sender.selectedColor
                saveColorToUserDefaults(color: bottomColor, forKey: "bottomColor")
                print("Bottom Text Color: \(String(describing: bottomColor))")
            } else if sender == Top_List_Background_Color {
                let topSelectedBackground = sender.selectedColor
                saveColorToUserDefaults(color: topSelectedBackground, forKey: "Top_selected_Background")
                print("Top Background Color: \(String(describing: topSelectedBackground))")
            } else if sender == Bottom_List_Background_Color {
                let bottomSelectedBackground = sender.selectedColor
                saveColorToUserDefaults(color: bottomSelectedBackground, forKey: "Bottom_selected_Background")
                print("Bottom Background Color: \(String(describing: bottomSelectedBackground))")
            }
            Preview_List.reloadData()
        }
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
    
    @IBAction func Sunday_Selection(_ sender: UIButton) {
        Clicky()
        let selectedEntity = "Sunday"
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
            
            
            guard let soundURL = Bundle.main.url(forResource: "Water Lurk", withExtension: "wav") else { return }
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
                
                guard let soundURL = Bundle.main.url(forResource: "Big Purr", withExtension: "wav") else { return }
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
            
            
            guard let soundURL = Bundle.main.url(forResource: "Far Outta Here Skatin' Rink", withExtension: "wav") else { return }
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
        // MARK: SODA
        // ===========================================================
            DispatchQueue.main.async {
                let gradientView = SodaGradientView(frame: self.view.bounds)
                gradientView.layer.opacity = Float(opacity)
                gradientView.layer.zPosition = -2
                gradientView.isUserInteractionEnabled = false
                self.view.addSubview(gradientView)
            }
            
            if day_actions_goal == 0 {
                opacity = 0
            } else {
                opacity = 100
            }
            let opacityPercentage = Int(opacity * 100)
            print("\n\n\n\n** Soda Gradient at 100% soda here")
            //===========================================================
        
            FontSelection.selectRow(selectedFontIndex, inComponent: 0, animated: false)
            selectedFontIndex = UserDefaults.standard.integer(forKey: "selectedFontIndex")
        selectedDeletionIndex = UserDefaults.standard.integer(forKey: "selectedDeleteSoundIndex")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        


        SKPaymentQueue.default().add(self)
        fetchSubscriptionProduct()

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
        GifPlayer().PlayGif(named: "TagurLogo", within: TagurLogo)
        let preferredLanguages = Locale.preferredLanguages
        print(preferredLanguages)
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
        fonts = UIFont.familyNames.sorted()
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
