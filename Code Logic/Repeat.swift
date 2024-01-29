import UIKit
import CoreData
import AVFoundation
import UserNotifications


class Repeat_Cells: UITableViewCell {
    func configure(with repeatEntity: RepeatEntity) {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.textLabel?.text = repeatEntity.repeat_section
        self.textLabel?.adjustsFontSizeToFitWidth = true
        if let selectedFont = UserDefaults.standard.string(forKey: "SelectedFont") {
            let customFont = UIFont(name: selectedFont, size: 15.0)
            self.textLabel?.font = customFont
        } else {
            self.textLabel?.font = UIFont(name: "Chalkduster", size: 15.0)
        }
    }
}

class Repeat: UIViewController, UITableViewDataSource, UNUserNotificationCenterDelegate, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    var selectedDeleteSoundIndex = 0
    var notifier_timeInterval: TimeInterval =  60
    var startColor: UIColor = .systemCyan
    var endColor: UIColor = .systemPurple
    var repeatEntities: [RepeatEntity] = []
    var Combined_missions: [MissionEntity] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedContext: NSManagedObjectContext!
    var timer: Timer?
    var years_actions_goal = 18250
    @IBOutlet weak var Duration_Display: UILabel!
    @IBOutlet weak var Type_Notify_Message: UITextField!
    @IBOutlet weak var Repeat_tableview: UITableView!
    @IBOutlet weak var Repeat_Counter: UILabel!
    @IBOutlet weak var Type_Resolution_One: UITextField!
    @IBOutlet weak var Type_Resolution_Two: UITextField!
    @IBOutlet weak var Type_Resolution_Three: UITextField!
    @IBOutlet weak var fs: UILabel!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        duration_levels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Repeat_Counter.text = "\(repeatEntities.count) repeating tasks"
        Repeat_Counter.textColor = UIColor.blue
        Repeat_Counter.font = UIFont.boldSystemFont(ofSize:
        Repeat_Counter.font.pointSize)
        return repeatEntities.count
    }

    var day_actions_goal: Int {
        let calendar = Calendar.current
        let currentDayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let remainingDays = 365 - currentDayOfYear
        return calculateDayActions_to_meet_goal(newYearActions: UserDefaults.standard.integer(forKey: "New_Year_Actions"), remainingDays: remainingDays)
    }

    func calculateDayActions_to_meet_goal(newYearActions: Int, remainingDays: Int) -> Int {
        let remainingActions = max(years_actions_goal - newYearActions, 0)
        return remainingActions / max(remainingDays, 1)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MainView?.fetchData()


        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.auto_add_repeating_cells), userInfo: nil, repeats: true)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let resolution_one = Type_Resolution_One.text, !resolution_one.isEmpty {
            UserDefaults.standard.set(resolution_one, forKey: "1st goal")
        }
        if let resolution_two = Type_Resolution_Two.text, !resolution_two.isEmpty {
            UserDefaults.standard.set(resolution_two, forKey: "2nd goal")
        }
        if let resolution_three = Type_Resolution_Three.text, !resolution_three.isEmpty {
            UserDefaults.standard.set(resolution_three, forKey: "3rd goal")
        }
        
        if let message = Type_Notify_Message.text, !message.isEmpty {
            UserDefaults.standard.set(message, forKey: "notificationText")
            let content = UNMutableNotificationContent()
            let emojis = ["⚡", "⛈️", "🦋", "🛸", "🎉", "💎", "👽", "🥷", "🪐", "🧧", "✈️", "🛩️"]
            let randomLeftEmoji = emojis.randomElement() ?? ""
            let randomRightEmoji = emojis.randomElement() ?? ""
            if let dailyInteger = UserDefaults.standard.value(forKey: "points") as? Int {
                content.title = "Prune and Embed:"
                let wrappedMessage = " \(randomLeftEmoji)\(dailyInteger)/\(day_actions_goal): \(message)\(randomRightEmoji) "
                content.body = wrappedMessage
            } else {
                print("No value or invalid value for key 'points'")
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notifier_timeInterval, repeats: true)
            let request = UNNotificationRequest(identifier: "messageNotification", content: content, trigger: trigger)
            let nextRepetitionTime = Date().addingTimeInterval(notifier_timeInterval)
            let formatter = DateFormatter()
            formatter.dateFormat = "mm:ss"
            let nextRepetitionTimeString = formatter.string(from: nextRepetitionTime)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    if let dailyInteger = UserDefaults.standard.value(forKey: "points") as? Int {
                        let wrappedMessage = " \(randomLeftEmoji)\(dailyInteger)/\(self.day_actions_goal): \(message)\(randomRightEmoji) "
                        print("Notification scheduled successfully. Message: \(wrappedMessage) Next Repetition Time: \(nextRepetitionTimeString) seconds")
                    }
                }
            }
        }
    }

    func Clicky() {
        guard let soundURL = Bundle.main.url(forResource: "Selected", withExtension: "wav") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.35
            Extra_sounds?.play()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return duration_levels[row]
    }

    @IBAction func Increase_notifier(_ sender: UIButton) {
        Clicky()
        medium_haptic.impactOccurred()
        if currentDurationIndex < duration_levels.count - 1 {
            currentDurationIndex += 1
            Notifier_Time_Interval()
        }
    }

    var currentDurationIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: "currentDurationIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currentDurationIndex")
        }
    }

    @IBAction func Decrease_notifier(_ sender: UIButton) {
        Clicky()
        medium_haptic.impactOccurred()
        if currentDurationIndex > 0 {
            currentDurationIndex -= 1
            Notifier_Time_Interval()
        }
    }

    func FART() {
        guard let soundURL = Bundle.main.url(forResource: "Fart", withExtension: "mp3") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
        } catch {
        }
    }

    let font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)
    func randomPastelColor() -> UIColor {
        let hue = CGFloat(arc4random() % 256) / 256.0
        let saturation = CGFloat(arc4random() % 128) / 256.0 + 0.5
        let brightness = CGFloat(arc4random() % 128) / 256.0 + 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }

    func add_logic_nonbutton( // // Adds repeats to main list
        mission1: String = "",
                          context: NSManagedObjectContext) {
        heavy_haptic.impactOccurred()
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
            fatalError("Entity description not found!")
        }
        let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
        if !mission1.isEmpty {
            new_todo.mission_1 = mission1
        }
        MainView?.tableView.reloadData()
    }

    var MainView: Main?

    @IBAction func Add_Repeat_Button(_ sender: UIButton) {
        Clicky()
        medium_haptic.impactOccurred()
        let alert = UIAlertController(title: "Select Duration", message: "\n\n\n\n\n", preferredStyle: .alert)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 40, width: 260, height: 110))
        pickerView.dataSource = self
        pickerView.delegate = self
        let middleGreen = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1.0)
        alert.view.addSubview(pickerView)
        alert.addTextField { (textField) in
            textField.font = self.font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.placeholder = "Type a task that will repeat in your to do list"
            textField.frame.origin.y += 150
            textField.autocorrectionType = .yes
            textField.spellCheckingType = .yes
            textField.adjustsFontSizeToFitWidth = true
            textField.minimumFontSize = 9
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = alert.textFields?.first?.text {
                let selectedDurationIndex = pickerView.selectedRow(inComponent: 0)
                let selectedDuration = self.duration_levels[selectedDurationIndex]
                let newText = "\(text) Repeats every: \(selectedDuration)"
                let newRepeatEntity = RepeatEntity(context: CoreDataStack.shared.persistentContainer.viewContext)
                var missions: [String] = []
                if (alert.textFields?.first?.text) != nil {
                    missions.append(newText)
                    self.add_logic_nonbutton(mission1: newText, context: self.context)
                }
                self.add_logic_nonbutton(mission1: newText, context: self.context)
                newRepeatEntity.repeat_section = newText
                CoreDataStack.shared.saveContext()
                self.repeatEntities.append(newRepeatEntity)

                self.saveData()
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.present(alert, animated: true, completion: nil)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty {
            playTypingSound()
        }
        return true
    }

    func playTypingSound() {
        medium_haptic.impactOccurred()
        list_deletion_sound?.stop()
        list_deletion_sound?.currentTime = 0
        list_deletion_sound?.play()
        list_deletion_sound?.volume = 0.3
    }

    @IBAction func Notify_Message(_ sender: UITextField) {
        guard let message = sender.text, !message.isEmpty else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "Prune and Embed:"
        content.body = message
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notifier_timeInterval, repeats: true)
        let request = UNNotificationRequest(identifier: "messageNotification", content: content, trigger: trigger)
        let nextRepetitionTime = Date().addingTimeInterval(notifier_timeInterval)
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

    func setColors() {
        if let storedStartColorData = UserDefaults.standard.data(forKey: "startColor"),
           let storedEndColorData = UserDefaults.standard.data(forKey: "endColor"),
           let storedStartColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedStartColorData),
           let storedEndColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedEndColorData) {
            self.startColor = storedStartColor
            self.endColor = storedEndColor
            Repeat_tableview.reloadData()
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Repeat_tableview.dequeueReusableCell(withIdentifier: "Repeat_Cell", for: indexPath) as! Repeat_Cells
        cell.layer.cornerRadius = 20
        cell.textLabel?.numberOfLines = 0
        cell.layer.masksToBounds = true
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        if indexPath.row < repeatEntities.count {
            let repeatEntity = repeatEntities[indexPath.row]
            cell.configure(with: repeatEntity)
        } else {
            print("Index out of range: \(indexPath.row)")
        }
        var colorProgress: CGFloat = 0.0
        let progress = (CGFloat(indexPath.row) / CGFloat(repeatEntities.count) + colorProgress).truncatingRemainder(dividingBy: 1.3)
        if let topColorData = UserDefaults.standard.data(forKey: "topColor"),
           let bottomColorData = UserDefaults.standard.data(forKey: "bottomColor"),
           let Top_Background_Color_Data = UserDefaults.standard.data(forKey: "Top_selected_Background"),
           let Bottom_Background_Color_Data = UserDefaults.standard.data(forKey: "Bottom_selected_Background"),
            let topColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(topColorData) as? UIColor,
           let bottomColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(bottomColorData) as? UIColor {
            setColors()
            let textColor = topColor.interpolateColorTo(bottomColor, fraction: progress)
            cell.textLabel?.textColor = textColor
            let topBackgroundColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Top_Background_Color_Data) as? UIColor
            let bottomBackgroundColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Bottom_Background_Color_Data) as? UIColor
            if let topBackgroundColor = topBackgroundColor, let bottomBackgroundColor = bottomBackgroundColor {
                let Gradient_Changing_Background_Cells = topBackgroundColor.interpolateColorTo(bottomBackgroundColor, fraction: progress)
                cell.backgroundColor = Gradient_Changing_Background_Cells
            }
        }
        return cell
    }

    class CoreDataStack {
        static let shared = CoreDataStack()
        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Speaks_AI")
            container.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        func saveContext() {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }

    @IBAction func showAlertButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Enter Text", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter text here"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let middleGreen = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1.0)
        alertController.actions[0].setValue(middleGreen, forKey: "titleTextColor")
        alertController.actions[1].setValue(UIColor.red, forKey: "titleTextColor")
        present(alertController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        heavy_haptic.impactOccurred()
        UserDefaults.standard.set(selectedDeleteSoundIndex, forKey: "selectedDeleteSoundIndex")
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
        Repeat_tableview.deselectRow(at: indexPath, animated: true)
        let repeatEntity = repeatEntities[indexPath.row]
        let context = CoreDataStack.shared.persistentContainer.viewContext
        context.delete(repeatEntity)
        repeatEntities.remove(at: indexPath.row)
        CoreDataStack.shared.saveContext()
        Repeat_tableview.reloadData()
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
                Extra_sounds = try AVAudioPlayer(contentsOf: finalSoundURL)
                Extra_sounds?.prepareToPlay()
                Extra_sounds?.volume = 0.7
                Extra_sounds?.play()
            } catch {
            }
        }
    }

    func getSelectedDuration(from text: String) -> String? {
        guard let range = text.range(of: "Repeats every: ") else {
            return nil
        }

        let selectedDuration = text[range.upperBound...]
        return String(selectedDuration)
    }

    func convertDurationToSeconds(_ duration: String?) -> Int {
        guard let duration = duration else {
            return 0
        }
        return 0
    }

    func calculateExecutionTime(_ selectedDurationInSeconds: Int) -> String {
        let currentDate = Date()
        let executionDate = currentDate.addingTimeInterval(TimeInterval(selectedDurationInSeconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: executionDate)
    }

    func calculateRemainingTime(_ selectedDurationInSeconds: Int) -> String {
        let currentDate = Date()
        let executionDate = currentDate.addingTimeInterval(TimeInterval(selectedDurationInSeconds))
        let remainingTimeInSeconds = max(0, executionDate.timeIntervalSinceNow)
        let minutes = Int(remainingTimeInSeconds) / 60
        let seconds = Int(remainingTimeInSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var duration_levels = ["1-Minute", "3-Minutes", "5-Minutes", "10-Minutes", "20-Minutes", "30-Minutes", "1-Hour", "3-Hours", "5-Hours", "1-Day", "1-Week"]
    func duration_math() {
        let defaults = UserDefaults.standard

        for repeatEntity in self.repeatEntities {
            if let section = repeatEntity.repeat_section {
                var repeat_cell_says = "\(section)"
                print("✨✨✨✨✨✨✨✨✨✨✨✨✨✨")
                if UserDefaults.standard.object(forKey: repeat_cell_says) == nil {
                    UserDefaults.standard.set(Date(), forKey: repeat_cell_says)
                    UserDefaults.standard.synchronize()
                }

                if repeat_cell_says.contains("1-Minute") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 60 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 60 since the last execution.")
                        }
                    }
                }
                
                if UserDefaults.standard.object(forKey: "3-Minutes") == nil {
                    UserDefaults.standard.set(Date(), forKey: "3-Minutes")
                    UserDefaults.standard.synchronize()
                }

                if repeat_cell_says.contains("3-Minutes") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 180 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 180 since the last execution.")
                        }
                    }
                }


                if UserDefaults.standard.object(forKey: "5-Minutes") == nil {
                    UserDefaults.standard.set(Date(), forKey: "5-Minutes")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("5-Minutes") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 300 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 300 since the last execution.")
                        }
                    }
                }
                

                if UserDefaults.standard.object(forKey: "10-Minutes") == nil {
                    UserDefaults.standard.set(Date(), forKey: "10-Minutes")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("10-Minutes") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 600 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 600 since the last execution.")
                        }
                    }
                }
                
                if UserDefaults.standard.object(forKey: "20-Minutes") == nil {
                    UserDefaults.standard.set(Date(), forKey: "20-Minutes")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("20-Minutes") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 1200 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 1200 since the last execution.")
                        }
                    }
                }
                
                if UserDefaults.standard.object(forKey: "30-Minutes") == nil {
                    UserDefaults.standard.set(Date(), forKey: "30-Minutes")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("30-Minutes") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 1800 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 1800 since the last execution.")
                        }
                    }
                }
                
                if UserDefaults.standard.object(forKey: "1-Hour") == nil {
                    UserDefaults.standard.set(Date(), forKey: "1-Hour")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("1-Hour") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 3600 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 3600 since the last execution.")
                        }
                    }
                }
                
                if UserDefaults.standard.object(forKey: "3-Hours") == nil {
                    UserDefaults.standard.set(Date(), forKey: "3-Hours")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("3-Hours") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 10800 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 10800 since the last execution.")
                        }
                    }
                }
                if UserDefaults.standard.object(forKey: "5-Hours") == nil {
                    UserDefaults.standard.set(Date(), forKey: "5-Hours")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("5-Hours") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 18000 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 18000 since the last execution.")
                        }
                    }
                }
                
                if UserDefaults.standard.object(forKey: "1-Day") == nil {
                    UserDefaults.standard.set(Date(), forKey: "1-Day")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("1-Day") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 86400 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 86400 since the last execution.")
                        }
                    }
                }
                if UserDefaults.standard.object(forKey: "1-Week") == nil {
                    UserDefaults.standard.set(Date(), forKey: "1-Week")
                    UserDefaults.standard.synchronize()
                }
                if repeat_cell_says.contains("1-Week") {
                    if let lastSavedTime = UserDefaults.standard.object(forKey: repeat_cell_says) as? Date {
                        let timeDifference = -Int(lastSavedTime.timeIntervalSinceNow)
                        if timeDifference > 604800 {
                            print("Executing \(repeat_cell_says) for \(lastSavedTime) on \(Date())")
                            defaults.set(Date(), forKey: repeat_cell_says)

                            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
                                fatalError("Entity description not found!")
                            }
                            let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
                            new_todo.mission_1 = repeat_cell_says

                        } else {
                            print("Skipping \(repeat_cell_says) as it's been \(timeDifference) seconds than 604800 since the last execution.")
                        }
                    }
                }

                //FART() Uncomment me and I'll let your I am checking for repeats to add correctly
                
 
            }
        }
        
    }

    @objc func auto_add_repeating_cells() {
        duration_math()
    }




