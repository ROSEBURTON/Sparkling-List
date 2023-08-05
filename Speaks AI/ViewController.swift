//Created by Orion Cait on 3/25/23.
import UIKit
import StoreKit
import CoreData
import AVFoundation

protocol ColorChangeDelegate: AnyObject {
    var startColor: UIColor { get set }
    var endColor: UIColor { get set }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, ColorChangeDelegate, SKStoreProductViewControllerDelegate, SKProductsRequestDelegate, AVAudioPlayerDelegate {
    let motivationalStrings = [
        "Small progress is still progress.",
        "Do it now. Sometimes later becomes never.",
        "Your only limit is the amount of action you take.",
        "Believe you can and you're halfway there.",
        "Focus on progress, not perfection.",
        "Action is the foundational key to all success.",
        "Don't let yesterday take up too much of today.",
        "The secret of getting ahead is getting started.",
        "The future depends on what you do today.",
        "You don't have to be great to start, but you have to start to be great.",
        "Wake up with determination, go to bed with satisfaction.",
        "The only way to do great work is to love what you do, reward yourself.",
        "The best way to predict the future is to create it.",
        "If you want to achieve greatness, stop asking for permission.",
        "Your time is limited, don't waste it living someone else's life.",
        "Stop watching the clock; instead, mimic its steady progress and persevere.",
        "Strive for progress, not perfection.",
        "You are never too old to set another goal or to dream a new dream.",
        "Believe in yourself and all that you are. Know that there is something inside you that is greater than any obstacle.",
        "The only place where success comes before work is in the dictionary.",
        "Don't wait for opportunity. Create it.",
        "The difference between ordinary and extraordinary is that little extra.",
        "The man who moves a mountain begins by carrying away small stones.",
        "The doubts we hold today are the only thing that can limit tomorrow's potential."
    ]
    
    var userTextInput = UserDefaults.standard.string(forKey: "EndOfDayText")
    let initialLabelText = "Today, I'll:"
    var repopulate_subscription_ask = true
    static var passive_income_customer = false
    var day_actions_max = 50
    var startColor: UIColor = .systemMint
    var endColor: UIColor = .systemPurple
    let currentDate = Date()
    let calendar = Calendar.current
    var I_agree_to_shop = false
    
    var selectedFont: String? {
        return UserDefaults.standard.string(forKey: "SelectedFont")
    }

    var isCountdownOver = false
    var colorProgress: CGFloat = 0.0
    var audioPlayer: AVAudioPlayer?
    let persistentContainer = NSPersistentContainer(name: "Speaks_AI")
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var FARTaudioPlayer: AVAudioPlayer?
    var ALERTaudioPlayer: AVAudioPlayer?
    var timer: Timer?
    var Countdown_From_Number: TimeInterval = 180
    var countdownStartTime: Date?
    var countdownEndTime: Date?
    @IBOutlet weak var Scribble: UIImageView!
    @IBOutlet weak var MissionCounter: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var TagurAI: UIImageView!
    @IBOutlet weak var Red_Timer_Outline: UIImageView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var countdownButton: UIButton!
    @IBOutlet weak var endDayTextField: UITextField!
    @IBOutlet weak var Blue_Button: UIImageView!
    @IBOutlet weak var CurrentSong: UILabel!
    var managedObjectContext: NSManagedObjectContext!
    var fontEntity: Font_Entity?
    var cellBackground: String?
    var products: [SKProduct] = []
    let productID = "LetsGoShopping"
    
    override var shouldAutorotate: Bool {
        return false  // Disable auto-rotation
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    
    //MARK:  SHOPPING FUNCTIONALITY
    @IBAction func SHOP_Button(_ sender: UIButton) {
        guard let soundURL = Bundle.main.url(forResource: "ComputerAlert", withExtension: "wav") else { return }
        do {
            COUNTaudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            COUNTaudioPlayer?.prepareToPlay()
            COUNTaudioPlayer?.volume = 0.7
            COUNTaudioPlayer?.play()
        } catch {
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "Shop")
        present(secondViewController, animated: true, completion: nil)
        
        if ViewController.passive_income_customer == false {
            let alert = UIAlertController(title: "Subscribe", message: "Would you like to subscribe to gain access to list gradient colors?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.I_agree_to_shop = true
                guard let product = self.products.first else {
                    return
                }
                self.purchaseProduct(product)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                secondViewController.present(alert, animated: true, completion: nil)
            }
        }
        
        if I_agree_to_shop == true {
            if let transactions = SKPaymentQueue.default().transactions as? [SKPaymentTransaction] {
                for transaction in transactions {
                    if transaction.transactionState == .purchased || transaction.transactionState == .restored {
                        ViewController.passive_income_customer = true
                        break
                    } else {
                        ViewController.passive_income_customer = false
                    }
                }
            }
        }
    }


    func requestProducts() {
      let productIdentifiers = Set([productID])
      let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
      productRequest.delegate = self
      productRequest.start()
    }
    
    func purchaseProduct(_ product: SKProduct) {
      let payment = SKPayment(product: product)
      SKPaymentQueue.default().add(payment)
      guard let receiptURL = Bundle.main.appStoreReceiptURL,
        let receiptData = try? Data(contentsOf: receiptURL) else {
          return
      }
      
      let request = SKRequest()
      request.delegate = self
      let sharedSecret = "feaf0d0523a94556847f6d461dd08ee6"
      let requestParameters: [String: Any] = [
        "receipt-data": receiptData.base64EncodedString(),
        "password": sharedSecret
      ]
      guard let requestData = try? JSONSerialization.data(withJSONObject: requestParameters, options: []) else {
        return
      }
      request.start()
    }

    
    @IBAction func HABITS_Button(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let habitsViewController = storyboard.instantiateViewController(withIdentifier: "Habits") as? Habits
        present(habitsViewController!, animated: true, completion: nil)
        
        
        guard let soundURL = Bundle.main.url(forResource: "ComputerAlert", withExtension: "wav") else { return }
        do {
            COUNTaudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            COUNTaudioPlayer?.prepareToPlay()
            COUNTaudioPlayer?.volume = 0.7
            COUNTaudioPlayer?.play()
        } catch {
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
setColors()
        checkIfTomorrow()
        MissionCounter.font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)
        countdownLabel.textColor = UIColor.red
        countdownLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 17.0)
        Points_Label.font = UIFont(name: selectedFont ?? "Chalkduster", size: 24.0)
        endDayTextField.font = UIFont(name: selectedFont ?? "Chalkduster", size: 24.0)


        DispatchQueue.global().async {
            print("Customer status: \(ViewController.passive_income_customer)")
        }

        if points >= day_actions_max {
            Points_Label.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        } else {
            Points_Label.textColor = UIColor.white
        }

        
        let pointsLabelText = "List resets: \(tomorrowDateString) \n+\(points) / \(day_actions_max) actions today"
        Points_Label.text = pointsLabelText


        audioPlayer?.play()
        if countdownLabel.text == "0:00" {
            guard let soundURL = Bundle.main.url(forResource: "CountOver", withExtension: "wav") else { return }
            countdownLabel.layer.opacity = 0.0
            Red_Timer_Outline.layer.opacity = 0.0
            Blue_Button.layer.opacity = 1.0
            do {
                ALERTaudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                ALERTaudioPlayer?.prepareToPlay()
                ALERTaudioPlayer?.volume = 0.7
                ALERTaudioPlayer?.play()
            } catch {
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let savedUserTextInput = UserDefaults.standard.string(forKey: "EndOfDayText") {
            userTextInput = savedUserTextInput
            endDayTextField.text = "\(initialLabelText) \(userTextInput ?? "")"
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.colorProgress += 0.03
            if self.colorProgress > 1.0 {
                self.colorProgress = 0.0
            }
            self.tableView.reloadData()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            tableView.reloadData()
        }
    }



    func start_Gradient_Timer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.colorProgress += 0.03
            if self.colorProgress > 1.0 {
                self.colorProgress = 0.0
            }
            self.tableView.reloadData()
        }
    }



    var COUNTaudioPlayer: AVAudioPlayer?
    @IBAction func countdownButtonTapped(_ sender: UIButton) {
        if let timer = timer {
            // Stop the timer
            timer.invalidate()
            self.timer = nil
            Blue_Button.layer.opacity = 1.0
            Red_Timer_Outline.layer.opacity = 0.0
            countdownLabel.layer.opacity = 0.0

            // Reset the countdown duration and update the label
            Countdown_From_Number = 180
            countdownLabel.text = timeString(time: Countdown_From_Number)
        } else {
            // Start the timer
            countdownStartTime = Date()
            countdownEndTime = countdownStartTime?.addingTimeInterval(Countdown_From_Number)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdownLabel), userInfo: nil, repeats: true)
            guard let soundURL = Bundle.main.url(forResource: "Countdown", withExtension: "wav") else { return }
            countdownLabel.layer.opacity = 1.0
            Red_Timer_Outline.layer.opacity = 1.0
            Blue_Button.layer.opacity = 0.0
            do {
                COUNTaudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                COUNTaudioPlayer?.prepareToPlay()
                COUNTaudioPlayer?.volume = 0.7
                COUNTaudioPlayer?.play()
            } catch {
            }
        }
    }
    
    @objc func updateCountdownLabel() {
        if let endTime = countdownEndTime {
            let now = Date()
            let timeRemaining = max(endTime.timeIntervalSince(now), 0)
            countdownLabel.text = timeString(time: timeRemaining)
            if timeRemaining == 0 {
                // Countdown finished, stop the timer
                timer?.invalidate()
                timer = nil
                guard let soundURL = Bundle.main.url(forResource: "CountOver", withExtension: "wav") else { return }
                do {
                    ALERTaudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    ALERTaudioPlayer?.prepareToPlay()
                    ALERTaudioPlayer?.volume = 0.7
                    ALERTaudioPlayer?.play()
                } catch {
                }
            }
        }
    }

    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    // MARK: - Lifecycle Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss the keyboard
        saveData() // or any other code you want to execute when the return key is pressed
        return true // return true to indicate that the text field should process the return key
    }
    
    
    


    class RoundedTableViewCell: UITableViewCell {
        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.layer.cornerRadius = 10
            contentView.clipsToBounds = true
        }
    }


    @objc func refresh() {
        setColors()
        tableView.reloadData()
    }

