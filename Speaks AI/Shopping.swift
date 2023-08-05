//
//  SHOP.swift
//  Speaks AI
//
//  Created by IAL VECTOR on 3/30/23.
//

import Foundation
import AVFoundation
import UIKit
import MessageUI
import CoreData
import StoreKit


public class SHOP: UIViewController, MFMailComposeViewControllerDelegate, ColorChangeDelegate {
    var startColor: UIColor = .gray
    var endColor: UIColor = .gray
    weak var delegate: ColorChangeDelegate?
    var colorProgress: CGFloat = 0.0
    var viewController: ViewController?
    var gradientEntity: Gradient?
    var onColorSelection: ((UIColor, UIColor) -> Void)?
    weak var colorChangeDelegate: ColorChangeDelegate?
    @IBOutlet weak var Email_Me: UILabel!
    var timer: Timer?
    @IBOutlet weak var Jalapeno_Description: UILabel!
    var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var Request: UIButton!
    @IBOutlet weak var Pastel_Description: UILabel!
    @IBOutlet weak var Mango_Description: UILabel!
    @IBOutlet weak var Watermelon_Description: UILabel!
    @IBOutlet weak var Swimming_Description: UILabel!
    @IBOutlet weak var LemonLime_Description: UILabel!
    @IBOutlet weak var Cafe_Description: UILabel!
    @IBOutlet weak var Summer_Lemonades: UILabel!
    @IBOutlet weak var Cooldown_Description: UILabel!
    @IBOutlet weak var Beach_Description: UILabel!
    var currentImageName = "TAGUR_BATTERY_4"
    static let shared = AppDelegate()
    var CustomerEntity: Customer?
    weak var fontSelectionDelegate: FontSelectionDelegate?
    var selectedFont: String?
    var managedObjectContext: NSManagedObjectContext!
    var Font_Entity: Font_Entity!

    
    
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
        // Dismiss the mail compose view controller
        controller.dismiss(animated: true, completion: nil)
        
        // Show a confirmation alert if the email was sent successfully
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
        mailComposerVC.setToRecipients(["cosmonautEBE@gmail.com"])
        mailComposerVC.setSubject("New Product Request")
        mailComposerVC.setMessageBody("I would like to request a new product for the store.\n\nProduct Name: \(productName)\nDescription: \(description)", isHTML: false)
        return mailComposerVC
    }
    
    
    @IBAction func requestButtonPressed(_ sender: UIButton) {
        ()
        Clicky()
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
            let alertController = UIAlertController(title: "Request a Product", message: "Fill out the information below to request a new product for this store:", preferredStyle: .alert)
            
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
    
    
    

    func Clicky() {
        guard let soundURL = Bundle.main.url(forResource: "Selected", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.7 // Adjust volume here
            audioPlayer?.play()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }
    
    
    func List_Gradient(startColor: UIColor, endColor: UIColor) {
        onColorSelection?(startColor, endColor)
        print((startColor, endColor))
        
        if let mainViewController = presentingViewController as? ViewController {
            //mainViewController.setColors(startColor: startColor, endColor: endColor)
        }
        dismiss(animated: true, completion: nil)
        
        delegate?.startColor = startColor
        delegate?.endColor = endColor
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Gradient> = Gradient.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let gradientEntity = results.first {
//                gradientEntity.currentStartColor = startColor
//                gradientEntity.currentEndColor = endColor
                try context.save()
                print("New gradient saved to Core Data with start color \(gradientEntity.currentStartColor!) and end color \(gradientEntity.currentEndColor!)")
            }
        } catch {
            print("Error saving gradient: \(error.localizedDescription)")
        }
    }
    
    @IBAction func Jalapeno_List_SELECTED(_ sender: UIButton) {
        Clicky()
        
        if ViewController.passive_income_customer {
            let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemRed, requiringSecureCoding: false)
            let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemGreen, requiringSecureCoding: false)

            UserDefaults.standard.set(startColorData, forKey: "startColor")
            UserDefaults.standard.set(endColorData, forKey: "endColor")

            // Call the setColors function in the second view controller to update the colors
            if let secondViewController = self.presentingViewController as? ViewController {
                secondViewController.setColors()
            }

            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }





@IBAction func Universal_Deluxe_List_SELECTED(_ sender: UIButton) {
    Clicky()
    
    if ViewController.passive_income_customer {
        let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemCyan, requiringSecureCoding: false)
        let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemPurple, requiringSecureCoding: false)

        UserDefaults.standard.set(startColorData, forKey: "startColor")
        UserDefaults.standard.set(endColorData, forKey: "endColor")

        // Call the setColors function in the second view controller to update the colors
        if let secondViewController = self.presentingViewController as? ViewController {
            secondViewController.setColors()
        }

        dismiss(animated: true, completion: nil)
    } else {
        Alert_Non_Subscriber()
    }
}

