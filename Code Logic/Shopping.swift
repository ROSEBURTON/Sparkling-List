import UIKit
import Foundation
import AVFoundation
import MessageUI
import CoreData
import StoreKit

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
var deleteSoundOptions = ["ATL Night Rain", "Aflame Procrasination", "Assimilation", "Calculated", "Censorship", "Chalkboard", "Cybernetic Models", "Dealt With", "Electro Shock", "Fart", "Glass Shatter", "Hotel Pool", "Laser", "Last Meal", "Loading Productive Ammo", "Lost Signal", "Mantid\'s Observation", "Miss Computer Email", "Missile Hit", "Nuclear Ending", "Omit", "Out of Bounds", "Pleased Watching Mantid", "Ready for Takeoff", "Rewiring", "Sea Mine", "Signal", "Static", "Submerge", "Vegan Muncher", "Барыня"]
let sortedOptions = deleteSoundOptions.sorted()


//Scroll Store:
// scroll view at 0 , 0 , 0 , 0. Add 4 constraints

// mini view contraints 0 , 0 , 0 , 0, specify height of SHOP. Add 5 constraints

// mini view control drag to main view , equal widths, equal heights
// 1750

public class SHOP: UIViewController, MFMailComposeViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var Background_Play_Options = ["The Primal Dexxacon", "Warping Speed", "Chinese Characters"]
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
    var viewController: Main?
    var gradientEntity: Gradient?
    var onColorSelection: ((UIColor, UIColor) -> Void)?
    weak var colorChangeDelegate: ColorChangeDelegate?
    @IBOutlet weak var Email_Me: UILabel!
    var timer: Timer?
    @IBOutlet weak var Request: UIButton!
    static let shared = AppDelegate()
    weak var fontSelectionDelegate: FontSelectionDelegate?
    var selectedFont: String?
    var selected_Background: String?
    var selectedEntity: String?
    var managedObjectContext: NSManagedObjectContext!
    var shop_deletion_sound: AVAudioPlayer?
    var Font_Entity: Font_Entity!
    var fonts: [String] = []
    @IBOutlet weak var FontSelection: UIPickerView!
    @IBOutlet weak var DeleteSound: UIPickerView!

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
            print("Playing: \(String(describing: list_sound))\nOf type: wav")
             UserDefaults.standard.set(list_sound, forKey: "list_sound")
        } else if let mp3_type = Bundle.main.url(forResource: list_sound, withExtension: "mp3") {
            soundURL = mp3_type
            print("Playing: \(String(describing: list_sound))\nOf type: mp3")
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
        if sender == Text_Top_Color {
            let topColor = sender.selectedColor
            saveColorToUserDefaults(color: topColor, forKey: "topColor")
            print("Top Text Color: \(String(describing: topColor))")
        }
        else if sender == Text_Bottom_Color {
            let bottomColor = sender.selectedColor
            saveColorToUserDefaults(color: bottomColor, forKey: "bottomColor")
            print("Bottom Text Color: \(String(describing: bottomColor))")
        }
        else if sender == Top_List_Background_Color {
            let Top_selected_Background = sender.selectedColor
            saveColorToUserDefaults(color: Top_selected_Background, forKey: "Top_selected_Background")
            print("Top Background Color: \(String(describing: Top_selected_Background))")
        }
        else if sender == Bottom_List_Background_Color {
            let Bottom_selected_Background = sender.selectedColor
            saveColorToUserDefaults(color: Bottom_selected_Background, forKey: "Bottom_selected_Background")
            print("Bottom Background Color: \(String(describing: Bottom_selected_Background))")
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
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title: String?
        if pickerView == DeleteSound {
            title = deleteSoundOptions[row]
        } else if let options = pickerView.userInfo?["options"] as? [String] {
            title = options[row]
        } else {
            title = nil
        }

        if let unwrappedTitle = title {
            let font_names = UIFont.familyNames.first
            let attributes: [NSAttributedString.Key: Any] = [
                .strokeWidth: 8,
                .strokeColor: UIColor.blue

            ]
            return NSAttributedString(string: unwrappedTitle, attributes: attributes)
        }
        return nil
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
                if selectedOption == deleteSoundOptions[row] {
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
                        }
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
    
    func Alert_Non_Subscriber() {
        let alertController = UIAlertController(title: nil, message: "List Gradient Colors\n are for Paying Customers \n\n - Stealing is not Permitted \n\n If no current store items interest you right now, make a product request at the bottom of this page so we can add your desired product", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        if let topViewController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController {
            if let presentedViewController = topViewController.presentedViewController {
                presentedViewController.present(alertController, animated: true, completion: nil)
            } else {
                topViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        if result == .sent {
            let alert = UIAlertController(title: "Confirmation", message: "Product request was sent.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func configureMailController(productName: String, description: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["chromium.geo@gmail.com"])
        mailComposerVC.setSubject("New Product Request")
        mailComposerVC.setMessageBody("I would like to request a new product for the store.\n\nProduct Name: \(productName)\nDescription: \(description)", isHTML: false)
        return mailComposerVC
    }

    @IBAction func Tagur_Selection(_ sender: UIButton) {
            Clicky()
        let selectedEntity = "TAGUR"
            UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
            if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
                print("Selected AI Entity: \(selectedEntity)")
            }
            self.selectedEntity = selectedEntity
    }
    
    @IBAction func Sunday_Selection(_ sender: UIButton) {
        Clicky()
        let selectedEntity = "Sunday"
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
        }
        self.selectedEntity = selectedEntity
    }
    
    @IBAction func Jerk_Beefy_Selection(_ sender: UIButton) {
        Clicky()
        let selectedEntity = "Scribble"
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
        }
        self.selectedEntity = selectedEntity
    }
    
    @IBAction func Disco_Dime_Selection(_ sender: UIButton) {
        Clicky()
        let selectedEntity = "Disco"
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
        }
        self.selectedEntity = selectedEntity
    }
    
    @IBAction func Seductress_Selection(_ sender: UIButton) {
        Clicky()
        let selectedEntity = "Seductress"
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
        }
        self.selectedEntity = selectedEntity
    }
    
    @IBAction func Sketches_Selection(_ sender: UIButton) {
        let selectedEntity = "Sketches"
        Clicky()
        UserDefaults.standard.set(selectedEntity, forKey: "Selected_AI_Entity")
        if let selectedEntity = UserDefaults.standard.string(forKey: "Selected_AI_Entity") {
            print("Selected AI Entity: \(selectedEntity)")
        }
        self.selectedEntity = selectedEntity
    }

    @IBAction func requestButtonPressed(_ sender: UIButton) {
        Clicky()
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
            let alertController = UIAlertController(title: "Request a Product", message: "Fill out the information below to request a new product for the Shop:", preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Product Name"
            }
            alertController.addTextField { textField in
                textField.placeholder = "Description"
            }
            let sendAction = UIAlertAction(title: "Send", style: .default) { action in
                guard let productName = alertController.textFields?[0].text,
                      let description = alertController.textFields?[1].text else {
                    return
                }
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeViewController = self.configureMailController(productName: productName, description: description)
                    mailComposeViewController.mailComposeDelegate = self
                    self.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Unable to send email", message: "Are you connected to your mail account? Your product was unable to be sent to the shop owner through email, try again after connecting account.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(sendAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func Clicky() { // forResource: "Selected", wav
        guard Bundle.main.url(forResource: "generated_audio", withExtension: "wav") != nil else { return }
        do {
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
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
            FontSelection.selectRow(selectedFontIndex, inComponent: 0, animated: false)
            selectedFontIndex = UserDefaults.standard.integer(forKey: "selectedFontIndex")
    }

    @IBAction func LinkedIn(_ sender: UIButton) {
        medium_haptic.impactOccurred()
        Clicky()
        if let url = URL(string: "https://www.linkedin.com/in/orioncait") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: Top of MEMORY crash
    public override func viewDidLoad() {
        super.viewDidLoad()
        print(sortedOptions)
        
        FontSelection.delegate = self
        FontSelection.dataSource = self
        DeleteSound.delegate = self
        DeleteSound.dataSource = self
        Preview_List.dataSource = self
        Preview_List.delegate = self
        let gradientView = GradientView(frame: view.bounds)
        gradientView.layer.zPosition = -1
        view.addSubview(gradientView)
        gradientView.isUserInteractionEnabled = false
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Gradient> = Gradient.fetchRequest()
        request.fetchLimit = 1
        GifPlayer().playGif(named: "TagurLogo", in: TagurLogo)
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
        configurePickerView(with: fonts, for: FontSelection)
        FontSelection.selectRow(selectedFontIndex, inComponent: 0, animated: false)
        selectedFontIndex = UserDefaults.standard.integer(forKey: "selectedFontIndex")
    }
    //MARK: Bottom of MEMORY crash
    
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