//MARK: Play the beat !!
    let songNames = ["Celestial Wandering", "Who Where?", "The NY rat", "123 Pond", "Chromed & Neutralized", "Galactic Relative"]
    var currentSongIndex = 0
    
    func playNextSong() {
        let songName = songNames[currentSongIndex]
        guard let audioPath = Bundle.main.path(forResource: songName, ofType: "mp3") else {
            print("Failed to load the audio file")
            return
        }
        CurrentSong.text = songName
        CurrentSong.font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.7
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print("Failed to play the audio file")
        }
        
        currentSongIndex += 1
        if currentSongIndex >= songNames.count {
            currentSongIndex = 0
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mainBundlePath = Bundle.main.resourcePath {
            do {
                let fileManager = FileManager.default
                let fileContents = try fileManager.contentsOfDirectory(atPath: mainBundlePath)
                print("Main Bundle Contents: \(fileContents)")
            } catch {
                print("Error while accessing main bundle: \(error)")
            }
        }

        GifPlayer().playGif(named: "TAGUR_IDLE", in: TagurAI)
        GifPlayer().playGif(named: "Scribble", in: Scribble)
        audioPlayer?.delegate = self
        playNextSong()
        requestProducts()

        let tomorrowDate = UserDefaults.standard.object(forKey: "tomorrowDate") as? Date

        // Format tomorrow's date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy 'at' h:mm a"
        if let tomorrowDate = tomorrowDate {
            _ = dateFormatter.string(from: tomorrowDate)
        } else {
            print("Error: Failed to retrieve tomorrow's date")
        }

        SKPaymentQueue.default().add(self)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        } catch {
        }

        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return
        }
        let appID = "6446804569"
        let urlString = "http://itunes.apple.com/lookup?id=\(appID)"
        let url = URL(string: urlString)!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("Error checking for updates: \(error!)")
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []),
                  let result = (json as? [String: Any])?["results"] as? [[String: Any]],
                  let appStoreVersion = result.first?["version"] as? String else {
                return
            }

            let updateAvailable = appStoreVersion != currentVersion
            if updateAvailable {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Update Available", message: "The latest version of Speaks AI is now available on the app store. It includes new features and improvements. Your current version is \(currentVersion) and the app store version is \(appStoreVersion). To access the latest features and improvements, please update to the latest version.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Later", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Get updated features", style: .default, handler: { action in
                        if let url = URL(string: "https://apps.apple.com/us/app/speaks-ai/id6446804569"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                print("No update available.")
            }
        }
        task.resume()

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Gradient> = Gradient.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
        } catch {
        }
    


        

        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        tableView.register(MissionCell.self, forCellReuseIdentifier: "MissionCell")
       
        let fetchRequest: NSFetchRequest<MissionEntity> = MissionEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "mission_1", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        Missions_Entity_Holder = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        Missions_Entity_Holder.delegate = self
        
        do {
            try Missions_Entity_Holder.performFetch()
        } catch {
        }

        tableView.layer.cornerRadius = 25
        tableView.clipsToBounds = true


        


        // Update the label with the current points
        let pointsLabelText = "Tomorrow: \(tomorrowDateString) \n+\(points) / \(day_actions_max) actions today"
        Points_Label.text = pointsLabelText





        Points_Label.adjustsFontSizeToFitWidth = true // auto-adjust the font size


        
        // Create an empty UIView object
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        tableView.separatorStyle = .none
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView

        // Set the tableFooterView property to the empty UIView
        tableView.tableFooterView = footerView
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear // Set table view background color to clear
        
        // Set background color of the view controller
        view.backgroundColor = UIColor.lightGray // Or any color you want
        
        // Add a UIView as the background view of the table view
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear // Or any color you want
        tableView.backgroundView = backgroundView


        let gradientView = GradientView(frame: view.bounds)
        gradientView.layer.zPosition = -1
        gradientView.isUserInteractionEnabled = false
        view.addSubview(gradientView)
        countdownLabel.text = timeString(time: Countdown_From_Number)
        
        
        // Set the delegate for the text field
        endDayTextField.delegate = self
        endDayTextField.textColor = UIColor.green
        endDayTextField.adjustsFontSizeToFitWidth = true
        fetchData()
    }
    


    @objc func reloadRow(_ notification: Notification) {
        if let indexPath = notification.object as? IndexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }


    class MissionCell: UITableViewCell {
        @IBOutlet weak var mission1Label: UILabel!
        @IBOutlet weak var mission2Label: UILabel!
        @IBOutlet weak var mission3Label: UILabel!
        @IBOutlet weak var mission4Label: UILabel!
        @IBOutlet weak var mission5Label: UILabel!
        @IBOutlet weak var habit1Label: UILabel!
        @IBOutlet weak var habit2Label: UILabel!
        @IBOutlet weak var habit3Label: UILabel!
        @IBOutlet weak var habit4Label: UILabel!
        @IBOutlet weak var habit5Label: UILabel!
    }
    


    func printCurrentTime() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        _ = dateFormatter.string(from: currentDate)
    }


    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MissionCounter.text = "\(Combined_missions_and_habits.count) missions"
        print("Here are the tasks: \(Combined_missions_and_habits)")
        MissionCounter.textColor = UIColor.blue
        MissionCounter.font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)
        MissionCounter.font = UIFont.boldSystemFont(ofSize: MissionCounter.font.pointSize)
        return Combined_missions_and_habits.count
    }

    
    var Missions_Entity_Holder: NSFetchedResultsController<MissionEntity>!
    

    func setColors() {
        // Accessing user defaults
        if let storedStartColorData = UserDefaults.standard.data(forKey: "startColor"),
            let storedEndColorData = UserDefaults.standard.data(forKey: "endColor"),
            let storedStartColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedStartColorData),
            let storedEndColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedEndColorData) {
            
            self.startColor = storedStartColor
            self.endColor = storedEndColor
            tableView.reloadData()
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = Combined_missions_and_habits[indexPath.row]
        
        if let missionTask = task as? MissionEntity {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? MissionCell else {
                fatalError("Unable to dequeue MissionCell")
            }
            
            cell.textLabel?.text = "\(missionTask.mission_1 ?? "") \(missionTask.mission_2 ?? "") \(missionTask.mission_3 ?? "") \(missionTask.mission_4 ?? "") \(missionTask.mission_5 ?? "")"
            cell.textLabel?.font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)
            cell.showsReorderControl = true
            cell.selectedBackgroundView = UIView()
            cell.selectedBackgroundView?.backgroundColor = UIColor.clear
            
            let progress = (CGFloat(indexPath.row) / CGFloat(Combined_missions_and_habits.count) + colorProgress).truncatingRemainder(dividingBy: 1.0)
            let textColor = startColor.interpolateColorTo(endColor, fraction: progress)
            cell.textLabel?.textColor = textColor
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            cell.textLabel?.numberOfLines = 0
            cell.layer.cornerRadius = 20
            
            // Add a background color animation
            cell.contentView.backgroundColor = .red
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.backgroundColor = .red
            }) { _ in
                cell.contentView.backgroundColor = .blue
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? MissionCell else {
                fatalError("Unable to dequeue MissionCell")
            }
            
            cell.textLabel?.text = task as? String
            return cell
        }
    }


    @IBOutlet weak var Points_Label: UILabel!
    var secondsRemaining = 180
    
    
    func checkIfTomorrow() {
        let defaults = UserDefaults.standard
        var tomorrowDate = defaults.object(forKey: "tomorrowDate") as? Date
        if tomorrowDate == nil {
            tomorrowDate = Calendar.current.date(byAdding: .hour, value: 23, to: Date())!
            defaults.set(tomorrowDate, forKey: "tomorrowDate")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy 'at' h:mm a"
        tomorrowDateString = dateFormatter.string(from: tomorrowDate!)
        // Print tomorrow's date in a specific format
        print("Tomorrow is \(tomorrowDateString)")


        if Date() >= tomorrowDate! {
            print("Tomorrow has arrived!")
            points = 0
            endDayTextField.placeholder = "New Day Goal"

            let nextTomorrowDate = Calendar.current.date(byAdding: .hour, value: 23, to: tomorrowDate!)!
            defaults.set(nextTomorrowDate, forKey: "tomorrowDate")
        } else {
            print("Tomorrow has not yet arrived.")
            endDayTextField.text = "\(initialLabelText) \(userTextInput ?? "")"
        }
    }

    var tomorrowDateString: String = ""

    var points: Int {
        get {
            return UserDefaults.standard.integer(forKey: "points")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "points")

            let pointsLabelText = "Tomorrow: \(tomorrowDateString) \n+\(newValue) / \(day_actions_max) actions today"
            Points_Label.text = pointsLabelText
            if newValue > 50 {
                Points_Label.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            }
        }
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < Combined_missions_and_habits.count {
            let task = Combined_missions_and_habits[indexPath.row]
            
            if let missionTask = task as? MissionEntity {
                print("Deleting mission task at index \(indexPath.row)")

                context.delete(missionTask)
                saveData()
                
                Combined_missions_and_habits.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else if let _ = task as? String {
                print("Deleting string task at index \(indexPath.row)")
                
                Combined_missions_and_habits.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                saveData()
            } else {
                print("I didn't delete anything")
            }
                if countdownLabel.text != "03:00" && countdownLabel.text != "00:00" {
                    print("Incrementing points because countdown is at : \(countdownLabel.text ?? "")")
                    points += 1
                }

 
        }
            guard let soundURL = Bundle.main.url(forResource: "laser", withExtension: "mp3") else { return }
            do {
                FARTaudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                FARTaudioPlayer?.prepareToPlay()
                FARTaudioPlayer?.volume = 1.0 // Adjust volume here
                FARTaudioPlayer?.play()
            } catch {
            }
            
            let pointsLabelText = "Tomorrow: \(tomorrowDateString) \n+\(points) / \(day_actions_max) actions today"
            Points_Label.text = pointsLabelText

            if points >= day_actions_max {
                Points_Label.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            }
    }




    // MARK: - Core Data Methods
    func addTaskButton(mission1: String = "", mission2: String = "", mission3: String = "", mission4: String = "", mission5: String = "", context: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
            fatalError("Entity description not found!")
        }
        
        let newTask = MissionEntity(entity: entityDescription, insertInto: context)
        
        if !mission1.isEmpty {
            newTask.mission_1 = mission1
        }

        if !mission2.isEmpty {
            newTask.mission_2 = mission2
        }

        if !mission3.isEmpty {
            newTask.mission_3 = mission3
        }
        
        if !mission4.isEmpty {
            newTask.mission_4 = mission4
        }
        
        if !mission5.isEmpty {
            newTask.mission_5 = mission5
        }
        
        saveData()
        newTask.mission_1 = nil
        newTask.mission_2 = nil
        newTask.mission_3 = nil
        newTask.mission_4 = nil
        newTask.mission_5 = nil
        saveData()
    }


    func randomPastelColor() -> UIColor {
        let hue = CGFloat(arc4random() % 256) / 256.0
        let saturation = CGFloat(arc4random() % 128) / 256.0 + 0.5
        let brightness = CGFloat(arc4random() % 128) / 256.0 + 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    

    var pizzaHabitTextFields: [UITextField] = []
    var current_pizza_habit: String?
    
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        let randomMotivationalString = motivationalStrings.randomElement() ?? ""
        let alertController = UIAlertController(title: "fuck", message: randomMotivationalString, preferredStyle: .alert)

        let pastelColor = randomPastelColor()

        let color_titleAttributes = [NSAttributedString.Key.foregroundColor: pastelColor]
        let color_attributedTitle = NSAttributedString(string: userTextInput ?? "", attributes: color_titleAttributes)
        alertController.setValue(color_attributedTitle, forKey: "attributedTitle")
        let font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)

        

        alertController.addTextField { [self] (textField) in
            textField.placeholder = "Small action"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.adjustsFontSizeToFitWidth = true
        }


        alertController.addTextField { (textField) in
            textField.placeholder = "Remove distraction"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.adjustsFontSizeToFitWidth = true
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Make big goal easier"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.adjustsFontSizeToFitWidth = true
        }

        
        alertController.addTextField { (textField) in
            textField.placeholder = "Smarter action"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.adjustsFontSizeToFitWidth = true
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Cooldown reward"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.adjustsFontSizeToFitWidth = true
        }


        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            guard let mission1 = alertController.textFields?[0].text,
                  let obstacle1 = alertController.textFields?[1].text,
                  let mission2 = alertController.textFields?[2].text,
                  let obstacle2 = alertController.textFields?[3].text,
                  let current_pizza_habit = alertController.textFields?[4].text else { return }
            let context = self.context
            self.addTaskButton(mission1: mission1, mission2: obstacle1, mission3: mission2, mission4: obstacle2, mission5: current_pizza_habit, context: context)
            self.saveData()
            self.fetchData()
        }))


        _ = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
        _ = UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        let middleGreen = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1.0)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.actions[0].setValue(middleGreen, forKey: "titleTextColor")
        alertController.actions[1].setValue(UIColor.red, forKey: "titleTextColor")

        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: selectedFont ?? "Chalkduster", size: 20)]
        let attributedTitle = NSMutableAttributedString(string: initialLabelText, attributes: titleAttributes)
        let endOfDayAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: self.selectedFont ?? "", size: 20) ?? UIFont.systemFont(ofSize: 16.0)]
        let endOfDayAttributedString = NSAttributedString(string: "\n\(userTextInput ?? "")\n", attributes: endOfDayAttributes)
        attributedTitle.append(endOfDayAttributedString)
        let motivationalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14.0, weight: .medium)]
        let motivationalAttributedString = NSAttributedString(string: "\n\"\(randomMotivationalString)\"", attributes: motivationalAttributes)
        attributedTitle.append(motivationalAttributedString)
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        let messageAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
        let attributedMessage = NSAttributedString(string: "", attributes: messageAttributes)
        alertController.setValue(attributedMessage, forKey: "attributedMessage")

        present(alertController, animated: true, completion: nil)

        guard let soundURL = Bundle.main.url(forResource: "ComputerAlert", withExtension: "wav") else { return }
        do {
            ALERTaudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            ALERTaudioPlayer?.prepareToPlay()
            ALERTaudioPlayer?.volume = 0.7
            ALERTaudioPlayer?.play()
        } catch {
        }
    }


    func saveData() {
        do {
            try context.save()
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        } catch let _ as NSError {
        }
        tableView.reloadData()
    }


    @objc func fetchData() {
        let request = NSFetchRequest<MissionEntity>(entityName: "MissionEntity")
        print("Fetch request function activated..")
        
        do {
            let tasks = try context.fetch(request)
            
            for task in tasks {
                for attribute in task.entity.attributesByName {
                    if let value = task.value(forKey: attribute.key) as? String {
                        print("\(attribute.key): \(value)")
                    }
                }
            }
            
            Combined_missions_and_habits.shuffle()
            
            print("Here are all of your tasks: \(Combined_missions_and_habits)")
        } catch _ as NSError {
            // Handle error
        }
        self.tableView.reloadData()
    }




    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if let todays_goal = sender.text {
            userTextInput = todays_goal
            
            let prefixToRemove = "Today, I'll: "
            if userTextInput?.hasPrefix(prefixToRemove) ?? false {
                userTextInput = userTextInput?.replacingOccurrences(of: prefixToRemove, with: "")
            }
            
            endDayTextField.text = "\(initialLabelText) \(userTextInput ?? "")"
            UserDefaults.standard.set(userTextInput, forKey: "EndOfDayText")
        } else {
            userTextInput = nil
            endDayTextField.text = userTextInput
            UserDefaults.standard.set("", forKey: "EndOfDayText")
        }
        saveData()
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        saveData()
    }
}


