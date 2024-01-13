import UIKit
import CoreData
import AVFoundation
import UserNotifications
//Scroll Store:
// scroll view at 0 , 0 , 0 , 0. Add 4 constraints

// mini view contraints 0 , 0 , 0 , 0, specify height of SHOP. Add 5 constraints

// mini view control drag to main view , equal widths, equal heights
// 1800
var habits: [String] = []



class Repeat: UIViewController, UITableViewDataSource, UNUserNotificationCenterDelegate {
    @IBOutlet weak var New_Years_Label: UILabel!
    @IBOutlet weak var Notify_Message_Outlet: UITextField!

    @IBOutlet weak var Repeat_Cell_1: UITextField!
    
    func Load_Repeats() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        let fetchRequest: NSFetchRequest<RepeatEntity> = RepeatEntity.fetchRequest()
        do {
            let existingEntities = try context.fetch(fetchRequest)

            if let existingEntity = existingEntities.first {
                Repeat_Cell_1.text = existingEntity.repeat_1
            }
        } catch let error as NSError {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }


//    @IBAction func Repeat_Cell_1(_ sender: UITextField) {
//        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
//            return
//        }
//
//        let fetchRequest: NSFetchRequest<RepeatEntity> = RepeatEntity.fetchRequest()
//
//        do {
//            let existingEntities = try context.fetch(fetchRequest)
//
//            if let existingEntity = existingEntities.first {
//                // Update the existing entity
//                existingEntity.repeat_1 = sender.text
//            } else {
//                // Create a new entity if it doesn't exist
//                let newEntity = RepeatEntity(context: context)
//                newEntity.repeat_1 = sender.text
//            }
//
//            // Save the context
//            try context.save()
//            print("Data saved successfully.")
//
//            // Update UI with the saved text
//            //Load_Repeats()
//
//
//
//        } catch let error as NSError {
//            print("Error saving data: \(error.localizedDescription)")
//        }
//    }

