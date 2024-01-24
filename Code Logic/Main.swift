import UIKit
import StoreKit
import CoreData
import Foundation
import AVFoundation
import NaturalLanguage
//Scroll Store:
//MEMORIZE FROM MAIN LIST:
// scroll view at 0 , 0 , 0 , 0. Add 4 constraints
// mini view contraints 0 , 0 , 0 , 0, specify height of SHOP. Add 5 constraints
// mini view control drag to main view , equal widths, equal heights
// 1800

class Main_Cells: UITableViewCell {
}

var day_actions_goal = 50
let heavy_haptic = UIImpactFeedbackGenerator(style: .heavy)
let medium_haptic = UIImpactFeedbackGenerator(style: .medium)
var Combined_missions: [MissionEntity] = []
var Song_Radio: AVAudioPlayer?
var list_deletion_sound: AVAudioPlayer?
var Extra_sounds: AVAudioPlayer?

protocol ColorChangeDelegate: AnyObject {
    var startColor: UIColor { get set }
    var endColor: UIColor { get set }
}

var selectedEntity: String? {
    return UserDefaults.standard.string(forKey: "Selected_AI_Entity")
}

var selectedFont: String? {
    return UserDefaults.standard.string(forKey: "SelectedFont")
}

var TOP_selected_Background_Color: String? {
    get {
        return UserDefaults.standard.string(forKey: "selected_Background")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "selected_Background")
    }
}

var BOTTOM_selected_Background_Color: String? {
    get {
        return UserDefaults.standard.string(forKey: "Bottom_selected_Background")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "Bottom_selected_Background")
    }
}

var list_sound: String? {
    return UserDefaults.standard.string(forKey: "list_sound")
}

var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
}


class Main: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, SKStoreProductViewControllerDelegate, AVAudioPlayerDelegate {
    let motivationalStrings = [
        "Small progress is still progress.",
        "Change your life trajectory",
        "Do it now. Sometimes later becomes never.",
        "Your only limit is the amount of action you take.",
        "Believe you can and you're halfway there. - Theodore Roosevelt",
        "Focus on progress, not perfection.",
        "Action is the foundational key to all success. - Pablo Picasso",
        "Don't let yesterday take up too much of today. - Will Rogers",
        "The secret of getting ahead is getting started. - Mark Twain",
        "The future depends on what you do today. - Mahatma Gandhi",
        "You don't have to be great to start, but you have to start to be great.",
        "Wake up with determination, go to bed with satisfaction.",
        "The best way to predict the future is to create it. - Peter Drucker",
        "Don't waste (your time) living someone else's life. - Steve Jobs",
        "The only place where success comes before work is in the dictionary. - Vidal Sassoon",
        "Don't wait for opportunity. Create it.",
        "The difference between ordinary and extraordinary is that little extra.",
        "The man who moves a mountain begins by carrying away small stones. - Confucius",
        "The doubts we hold today are the only thing that can limit tomorrow's potential.",
        "The best time to plant a tree was 20 years ago. The second-best time is now. - Chinese proverb",
        "Vegan-Related: Animal factories are one more sign of the extent to which our technological capacities have advanced faster than our ethics. - Peter Singer",
        "Vegan-Related: If you think that being vegan is difficult, imagine being a factory-farmed animal.",
        "Vegan-Related: Discrimination based off species goes by the term Speciesism",
        "Vegan-Related: The more helpless a creature, the more entitled it is to protection by humans from the cruelty of humans. - Mahatma Gandhi",
        "Actions speak louder than words"
        ]

    @IBOutlet weak var The_Primal_Dexxacon: UIImageView!
    @IBOutlet weak var Points_DayLabel: UILabel!
    @IBOutlet weak var Points_YearLabel: UILabel!
    @IBOutlet weak var Volume_Bars: UIImageView!
    @IBOutlet weak var Scribble: UIImageView!
    @IBOutlet weak var MissionCounter: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Current_AI: UIImageView!
    @IBOutlet weak var day_goal: UITextField!
    @IBOutlet weak var CurrentSong: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    let songNames = ["Chromed & Neutralized", "Distraught Commander", "Southern Dark N' Oily", "天宫空间站出界", ]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentActions = UserDefaults.standard.integer(forKey: "New_Year_Actions")
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var repeat_viewcontroller: Repeat?
    var remainingActions: Int?
    var tomorrowDateString: String = ""
    var totalTime = 18.0
    var years_actions_goal = 18250
    var cycleCount = 0
    var shuffledSongNames = [String]()
    var currentSongIndex = 0
    var userTextInput = UserDefaults.standard.string(forKey: "Operation")
    let initialLabelText = "Today, I'll:"
    var startColor: UIColor = .systemCyan
    var endColor: UIColor = .systemPurple
    let currentDate = Date()
    var colorProgress: CGFloat = 0.0
    var timer: Timer?
    var managedObjectContext: NSManagedObjectContext!
    var colorIndex = 0
    var selectedDeleteSoundIndex = 0
    var repeatExecutionTimer: Timer?
    weak var Carbonation_timer: Timer?
    var DAY_transitioningToRed = true
    var YEAR_transitioningToRed = true
    let transitionDuration = 2.0
    var rainbowTimer: Timer?
    let New_Years_Satisfied: [UIColor] = [
        UIColor.systemCyan,
        UIColor.systemCyan,
        UIColor.purple,
        UIColor.purple
    ]
    
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