//        In my Repeat_tableview I have cells that end withd with one of the strings in the list above:duration_levels. Organize the cells by their duration_levels and create user defaults in the same of that duration so for example forKey: 1-Minute and forKeys for every duration within duration_levels. Set next_minute defaults.object(forKey: "") as? Date for all of these keys and if any are nil then add Calendar.current.date(byAdding: .hour, value: ?, to: Date())! with the value: being equal to the correct duration. Also for every if statement for those duration_levels but a print statement that says what that if statement will execute in this format: "EEEE, MMM d, 'at' h:mm a". You are only executing the repeats that belong to the proper if statement so if a cell contains the string 1-Minute that cell should only append itself into guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) in a minute.
        //





    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<RepeatEntity> = RepeatEntity.fetchRequest()
        do {
            repeatEntities = try CoreDataStack.shared.persistentContainer.viewContext.fetch(fetchRequest)
            Repeat_tableview.reloadData()
            
        } catch {
            print("Error fetching data: \(error)")
        }

        Notifier_Time_Interval()
        Repeat_tableview.dataSource = self
        Repeat_tableview.delegate = self
        Repeat_tableview.backgroundColor = UIColor.clear
        Type_Notify_Message.delegate = self
        Type_Notify_Message.adjustsFontSizeToFitWidth = true
        if let savedMessage = UserDefaults.standard.string(forKey: "notificationText") {
            Type_Notify_Message.text = savedMessage
        }


        Type_Resolution_One.delegate = self
        Type_Resolution_One.adjustsFontSizeToFitWidth = true
        if let savedMessage1 = UserDefaults.standard.string(forKey: "1st goal") {
            Type_Resolution_One.text = savedMessage1
        }
        
        Type_Resolution_Two.delegate = self
        Type_Resolution_Two.adjustsFontSizeToFitWidth = true
        if let savedMessage2 = UserDefaults.standard.string(forKey: "2nd goal") {
            Type_Resolution_Two.text = savedMessage2
        }
        
        Type_Resolution_Three.delegate = self
        Type_Resolution_Three.adjustsFontSizeToFitWidth = true
        if let savedMessage3 = UserDefaults.standard.string(forKey: "3rd goal") {
            Type_Resolution_Three.text = savedMessage3
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
                                                                message: "You can enable it in the settings: Settings > Sparkling List > Notifications.",
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        saveHabits()
    }


    func saveData() {
        do {
            try context.save()
        } catch {

        }

        let fetchRequest: NSFetchRequest<MissionEntity> = MissionEntity.fetchRequest()
        do {
            let missions = try context.fetch(fetchRequest)
        } catch {
            print("Problem fetching missions: \(error)")
        }
        Repeat_tableview.reloadData()
        MainView?.tableView.reloadData()
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

    func Notifier_Time_Interval() {
        let selectedDuration = duration_levels[currentDurationIndex]
        Duration_Display.text = selectedDuration
        if selectedDuration == "1-Minute" {
            notifier_timeInterval = 60
        } else if selectedDuration == "3-Minutes" {
            notifier_timeInterval = 180
        } else if selectedDuration == "5-Minutes" {
            notifier_timeInterval = 300
        } else if selectedDuration == "10-Minutes" {
            notifier_timeInterval = 600
        } else if selectedDuration == "20-Minutes" {
            notifier_timeInterval = 1200
        } else if selectedDuration == "30-Minutes" {
            notifier_timeInterval = 1800
        } else if selectedDuration == "1-Hour" {
            notifier_timeInterval = 3600
        } else if selectedDuration == "3-Hours" {
            notifier_timeInterval = 10800
        } else if selectedDuration == "5-Hours" {
            notifier_timeInterval = 18000
        } else if selectedDuration == "1-Day" {
            notifier_timeInterval = 86400
        } else if selectedDuration == "1-Week" {
            notifier_timeInterval = 604800
        }
        else {
            notifier_timeInterval = 60
        }
    }

}

extension Repeat: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