extension UIColor {
    func interpolateColorTo(_ endColor: UIColor, fraction: CGFloat) -> UIColor {
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

extension UIAlertController {

    func addTextView(text: String? = nil, placeholder: String? = nil) {
        let margin:CGFloat = 3.0
        let rect = CGRect(x: margin, y: 50.0, width: 240.0, height: 80.0)
        let textView = UITextView(frame: rect)
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.isEditable = true
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 0
        textView.textContainerInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        textView.backgroundColor = UIColor.clear
        textView.autocorrectionType = .yes
        textView.spellCheckingType = .yes
        textView.keyboardType = .default
        textView.returnKeyType = .done
        textView.enablesReturnKeyAutomatically = true
        textView.delegate = self as? UITextViewDelegate
        textView.setContentOffset(CGPoint.zero, animated: false)
        let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        if let placeholder = placeholder {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
        self.view.addSubview(textView)
        let height: NSLayoutConstraint = NSLayoutConstraint(item: self.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
        self.view.addConstraint(height)
    }
}

extension ViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        if repopulate_subscription_ask == true {
            for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Purchase successful")
                ViewController.passive_income_customer = true
                print("YOU ARE NOW A CUSTOMER")
                repopulate_subscription_ask = false

            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("You have paid in the past")
            default:
                break
            }
        }
    }
}

  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    products = response.products
    for product in products {
      print("Product title: \(product.localizedTitle)")
      print("Product price: \(product.price)")
      print("Product ID: \(product.productIdentifier)")
    }
  }
}