    @IBAction func Mixing_Dough(_ sender: UIButton) {
        medium_haptic.impactOccurred()
        guard let soundURL = Bundle.main.url(forResource: "Telepathy", withExtension: "wav") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
        } catch {
        }
        let randomMissionRed = CGFloat(Float.random(in: 0.0...1.0))
        let randomMissionGreen = CGFloat(Float.random(in: 0.0...1.0))
        let randomMissionBlue = CGFloat(Float.random(in: 0.0...1.0))
        let randomMissionColor = UIColor(red: randomMissionRed, green: randomMissionGreen, blue: randomMissionBlue, alpha: 1.0)
        if let encodedMissionColorData = try? NSKeyedArchiver.archivedData(withRootObject: randomMissionColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedMissionColorData, forKey: "MissionColor")
        }
        let randomTopRed = CGFloat(Float.random(in: 0.0...1.0))
        let randomTopGreen = CGFloat(Float.random(in: 0.0...1.0))
        let randomTopBlue = CGFloat(Float.random(in: 0.0...1.0))
        let randomTopColor = UIColor(red: randomTopRed, green: randomTopGreen, blue: randomTopBlue, alpha: 1.0)
        if let encodedTopColorData = try? NSKeyedArchiver.archivedData(withRootObject: randomTopColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedTopColorData, forKey: "topColor")
        }
        let randomBottomRed = CGFloat(Float.random(in: 0.0...1.0))
        let randomBottomGreen = CGFloat(Float.random(in: 0.0...1.0))
        let randomBottomBlue = CGFloat(Float.random(in: 0.0...1.0))
        let randomBottomColor = UIColor(red: randomBottomRed, green: randomBottomGreen, blue: randomBottomBlue, alpha: 1.0)
        if let encodedBottomColorData = try? NSKeyedArchiver.archivedData(withRootObject: randomBottomColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedBottomColorData, forKey: "bottomColor")
        }
        let Back_randomTopRed = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomTopGreen = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomTopBlue = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomTopColor = UIColor(red: Back_randomTopRed, green: Back_randomTopGreen, blue: Back_randomTopBlue, alpha: 1.0)
        if let Back_encodedTopColorData = try? NSKeyedArchiver.archivedData(withRootObject: Back_randomTopColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(Back_encodedTopColorData, forKey: "Top_selected_Background")
        }
        let Back_randomBottomRed = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomBottomGreen = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomBottomBlue = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomBottomColor = UIColor(red: Back_randomTopRed, green: Back_randomBottomGreen, blue: Back_randomTopBlue, alpha: 1.0)
        if let Back_encodedBottomColorData = try? NSKeyedArchiver.archivedData(withRootObject: Back_randomBottomColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(Back_encodedBottomColorData, forKey: "Bottom_selected_Background")
        }
        let randomIndex = Int(arc4random_uniform(UInt32(deleteSoundOptions.count)))
        let list_sound = deleteSoundOptions[randomIndex]
        UserDefaults.standard.set(list_sound, forKey: "list_sound")
        UserDefaults.standard.set(randomIndex, forKey: "selectedDeleteSoundIndex")
        if let fontNames = UIFont.familyNames as? [String], !fontNames.isEmpty {
            let randomFontIndex = Int.random(in: 0..<fontNames.count)
            let randomFontName = fontNames[randomFontIndex]
            UserDefaults.standard.set(randomFontName, forKey: "SelectedFont")
            UserDefaults.standard.set(randomFontIndex, forKey: "selectedFontIndex")
            Combined_missions.shuffle()
            saveData()
            tableView.reloadData()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let lastOpenDate = UserDefaults.standard.value(forKey: "lastOpenDate") as? Date
        if let lastOpenDate = lastOpenDate, Calendar.current.isDateInToday(lastOpenDate) {
        } else {
            var openCount = UserDefaults.standard.integer(forKey: "openCount")
            openCount += 1
            UserDefaults.standard.set(openCount, forKey: "openCount")
            UserDefaults.standard.set(currentDate, forKey: "lastOpenDate")
        }
    }

    @IBAction func SHOP_Button(_ sender: UIButton) {
        medium_haptic.impactOccurred()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "Shop")
        present(secondViewController, animated: true)
        guard let soundURL = Bundle.main.url(forResource: "ComputerAlert", withExtension: "wav") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
        } catch {
        }
    }

    @IBAction func Repeat_View_Trigger(_ sender: UIButton) {
        medium_haptic.impactOccurred()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let Repeat_View_Controller = storyboard.instantiateViewController(withIdentifier: "Repeat") as? Repeat
        present(Repeat_View_Controller!, animated: true, completion: nil)
        guard let soundURL = Bundle.main.url(forResource: "ComputerAlert", withExtension: "wav") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
        } catch {
        }
    }

    @objc func updateTextColor() {
        Points_DayLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 15.0)
        Points_YearLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 15.0)
        CurrentSong.font = UIFont(name: selectedFont ?? "Chalkduster", size: 24.0)
        day_goal.font = UIFont(name: selectedFont ?? "Chalkduster", size: 24.0)
        if points >= day_actions_goal {
            UIView.transition(with: Points_DayLabel, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                self.Points_DayLabel.textColor = self.New_Years_Satisfied[self.colorIndex]
                self.colorIndex = (self.colorIndex + 1) % self.New_Years_Satisfied.count
            }, completion: nil)
        } else {
            UIView.transition(with: Points_DayLabel, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                if self.DAY_transitioningToRed {
                    self.Points_DayLabel.textColor = .clear
                } else {
                    self.Points_DayLabel.textColor = .red
                }
                self.DAY_transitioningToRed.toggle()
            }, completion: nil)
        }

        if let newYearActions = UserDefaults.standard.value(forKey: "New_Year_Actions") as? Int {
            let percentage = Double(newYearActions) / Double(years_actions_goal) * 100.0
            Points_YearLabel.text = "\(newYearActions) / \(years_actions_goal) actions this year \(String(format: "%.2f", percentage))% Finished"
            let calendar = Calendar.current
            if let dayOfYear = calendar.ordinality(of: .day, in: .year, for: currentDate) {
                let currentDayTimes50 = dayOfYear * 50
                if currentDayTimes50 <= newYearActions {
                    UIView.transition(with: Points_YearLabel, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                        //print("\n\nGreat job for the year, you current day times 50 is \(currentDayTimes50) and you met your quota at \(newYearActions)")
                        self.Points_YearLabel.textColor = self.New_Years_Satisfied[self.colorIndex]
                        self.colorIndex = (self.colorIndex + 1) % self.New_Years_Satisfied.count
                    }, completion: nil)
                }
                else {
                    //print("Your current day times 50 is \(currentDayTimes50) and you are currently at \(newYearActions)")
                    UIView.transition(with: Points_YearLabel, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                        if self.YEAR_transitioningToRed {
                            self.Points_YearLabel.textColor = .clear
                            do {
                                Combined_missions = try self.context.fetch(MissionEntity.fetchRequest())
                                self.tableView.reloadData()
                            } catch _ as NSError {
                            }
                            self.tableView.reloadData()
                        } else {
                            self.Points_YearLabel.textColor = .red
                        }
                        self.YEAR_transitioningToRed.toggle()
                    }, completion: nil)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            let gradientView = GradientView(frame: self.view.bounds)
            gradientView.layer.zPosition = -2
            gradientView.isUserInteractionEnabled = false
            self.view.addSubview(gradientView)
        }
        updateProgress()
        setupTimer()
        Play_List_Sounds()
        Points_DayLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 15.0)
        Points_YearLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 15.0)
        if let topColorData = UserDefaults.standard.data(forKey: "topColor"),
           let bottomColorData = UserDefaults.standard.data(forKey: "bottomColor"),
           let topColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(topColorData) as? UIColor,
           let bottomColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(bottomColorData) as? UIColor {
            startColor = topColor
            endColor = bottomColor
        } else {
            print("Colors not found in UserDefaults")
        }
        refresh()
        rainbowTimer = Timer.scheduledTimer(timeInterval: transitionDuration, target: self, selector: #selector(updateTextColor), userInfo: nil, repeats: true)
        let currentPoints = self.points
        The_Primal_Dexxacon.layer.zPosition = -1
        let pointsLabelText = "Actions resets: \(tomorrowDateString) \n+\(currentPoints) / \(day_actions_goal) actions today"
        Points_DayLabel.text = pointsLabelText
        Song_Radio?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    var populate_timeInterval: TimeInterval =  60
    func updateLabelAndTimeInterval(_ selectedDuration: String) {
        switch selectedDuration {
        case "1-Minute":
            populate_timeInterval = 60
        case "3-Minutes":
            populate_timeInterval = 180
        case "5-Minutes":
            populate_timeInterval = 300
        case "10-Minutes":
            populate_timeInterval = 600
        case "20-Minutes":
            populate_timeInterval = 1200
        case "30-Minutes":
            populate_timeInterval = 1800
        case "1-Hour":
            populate_timeInterval = 3600
        case "3-Hours":
            populate_timeInterval = 10800
        case "5-Hours":
            populate_timeInterval = 18000
        case "1-Day":
            populate_timeInterval = 86400
        default:
            populate_timeInterval = 60
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Song_Radio?.volume = 0.7
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.colorProgress += 0.03
            if self.colorProgress > 1.0 {
                self.colorProgress = 0.0
            }
            Play_List_Sounds()
            self.tableView.reloadData()
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.Current_AI_Presented()
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Current_AI_Presented()
                let defaults = UserDefaults.standard
                var tomorrowDate = defaults.object(forKey: "tomorrowDate") as? Date
                if tomorrowDate == nil {
                    tomorrowDate = Calendar.current.date(byAdding: .hour, value: 23, to: Date())!
                    defaults.set(tomorrowDate, forKey: "tomorrowDate")
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMM d, 'at' h:mm a"
                tomorrowDateString = dateFormatter.string(from: tomorrowDate!)
            }
        }
    }
    
    func Current_AI_Presented() {
        if (currentActions < 3650 && selectedEntity == "TAGUR") || (selectedEntity == nil) {
            Scribble.layer.opacity = 1.0
            Scribble.layer.zPosition = 0
            GifPlayer().playGif(named: "TAGUR_zero", in: Current_AI)
            GifPlayer().playGif(named: "Scribble", in: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
        }
        if currentActions > 3650 && currentActions < 7300 && selectedEntity == "TAGUR" {
            Scribble.layer.opacity = 1.0
            GifPlayer().playGif(named: "TAGUR_Low", in: Current_AI)
            GifPlayer().playGif(named: "Scribble", in: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
            print("Low")
        }
        if currentActions > 7300 && currentActions < 10950 && selectedEntity == "TAGUR" {
            Scribble.layer.opacity = 1.0
            GifPlayer().playGif(named: "TAGUR_Steady", in: Current_AI)
            GifPlayer().playGif(named: "Scribble", in: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
            print("Steady")
        }
        if currentActions > 10950 && currentActions < 14600 && selectedEntity == "TAGUR" {
            Scribble.layer.opacity = 1.0
            GifPlayer().playGif(named: "TAGUR_Rising", in: Current_AI)
            GifPlayer().playGif(named: "Scribble", in: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
            print("Rising")
        }
        if currentActions > 18250 && selectedEntity == "TAGUR" {
            Scribble.layer.opacity = 1.0
            GifPlayer().playGif(named: "TAGUR_Optimal", in: Current_AI)
            GifPlayer().playGif(named: "Scribble", in: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
            print("Optimal")
        }
        if selectedEntity == "Sunday" {
            Current_AI.layer.zPosition = -1
            GifPlayer().playGif(named: "Sunday", in: Current_AI)
            Current_AI.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
            Current_AI.transform = Current_AI.transform.concatenating(CGAffineTransform(translationX: 3.3, y: 0))
            Current_AI.contentMode = .scaleAspectFit
            Scribble.layer.opacity = 0.0
        }
        if selectedEntity == "Seductress" {
            Current_AI.layer.zPosition = -1
            GifPlayer().playGif(named: "Seductress", in: Current_AI)
            Current_AI.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            Current_AI.transform = Current_AI.transform.concatenating(CGAffineTransform(translationX: 25.0, y: 30.0))
            Scribble.layer.opacity = 0.0
            Current_AI.contentMode = .scaleAspectFit
        }
        if selectedEntity == "Disco" {
            Current_AI.layer.zPosition = -1
            GifPlayer().playGif(named: "Disco", in: Current_AI)
            Current_AI.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            Current_AI.transform = Current_AI.transform.concatenating(CGAffineTransform(translationX: 25.0, y: 0))
            Current_AI.contentMode = .scaleAspectFit
            Scribble.layer.opacity = 0.0
        }
        if selectedEntity == "Scribble" {
            Current_AI.layer.zPosition = 2
            GifPlayer().playGif(named: "Scribble", in: Current_AI)
            Current_AI.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
            if selectedEntity == "Sketches" && points < day_actions_goal {
            Current_AI.layer.zPosition = -1
            Current_AI.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            Current_AI.contentMode = .scaleAspectFill
            GifPlayer().playGif(named: "SketchesRED", in: Current_AI)
            Scribble.layer.opacity = 0.0
        }
        if selectedEntity == "Sketches" && points > day_actions_goal {
            Current_AI.layer.zPosition = -1
            Current_AI.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            Current_AI.contentMode = .scaleAspectFill
            GifPlayer().playGif(named: "Sketches_VALID", in: Current_AI)
            Scribble.layer.opacity = 0.0
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
            self.colorProgress += 0.05
            if self.colorProgress > 1.0 {
                self.colorProgress = 0.0
            }
            self.tableView.reloadData()
        }
    }

    func timeStringWithoutLeadingZero(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 9 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%2d:%02d", minutes, seconds)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveData()
        return true
    }
    
    @objc func refresh() {
        setColors()
        tableView.reloadData()
    }
    
    func shuffleSongNamesIfNeeded() {
        if shuffledSongNames.isEmpty {
            shuffledSongNames = songNames.shuffled()
        }
    }
    
    func playNextSong() {
        shuffleSongNamesIfNeeded()
        let songName = shuffledSongNames[currentSongIndex]
        guard let audioPath = Bundle.main.path(forResource: songName, ofType: "mp3") else {
            return
        }
        CurrentSong.text = songName
        pausePlayback()
        do {
            Song_Radio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
            Song_Radio?.numberOfLoops = 0
            Song_Radio?.prepareToPlay()
            Song_Radio?.volume = 0.7
            Song_Radio?.delegate = self
            resumePlayback() // uncomment maybe
            Song_Radio?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
        currentSongIndex += 1
        if currentSongIndex >= shuffledSongNames.count {
            currentSongIndex = 0
            shuffledSongNames.removeAll()
        }
    }

    func pausePlayback() {
        if let player = Song_Radio, player.isPlaying {
            player.pause()
        }
    }

    func resumePlayback() {
        if let player = Song_Radio, !player.isPlaying {
            player.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextSong()
    }

    func Play_List_Sounds() {
        var soundURL: URL?
        if let wavURL = Bundle.main.url(forResource: list_sound, withExtension: "wav") {
            soundURL = wavURL
        } else if let mp3URL = Bundle.main.url(forResource: list_sound, withExtension: "mp3") {
            soundURL = mp3URL
        }
        if let finalSoundURL = soundURL {
            do {
                list_deletion_sound = try AVAudioPlayer(contentsOf: finalSoundURL)
                list_deletion_sound?.prepareToPlay()
            } catch {
            }
        }
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

    @objc func updateProgress() {
        let fillDuration = 9.0
        let fullDuration = 3.0
        let emptyDuration = 6.0
        let elapsed = 0.1
        if totalTime > 0 {
            if totalTime > fillDuration + fullDuration + emptyDuration {
                 print("Executing>>>")
                totalTime   = 18.0
                cycleCount += 1
               //UserDefaults.standard.set(1, forKey: "CycleCount")
                if cycleCount % 10 < 5 {
                    print("Executing:::")
                    progressBar.progressTintColor = .cyan
                } else {
                    progressBar.progressTintColor = .blue
                }
                progressBar.setProgress(0.0, animated: true)
            } else if totalTime > fillDuration + fullDuration {
                let emptyElapsed = totalTime - (fillDuration + fullDuration)
                let progressValue = Float(emptyElapsed / emptyDuration)
                progressBar.setProgress(1.0 - progressValue, animated: true)
            } else if totalTime > fillDuration {
                progressBar.setProgress(1.0, animated: true)
            } else {
                let progressValue = Float((fillDuration - totalTime) / fillDuration)
                
                progressBar.setProgress(1.0 - progressValue, animated: true)
            }
            totalTime -= elapsed
        }  else {
            totalTime = 18.0
            cycleCount = 0
            Carbonation_timer?.invalidate()
            setupTimer()
        }
    }
    
    func setupTimer() {
            self.Carbonation_timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)
        let animatedLabel = UILabel(frame: CGRect(x: tapLocation.x - 25, y: tapLocation.y - 25, width: 200, height: 50))
        animatedLabel.textAlignment = .center
        animatedLabel.center = CGPoint(x: animatedLabel.center.x - 60, y: animatedLabel.center.y)
        var compliments = ["Great job!", "Keep up the good work!", "You're doing fantastic!", "New Year New Me", "You're making progress!", "🍾 Sparkling! 🍾"]
        let randomIndex = Int.random(in: 0..<compliments.count)
        let randomCompliment = compliments[randomIndex]
        animatedLabel.text = randomCompliment
        view.addSubview(animatedLabel)
        UIView.animate(withDuration: 1.0, animations: {
            animatedLabel.alpha = 0
            animatedLabel.center.y -= 50
        }) { _ in
            animatedLabel.removeFromSuperview()
        }
    }

    deinit {
        repeatExecutionTimer?.invalidate()
    }
    
    func Updates() {
        let tomorrowDate = UserDefaults.standard.object(forKey: "tomorrowDate") as? Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, 'at' h:mm a"
        if let tomorrowDate = tomorrowDate {
            _ = dateFormatter.string(from: tomorrowDate)
        } else {
            print("Error: Failed to retrieve tomorrow's date")
        }
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
    }
    
    @objc func silent_model_audio_recover(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        switch interruptionType {
        case .began:
            break
        case .ended:
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
            break
        @unknown default:
            fatalError()
        }
    }
    
    var RepeatView = Repeat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")

        GifPlayer().playGif(named: "The Primal Dexxacon", in: The_Primal_Dexxacon)
        GifPlayer().playGif(named: "Volume", in: Volume_Bars)
        

//        updateCellCornerRadius()
//        var radius_timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateCellCornerRadius), userInfo: nil, repeats: true)
//        RunLoop.main.add(radius_timer, forMode: .common)
        CurrentSong.adjustsFontSizeToFitWidth = true
        Current_AI_Presented()
        shuffledSongNames = songNames.shuffled()

        tableView.register(Shopping_Cells.self, forCellReuseIdentifier: "Repeat_Cell")
        tableView.register(Shopping_Cells.self, forCellReuseIdentifier: "MissionCell")
        fetchData()
        
//        tableView.register(Main_Cells.self, forCellReuseIdentifier: "MissionCell")


        let request: NSFetchRequest<Gradient> = Gradient.fetchRequest()
        request.fetchLimit = 1
        do {
            _ = try context.fetch(request)
        } catch {
        }
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        Song_Radio?.delegate = self
        playNextSong()
        Points_DayLabel.adjustsFontSizeToFitWidth = true
        Points_YearLabel.adjustsFontSizeToFitWidth = true
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        tableView.layer.cornerRadius = 25
        tableView.clipsToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        tableView.backgroundView = backgroundView

        if let savedUserTextInput = UserDefaults.standard.string(forKey: "Operation") {
            userTextInput = savedUserTextInput
            day_goal.text = "\(initialLabelText) \(userTextInput ?? "")"
        }
        day_goal.delegate = self
        day_goal.font = UIFont(name: selectedFont ?? "Chalkduster", size: 24.0)
        day_goal.textColor = UIColor.green
        day_goal.adjustsFontSizeToFitWidth = true
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        let blackScreenView = UIView(frame: view.bounds)
        blackScreenView.backgroundColor = UIColor.black
        blackScreenView.alpha = 3.0
        view.addSubview(blackScreenView)
        UIView.animate(withDuration: 5.0, animations: {
            blackScreenView.alpha = 0.0
        })

        UIView.animate(withDuration: 12.0, animations: {
            blurEffectView.alpha = 0.0
        }) { _ in
            blurEffectView.removeFromSuperview()
            blackScreenView.removeFromSuperview()
        }
    }
    
    @objc func reloadRow(_ notification: Notification) {
        if let indexPath = notification.object as? IndexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func printCurrentTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        _ = dateFormatter.string(from: currentDate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        MissionCounter.text = "\(Combined_missions.count) missions"
        MissionCounter.textColor = UIColor.blue
        MissionCounter.font = UIFont.boldSystemFont(ofSize:
                                                        MissionCounter.font.pointSize)
        return Combined_missions.count
    }
    
    func setColors() {
        if let storedStartColorData = UserDefaults.standard.data(forKey: "startColor"),
           let storedEndColorData = UserDefaults.standard.data(forKey: "endColor"),
           let storedStartColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedStartColorData),
           let storedEndColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: storedEndColorData) {
            self.startColor = storedStartColor
            self.endColor = storedEndColor
            tableView.reloadData()
        }
    }
    
    func checkIfTomorrow() {
        //Repeat().auto_add_repeating_cells()

        
        let defaults = UserDefaults.standard
        var tomorrowDate = defaults.object(forKey: "tomorrowDate") as? Date
        if tomorrowDate == nil {
            tomorrowDate = Calendar.current.date(byAdding: .hour, value: 23, to: Date())!
            defaults.set(tomorrowDate, forKey: "tomorrowDate")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, 'at' h:mm a"
        tomorrowDateString = dateFormatter.string(from: tomorrowDate!)
        if Date() >= tomorrowDate! {
            points = 0
//            day_goal.text = ""
//            day_goal.placeholder = "New Day Goal"
            let nextTomorrowDate = Calendar.current.date(byAdding: .hour, value: 23, to: tomorrowDate!)!
            defaults.set(nextTomorrowDate, forKey: "tomorrowDate")
        } else {
//            day_goal.text = "\(initialLabelText) \(userTextInput ?? "")"
        }
    }

    var points: Int {
            get {
                return UserDefaults.standard.integer(forKey: "points")
            }
            set {
                let calendar = Calendar.current
                if let newYearDate = calendar.date(from: calendar.dateComponents([.year], from: Date())) {
                    if Date() < newYearDate {
                        UserDefaults.standard.set(0, forKey: "New_Year_Actions")
                        Points_YearLabel.text = "0"
                    } else {
                        let currentActions = UserDefaults.standard.integer(forKey: "New_Year_Actions")
                        let newActions = currentActions + 1
                        UserDefaults.standard.set(newActions, forKey: "New_Year_Actions")
                        let percentage = Double(newActions) / Double(years_actions_goal) * 100.0
                        Points_YearLabel.text = "\(newActions) / \(years_actions_goal) actions this year \(String(format: "%.2f", percentage))% Finished"
                    }
                }
                UserDefaults.standard.set(newValue, forKey: "points")
                let pointsLabelText = "Tomorrow: \(tomorrowDateString) \n+\(newValue) / \(day_actions_goal) actions today"
                Points_DayLabel.text = pointsLabelText
                if newValue > 50 {
                    Points_DayLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
                }
            }
        }
    
    func saveData() {
        do {
            try context.save()
        } catch {
        }
        tableView.reloadData()
    }
    
//    @objc func updateCellCornerRadius() {
//        let lowerBound: CGFloat = 5.0
//        let upperBound: CGFloat = 25.0
//        let elapsedTime = Date().timeIntervalSinceReferenceDate
//        let oscillation = (cos(elapsedTime * 0.5) + 1.0) / 2.0
//        let fluctuatingRadius = lowerBound + oscillation * (upperBound - lowerBound)
//        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
//            if let cell = tableView.cellForRow(at: indexPath) {
//                cell.layer.cornerRadius = fluctuatingRadius
//                cell.layer.masksToBounds = true
//            }
//        }
//    }
    
    @objc func fetchData() {
        do {
            Combined_missions = try context.fetch(MissionEntity.fetchRequest())
            self.tableView.reloadData()
        } catch _ as NSError {
        }
        Combined_missions.shuffle()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        checkIfTomorrow()
        tableView.separatorStyle = .singleLine
        let cell: UITableViewCell
        if indexPath.row < Combined_missions.count {
            let task = Combined_missions[indexPath.row]
            if let missionEntity = task as? MissionEntity {
                cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? Main_Cells ?? UITableViewCell()
                cell.textLabel?.text = "\(missionEntity.mission_1 ?? "") \(missionEntity.mission_2 ?? "") \(missionEntity.mission_3 ?? "") \(missionEntity.mission_4 ?? "") \(missionEntity.mission_5 ?? "")"
            } else if let repeatEntity = task as? RepeatEntity {
                cell = tableView.dequeueReusableCell(withIdentifier: "Repeat_Cell", for: indexPath) as? Main_Cells ?? UITableViewCell()
                cell.textLabel?.text = repeatEntity.repeat_section
                print("Running RepeatEntity...")
            } else {
                cell = UITableViewCell()
            }

            cell.textLabel?.font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)
            cell.selectedBackgroundView = UIView()
            cell.contentView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView?.backgroundColor = UIColor.clear
            let progress = (CGFloat(indexPath.row) / CGFloat(Combined_missions.count) + colorProgress).truncatingRemainder(dividingBy: 1.3)
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
            cell.textLabel?.numberOfLines = 0
            cell.layer.cornerRadius = 20
            cell.layer.masksToBounds = true
        } else {
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        heavy_haptic.impactOccurred()
        if indexPath.row < Combined_missions.count {
            if let task = Combined_missions[indexPath.row] as? MissionEntity {
                let attributeKey = "mission_1"
                task.setValue("", forKey: attributeKey)
                context.delete(task)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                tapGesture.cancelsTouchesInView = false
                tableView.addGestureRecognizer(tapGesture)
                saveData()
                Combined_missions.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else if let _ = Combined_missions[indexPath.row] as? String {
                Combined_missions.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                saveData()
            } else {
            }
            points += 1
        }
        if let mp3URL = Bundle.main.url(forResource: list_sound, withExtension: "mp3") {
            do {
                Extra_sounds = try AVAudioPlayer(contentsOf: mp3URL)
                Extra_sounds?.prepareToPlay()
                Extra_sounds?.volume = 0.3
                Extra_sounds?.enableRate = true
                Extra_sounds?.rate = Float.random(in: 0.1...2.0)
                Extra_sounds?.play()
            } catch {
            }
        } else if let wavURL = Bundle.main.url(forResource: list_sound, withExtension: "wav") {
            do {
                Extra_sounds = try AVAudioPlayer(contentsOf: wavURL)
                Extra_sounds?.prepareToPlay()
                Extra_sounds?.volume = 0.3
                Extra_sounds?.enableRate = true
                Extra_sounds?.rate = Float.random(in: 0.1...2.0)
                Extra_sounds?.play()
            } catch {
            }
        }
        
        let pointsLabelText = "Actions resets: \(tomorrowDateString) \n+\(points) / \(day_actions_goal) actions today"
        Points_DayLabel.text = pointsLabelText
    }
    
    func add_logic_nonbutton(
                          mission1: String = "",
                          mission2: String = "",
                          mission3: String = "",
                          mission4: String = "",
                          mission5: String = "",
                          context: NSManagedObjectContext) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "MissionEntity", in: context) else {
            fatalError("Entity description not found!")
        }
        let new_todo = MissionEntity(entity: entityDescription, insertInto: context)
        if !mission1.isEmpty {
            new_todo.mission_1 = mission1
        }
        if !mission2.isEmpty {
            new_todo.mission_2 = mission2
        }
        if !mission3.isEmpty {
            new_todo.mission_3 = mission3
        }
        if !mission4.isEmpty {
            new_todo.mission_4 = mission4
        }
        if !mission5.isEmpty {
            new_todo.mission_5 = mission5
        }
        saveData()
        fetchData()
    }
    
    func randomPastelColor() -> UIColor {
        let hue = CGFloat(arc4random() % 256) / 256.0
        let saturation = CGFloat(arc4random() % 128) / 256.0 + 0.5
        let brightness = CGFloat(arc4random() % 128) / 256.0 + 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
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

    @IBAction func addTaskButtonTapped(_ sender: Any) {
        medium_haptic.impactOccurred()
        let randomMotivationalString = motivationalStrings.randomElement() ?? ""
        let alertController = UIAlertController(title: "", message: randomMotivationalString, preferredStyle: .alert)
        let pastelColor = randomPastelColor()
        let color_titleAttributes = [NSAttributedString.Key.foregroundColor: pastelColor]
        let color_attributedTitle = NSAttributedString(string: userTextInput ?? "", attributes: color_titleAttributes)
        alertController.setValue(color_attributedTitle, forKey: "attributedTitle")
        let font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)
        alertController.addTextField { [self] (textField) in
            textField.placeholder = "Immune support"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.autocorrectionType = .yes
            textField.spellCheckingType = .yes
            textField.adjustsFontSizeToFitWidth = true
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Remove distraction"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.autocorrectionType = .yes
            textField.spellCheckingType = .yes
            textField.adjustsFontSizeToFitWidth = true
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Make big goal easier"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.autocorrectionType = .yes
            textField.spellCheckingType = .yes
            textField.adjustsFontSizeToFitWidth = true
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Smarter action"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.autocorrectionType = .yes
            textField.spellCheckingType = .yes
            textField.adjustsFontSizeToFitWidth = true
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Cooldown reward"
            textField.font = font
            textField.textColor = self.randomPastelColor()
            textField.delegate = self
            textField.textAlignment = .center
            textField.autocorrectionType = .yes
            textField.spellCheckingType = .yes
            textField.adjustsFontSizeToFitWidth = true
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] (action) in
            guard let self = self else {
                return
            }
            var missions: [String] = []
            if let mission1 = alertController.textFields?[0].text, !mission1.isEmpty {
                missions.append(mission1)
            }
            if let mission2 = alertController.textFields?[1].text, !mission2.isEmpty {
                missions.append(mission2)
            }
            if let mission3 = alertController.textFields?[2].text, !mission3.isEmpty {
                missions.append(mission3)
            }
            if let mission4 = alertController.textFields?[3].text, !mission4.isEmpty {
                missions.append(mission4)
            }
            if let mission5 = alertController.textFields?[4].text, !mission5.isEmpty {
                missions.append(mission5)
            }
            if missions.isEmpty {
                return
            }
            let context = self.context
            for (index, mission) in missions.enumerated() {
                self.add_logic_nonbutton(mission1: mission, context: context)
                print("Mission added \(index + 1)")
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.30) {
                    self.FART()
                }
            }
            self.saveData()
            self.fetchData()
        }))
        _ = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
        _ = UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        let middleGreen = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1.0)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.actions[0].setValue(middleGreen, forKey: "titleTextColor")
        alertController.actions[1].setValue(UIColor.red, forKey: "titleTextColor")
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: selectedFont ?? "Chalkduster", size: 20) as Any]
        let attributedTitle = NSMutableAttributedString(string: initialLabelText, attributes: titleAttributes)
        let endOfDayAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: selectedFont ?? "", size: 20) ?? UIFont.systemFont(ofSize: 16.0)]
        let endOfDayAttributedString = NSAttributedString(string: "\n\(userTextInput ?? "")\n", attributes: endOfDayAttributes)
        attributedTitle.append(endOfDayAttributedString)
        let motivationalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14.0, weight: .medium)]
        let motivationalAttributedString = NSAttributedString(string: "\n\"\(randomMotivationalString)\"", attributes: motivationalAttributes)
        attributedTitle.append(motivationalAttributedString)
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        let messageAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
        let attributedMessage = NSAttributedString(string: "", attributes: messageAttributes)
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        do {
            try present(alertController, animated: true, completion: nil)
        } catch {
            print("Error: Unable to present the UIAlertController - \(error.localizedDescription)")
        }
        guard let soundURL = Bundle.main.url(forResource: "ComputerAlert", withExtension: "wav") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
        } catch {
        }
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if let todays_goal = sender.text {
            userTextInput = todays_goal
            let prefixToRemove = "Today, I'll: "
            if userTextInput?.hasPrefix(prefixToRemove) ?? false {
                userTextInput = userTextInput?.replacingOccurrences(of: prefixToRemove, with: "")
            }
            day_goal.text = "\(initialLabelText) \(userTextInput ?? "")"
            UserDefaults.standard.set(userTextInput, forKey: "Operation")
        } else {
            userTextInput = nil
            day_goal.text = userTextInput
            UserDefaults.standard.set("", forKey: "Operation")
        }
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

extension UIColor {
    convenience init?(named colorName: String?) {
        guard let colorName = colorName else {
            return nil
        }
        let selector = NSSelectorFromString(colorName)
        let color = UIColor.perform(selector)?.takeUnretainedValue() as? UIColor
        self.init(cgColor: color?.cgColor ?? UIColor.clear.cgColor)
    }
}