@IBAction func Beach_List_SELECTED(_ sender: UIButton) {
    Clicky()
    
    if ViewController.passive_income_customer {
        let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemBlue, requiringSecureCoding: false)
        let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemBrown, requiringSecureCoding: false)

        UserDefaults.standard.set(startColorData, forKey: "startColor")
        UserDefaults.standard.set(endColorData, forKey: "endColor")

        // Call the setColors function in the second view controller to update the colors
        if let secondViewController = self.presentingViewController as? ViewController {
            secondViewController.setColors()
        }

        dismiss(animated: true, completion: nil)
    } else {
        Alert_Non_Subscriber()
    }
}

@IBAction func CooldownSlush_List_SELECTED(_ sender: UIButton) {
    Clicky()
    
    if ViewController.passive_income_customer {
        let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemRed, requiringSecureCoding: false)
        let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemBlue, requiringSecureCoding: false)

        UserDefaults.standard.set(startColorData, forKey: "startColor")
        UserDefaults.standard.set(endColorData, forKey: "endColor")

        // Call the setColors function in the second view controller to update the colors
        if let secondViewController = self.presentingViewController as? ViewController {
            secondViewController.setColors()
        }

        dismiss(animated: true, completion: nil)
    } else {
        Alert_Non_Subscriber()
    }
}

    @IBAction func Mango_List_SELECTED(_ sender: UIButton) {
        Clicky()
        
        if ViewController.passive_income_customer {
            let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemOrange, requiringSecureCoding: false)
            let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemGreen, requiringSecureCoding: false)

            UserDefaults.standard.set(startColorData, forKey: "startColor")
            UserDefaults.standard.set(endColorData, forKey: "endColor")

            // Call the setColors function in the second view controller to update the colors
            if let secondViewController = self.presentingViewController as? ViewController {
                secondViewController.setColors()
            }

            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }

@IBAction func SourWatermelon_List_SELECTED(_ sender: UIButton) {
    Clicky()
    
    if ViewController.passive_income_customer {
        let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemPink, requiringSecureCoding: false)
        let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemGreen, requiringSecureCoding: false)

        UserDefaults.standard.set(startColorData, forKey: "startColor")
        UserDefaults.standard.set(endColorData, forKey: "endColor")

        // Call the setColors function in the second view controller to update the colors
        if let secondViewController = self.presentingViewController as? ViewController {
            secondViewController.setColors()
        }

        dismiss(animated: true, completion: nil)
    } else {
        Alert_Non_Subscriber()
    }
}


@IBAction func SummerLemonades_List_SELECTED(_ sender: UIButton)  {
    Clicky()
    
    if ViewController.passive_income_customer {
        let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemYellow, requiringSecureCoding: false)
        let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemPink, requiringSecureCoding: false)

        UserDefaults.standard.set(startColorData, forKey: "startColor")
        UserDefaults.standard.set(endColorData, forKey: "endColor")

        // Call the setColors function in the second view controller to update the colors
        if let secondViewController = self.presentingViewController as? ViewController {
            secondViewController.setColors()
        }

        dismiss(animated: true, completion: nil)
    } else {
        Alert_Non_Subscriber()
    }
}