    var audioPlayer: AVAudioPlayer?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    class Habit_Cell: UITableViewCell {
    @IBOutlet weak var habit1Label: UILabel!
    @IBOutlet weak var habit2Label: UILabel!
    @IBOutlet weak var habit3Label: UILabel!
    @IBOutlet weak var habit4Label: UILabel!
    @IBOutlet weak var habit5Label: UILabel!
}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let message = Notify_Message_Outlet.text, !message.isEmpty {
            UserDefaults.standard.set(message, forKey: "notificationText")
            let content = UNMutableNotificationContent()
            
            let emojis = ["⚡", "⛈️", "🦋", "🛸", "🎉", "💎", "👽", "🥷", "🪐", "🧧", "✈️", "🛩️"]
            let randomLeftEmoji = emojis.randomElement() ?? ""
            let randomRightEmoji = emojis.randomElement() ?? ""

            if let dailyInteger = UserDefaults.standard.value(forKey: "points") as? Int {
                content.title = "Prune and Embed:"

                let wrappedMessage = " \(randomLeftEmoji)\(dailyInteger)/\(day_actions_max): \(message)\(randomRightEmoji) "
                content.body = wrappedMessage

            } else {
                print("No value or invalid value for key 'points'")
            }

            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
            let request = UNNotificationRequest(identifier: "messageNotification", content: content, trigger: trigger)
            let nextRepetitionTime = Date().addingTimeInterval(timeInterval)
            let formatter = DateFormatter()
            formatter.dateFormat = "mm:ss"
            let nextRepetitionTimeString = formatter.string(from: nextRepetitionTime)

            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    if let dailyInteger = UserDefaults.standard.value(forKey: "points") as? Int {
                        let wrappedMessage = " \(randomLeftEmoji)\(dailyInteger)/\(day_actions_max): \(message)\(randomRightEmoji) "
                        print("Notification scheduled successfully. Message: \(wrappedMessage) Next Repetition Time: \(nextRepetitionTimeString) seconds")
                    }
                }
            }
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
    
    
    var timeInterval: TimeInterval = 60
    @IBAction func Minutely(_ sender: UIButton) {
        Clicky()
        timeInterval = 60
    }

    @IBAction func Hourly(_ sender: UIButton) {
        Clicky()
        timeInterval = 60 * 3
    }

    @IBAction func Daily(_ sender: UIButton) {
        Clicky()
        timeInterval = 60 * 5
    }
    
    
    @IBAction func Notify_Message(_ sender: UITextField) {
        guard let message = sender.text, !message.isEmpty else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "Prune and Embed:"
        content.body = message

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)

        let request = UNNotificationRequest(identifier: "messageNotification", content: content, trigger: trigger)
        let nextRepetitionTime = Date().addingTimeInterval(timeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let nextRepetitionTimeString = formatter.string(from: nextRepetitionTime)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully. Message: '\(message)' Next Repetition Time: \(nextRepetitionTimeString)")
            }
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? Habit_Cell ?? UITableViewCell()
        guard indexPath.row < habits.count else {
            cell.textLabel?.text = "Invalid Habit"
            return cell
        }

        let habit = habits[indexPath.row]
        cell.textLabel?.text = habit
        
        return cell
    }


    
    @IBOutlet weak var Habit_1_Textfield: UITextField!
    @IBOutlet weak var Habit_2_Textfield: UITextField!
    @IBOutlet weak var Habit_3_Textfield: UITextField!
    @IBOutlet weak var Habit_4_Textfield: UITextField!
    @IBOutlet weak var Habit_5_Textfield: UITextField!
    @IBOutlet weak var Habit_Tableview: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedContext: NSManagedObjectContext!
    
    @IBAction func showAlertButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Enter Text", message: nil, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Enter text here"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            if let textField = alertController.textFields?.first {
                if let newText = textField.text {
                    UserDefaults.standard.set(newText, forKey: "NewYearsText")
                    self.New_Years_Label.text = newText
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func steps(_ sender: UITextField) {
        sender.keyboardType = .numberPad
    }
    
    var List_Deletion_Voicebox: AVAudioPlayer?

    

    
    var currentNumber = 0
    @IBOutlet weak var Duolingo: UILabel!
    @IBOutlet weak var Duo_Progress: UIProgressView!
    @IBAction func Duo_Submit(_ sender: UIButton) {
        incrementAndUpdate(label: Duolingo, progressView: Duo_Progress, key: "DUO_CurrentNumber", labelText: "DUO", max_limit: 1)
    }

    @IBOutlet weak var EMBEDDER: UILabel!
    @IBOutlet weak var EMBED_Progress: UIProgressView!
    @IBAction func EMBED_Submit(_ sender: UIButton) {
        incrementAndUpdate(label: EMBEDDER, progressView: EMBED_Progress, key: "EMBED_CurrentNumber", labelText: "EMBEDDER", max_limit: 500)
    }
    
    
    @IBOutlet weak var COURSES: UILabel!
    @IBOutlet weak var Courses_Progress: UIProgressView!
    @IBAction func Courses_Submit(_ sender: UIButton) {
        incrementAndUpdate(label: COURSES, progressView: Courses_Progress, key: "Courses_CurrentNumber", labelText: "PROFESSIONAL CERTIFICATE", max_limit: 1)
    }
    
    
    @IBOutlet weak var Loom_DS: UILabel!
    @IBOutlet weak var Loom_Progress: UIProgressView!
    @IBAction func Loom_Submit(_ sender: UIButton) {
        incrementAndUpdate(label: Loom_DS, progressView: Loom_Progress, key: "Loom_CurrentNumber", labelText: "Running 1=1,000", max_limit: 21000)
    }
    
    
    @IBOutlet weak var DS_Apply: UILabel!
    @IBOutlet weak var DS_Apply_Progress: UIProgressView!
    @IBAction func DS_Apply_Submit(_ sender: UIButton) {
        incrementAndUpdate(label: DS_Apply, progressView: DS_Apply_Progress, key: "DS_APPLY_CurrentNumber", labelText: "For 10-10", max_limit: 20)
    }
    
    
    @IBOutlet weak var Textbook: UILabel!
    @IBOutlet weak var Textbook_Progress: UIProgressView!
    @IBAction func Textbook_Submit(_ sender: UIButton) {
        incrementAndUpdate(label: Textbook, progressView: Textbook_Progress, key: "Textbook_CurrentNumber", labelText: "Textbook", max_limit: 1)
    }
    
    
    @IBOutlet weak var FS_Assignments: UILabel!
    @IBOutlet weak var FS_Progress: UIProgressView!
    @IBAction func FS_Submit(_ sender: UIButton) {
        incrementAndUpdate(label: FS_Assignments, progressView: FS_Progress, key: "FS_CurrentNumber", labelText: "FS HW", max_limit: 10)
    }
    
    
    @IBOutlet weak var Elubatel_Apply: UILabel!
    @IBOutlet weak var Elubatel_Progress: UIProgressView!
    @IBAction func Elubatel_Apply_Submit(_ sender: UIButton) {
        incrementAndUpdate(label: Elubatel_Apply, progressView: Elubatel_Progress, key: "ELUBATEL_WORSHIP_CurrentNumber", labelText: "Easily Apply", max_limit: 40)
    }
    
    func PlayListSoundEffects() {
        var soundURL: URL?
        if let wavURL = Bundle.main.url(forResource: list_sound, withExtension: "wav") {
            soundURL = wavURL
        } else if let mp3URL = Bundle.main.url(forResource: list_sound, withExtension: "mp3") {
            soundURL = mp3URL
        }
        if let finalSoundURL = soundURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: finalSoundURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = 0.7
                audioPlayer?.play()
            } catch {
            }
        }
    }
    
    func incrementAndUpdate(label: UILabel, progressView: UIProgressView, key: String, labelText: String, max_limit: Int) {
        PlayListSoundEffects()
        currentNumber = UserDefaults.standard.integer(forKey: key)
        currentNumber += 1
        currentNumber = max(0, min(currentNumber, max_limit))
        UserDefaults.standard.set(currentNumber, forKey: key)
        label.text = "\(labelText) \(currentNumber)/\(max_limit)"
        progressView.progress = Float(currentNumber) / Float(max_limit)
    }
    
    func updateFunctionality(label: UILabel, progressView: UIProgressView, key: String, labelText: String, max_limit: Int) {
        currentNumber = UserDefaults.standard.integer(forKey: key)
        label.text = "\(labelText) \(currentNumber)/\(max_limit)"
        progressView.progress = Float(currentNumber) / Float(max_limit)
    }

    @objc func Resetter() {
        // Reset values immediately
        UserDefaults.standard.set(0, forKey: "EMBED_CurrentNumber")
        UserDefaults.standard.set(0, forKey: "DUO_CurrentNumber")
        UserDefaults.standard.set(0, forKey: "Courses_CurrentNumber")
        UserDefaults.standard.set(0, forKey: "Loom_CurrentNumber")
        UserDefaults.standard.set(0, forKey: "DS_APPLY_CurrentNumber")
        UserDefaults.standard.set(0, forKey: "Textbook_CurrentNumber")
        UserDefaults.standard.set(0, forKey: "FS_CurrentNumber")
        UserDefaults.standard.set(0, forKey: "ELUBATEL_WORSHIP_CurrentNumber")

        // Set up a Timer to trigger every Monday at 12:00 AM
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekday = 2
        components.hour = 0
        components.minute = 0

        if let nextMonday = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime) {
            let timer = Timer(fireAt: nextMonday, interval: TimeInterval(7 * 24 * 60 * 60), target: self, selector: #selector(Resetter), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Resetter()
        updateFunctionality(label: Duolingo, progressView: Duo_Progress, key: "DUO_CurrentNumber", labelText: "DUO", max_limit: 1)
        updateFunctionality(label: EMBEDDER, progressView: EMBED_Progress, key: "EMBED_CurrentNumber", labelText: "EMBEDDER", max_limit: 500)
        updateFunctionality(label: COURSES, progressView: Courses_Progress, key: "Courses_CurrentNumber", labelText: "Courses", max_limit: 4)
        updateFunctionality(label: Loom_DS, progressView: Loom_Progress, key: "Loom_CurrentNumber", labelText: "Loom Demos", max_limit: 2)
        updateFunctionality(label: DS_Apply, progressView: DS_Apply_Progress, key: "DS_APPLY_CurrentNumber", labelText: "For 10-10", max_limit: 20)
        updateFunctionality(label: Textbook, progressView: Textbook_Progress, key: "Textbook_CurrentNumber", labelText: "Textbook", max_limit: 1)
        updateFunctionality(label: FS_Assignments, progressView: FS_Progress, key: "FS_CurrentNumber", labelText: "FS HW", max_limit: 10)
        updateFunctionality(label: Elubatel_Apply, progressView: Elubatel_Progress, key: "ELUBATEL_WORSHIP_CurrentNumber", labelText: "Easily Apply", max_limit: 40)



        
        
        
        
        
        
        Notify_Message_Outlet.delegate = self
        if let savedMessage = UserDefaults.standard.string(forKey: "notificationText") {
            Notify_Message_Outlet.text = savedMessage
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Notification permission granted")
            } else {
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Notification Permission Denied",
                                                                message: "You can enable it in the settings: Settings > Speaks AI > Notifications.",
                                                                preferredStyle: .alert)
                        
                        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { (_) in
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        }
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        alertController.addAction(settingsAction)
                        alertController.addAction(cancelAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }



        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        if let savedText = UserDefaults.standard.string(forKey: "NewYearsText") {
            New_Years_Label.text = savedText
        }
        
        let gradientView = GradientView(frame: view.bounds)
        gradientView.layer.zPosition = -1
        view.addSubview(gradientView)
        gradientView.isUserInteractionEnabled = false

    }


    func saveHabits() {
        do {
            let request: NSFetchRequest<MissionEntity> = MissionEntity.fetchRequest()
                try context.save()
            
        } catch {
            print("Error saving habits: \(error)")
        }
    }

    // Implement UITextFieldDelegate methods to save data when text field values change
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveHabits()
    }

    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving data: \(error)")
        }
    }

    func fetchMissionEntity() -> MissionEntity? {
        let fetchRequest: NSFetchRequest<MissionEntity> = MissionEntity.fetchRequest()
        do {
            let missions = try context.fetch(fetchRequest)
            return missions.first
        } catch {
            print("Problem fetching missions: \(error)")
            return nil
        }
    }
}

extension Repeat: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