@IBAction func LemonLimeSparklingWater_List_SELECTED(_ sender: UIButton)  {
    Clicky()
    
    if ViewController.passive_income_customer {
        let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemYellow, requiringSecureCoding: false)
        let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemGreen, requiringSecureCoding: false)

        UserDefaults.standard.set(startColorData, forKey: "startColor")
        UserDefaults.standard.set(endColorData, forKey: "endColor")

        // Call the setColors function in the second view controller to update the colors
        if let secondViewController = self.presentingViewController as? ViewController {
            secondViewController.setColors()
        }

        dismiss(animated: true, completion: nil)
    } else {
        Alert_Non_Subscriber()
    }
}
    
    @IBAction func SwimmingPool_List_SELECTED(_ sender: UIButton)  {
        Clicky()
        
        if ViewController.passive_income_customer {
            let startColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemBlue, requiringSecureCoding: false)
            let endColorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor.systemCyan, requiringSecureCoding: false)

            UserDefaults.standard.set(startColorData, forKey: "startColor")
            UserDefaults.standard.set(endColorData, forKey: "endColor")

            // Call the setColors function in the second view controller to update the colors
            if let secondViewController = self.presentingViewController as? ViewController {
                secondViewController.setColors()
            }

            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }

    @IBAction func Clear_Gel_SELECTED(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let colorData = NSKeyedArchiver.archivedData(withRootObject: UIColor.clear)
            UserDefaults.standard.set(colorData, forKey: "Cell_Background")
            dismiss(animated: true, completion: nil)
        }
             else {
                Alert_Non_Subscriber()
            }
        }
    
    @IBAction func Red_Pool_SELECTED(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let darkRedColor = UIColor(red: 50/255, green: 0, blue: 0, alpha: 1.0)
            let darkRedColorData = NSKeyedArchiver.archivedData(withRootObject: darkRedColor)
            UserDefaults.standard.set(darkRedColorData, forKey: "Cell_Background")

            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }

    
    @IBAction func Orange_Citrus_SELECTED(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let excessivelyDarkOrangeColor = UIColor(red: 100/255, green: 25/255, blue: 0, alpha: 1.0)
            let excessivelyDarkOrangeColorData = try? NSKeyedArchiver.archivedData(withRootObject: excessivelyDarkOrangeColor, requiringSecureCoding: false)
            UserDefaults.standard.set(excessivelyDarkOrangeColorData, forKey: "Cell_Background")

            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }



    
    
    @IBAction func Electricity_Cells(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let darkYellowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            let darkYellowColorData = try? NSKeyedArchiver.archivedData(withRootObject: darkYellowColor, requiringSecureCoding: false)
            UserDefaults.standard.set(darkYellowColorData, forKey: "Cell_Background")

            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }

    @IBAction func Leafy_Greens(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let darkGreenColor = UIColor(red: 0/255, green: 40/255, blue: 0/255, alpha: 1.0)
            let darkGreenColorData = try? NSKeyedArchiver.archivedData(withRootObject: darkGreenColor, requiringSecureCoding: false)
            UserDefaults.standard.set(darkGreenColorData, forKey: "Cell_Background")

            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


    @IBAction func Serious_Font_SELECTED(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Snell Roundhand"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }



    
    @IBAction func TypewriterFont_SELECTED(_ sender: UIButton) {
            Clicky()

            if ViewController.passive_income_customer {
                let selectedFont = "American Typewriter Condensed"
                UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
                if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                    print("Selected Font: \(selectedFont)")
                }
                self.selectedFont = selectedFont
                dismiss(animated: true, completion: nil)
            } else {
                Alert_Non_Subscriber()
            }
        }

    
    @IBAction func Example_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Copperplate"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Extra_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "SignPainter-HouseScript"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Rater_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Sinhala Sangam MN"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Dark_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Gill Sans"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Marker_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Impact"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Thicko_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Georgia"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Nice_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Futura"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Funtime_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Papyrus"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Chalky_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Chalkduster"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Love_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Chalkboard SE"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Rockwell_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Rockwell"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }
    
    @IBAction func Menlo_Font(_ sender: UIButton) {
        Clicky()
        if ViewController.passive_income_customer {
            let selectedFont = "Menlo"
            UserDefaults.standard.set(selectedFont, forKey: "SelectedFont")
            if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
                print("Selected Font: \(selectedFont)")
            }
            self.selectedFont = selectedFont
            dismiss(animated: true, completion: nil)
        } else {
            Alert_Non_Subscriber()
        }
    }


    
//    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "Main" {
//            if let destinationVC = segue.destination as? ViewController {
//                destinationVC.selectedFont = self.selectedFont
//            }
//        }
//    }


    








func start_Gradient_Timer() {
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
        guard let self = self else { return }
        self.colorProgress += 0.01
        if self.colorProgress > 1.0 {
            self.colorProgress = 0.0
        }
    }
}

    

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ValueTransformer.setValueTransformer(ColorTransformer(), forName: NSValueTransformerName(rawValue: "ColorTransformer"))
    return true
}


@objc func refresh() {
}

func setColors(startColor: UIColor, endColor: UIColor) {
    // your implementation to set the gradient colors goes here
}

class ColorTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else {
            return nil
        }
        return NSKeyedArchiver.archivedData(withRootObject: color)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
    }
}

func Chalk_And_Fitting(label: UILabel, font: UIFont, minimumScaleFactor: CGFloat) {
    label.font = font
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.2
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






public override func viewDidLoad() {
    super.viewDidLoad()
    let gradientView = GradientView(frame: view.bounds)
    gradientView.layer.zPosition = -1
    view.addSubview(gradientView)
    gradientView.isUserInteractionEnabled = false

    
    _ = UIFont(name: "Chalkduster", size: 16)!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // Fetch the most recent gradient entity
    let request: NSFetchRequest<Gradient> = Gradient.fetchRequest()
    request.fetchLimit = 1
    
    do {
        let results = try context.fetch(request)
        guard let gradientEntity = results.first else {
            // If no gradient entity was found, set default colors
            setColors(startColor: UIColor.systemBlue, endColor: UIColor.systemPurple)
            return
        }
        // If a gradient entity was found, set the view's background colors
        let startColor = gradientEntity.currentStartColor as? UIColor ?? UIColor.systemBlue
        let endColor = gradientEntity.currentEndColor as? UIColor ?? UIColor.systemPurple
        setColors(startColor: startColor, endColor: endColor)
        print("Current start color is: \(startColor), current end color is: \(endColor)")
    } catch {
        print("Error fetching gradient: \(error.localizedDescription)")
    }
    
    
    timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    
    


    
    
    Chalk_And_Fitting(label: Jalapeno_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: Pastel_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: Beach_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: Cooldown_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: Mango_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: Watermelon_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: Summer_Lemonades, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: Cafe_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: LemonLime_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    Chalk_And_Fitting(label: Swimming_Description, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
    
    Chalk_And_Fitting(label: Email_Me, font: UIFont(name: "Chalkduster", size: 16)!, minimumScaleFactor: 0.2)
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
