import UIKit
import StoreKit
import CoreData
import Foundation
import CoreMotion
import AVFoundation

//import PythonKit
//Scroll Store:
//MEMORIZE FROM MAIN LIST:
// scroll view at 0 , 0 , 0 , 0. Add 4 constraints (SCROLL VIEW 4)
// mini view contraints 0 , 0 , 0 , 0, specify height of SHOP. Add 5 constraints (MINI 5)
// mini view control drag to main view , equal widths, equal heights (MINI DRAG)
// 1800

class Main_Cells: UITableViewCell {
}

let heavy_haptic = UIImpactFeedbackGenerator(style: .heavy)
let medium_haptic = UIImpactFeedbackGenerator(style: .medium)
var list_deletion_sound: AVAudioPlayer?
var Song_Radio: AVAudioPlayer?
var Extra_sounds: AVAudioPlayer?
var Combined_missions: [MissionEntity] = []
var day_actions_goal = 50

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

class Main: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, SKStoreProductViewControllerDelegate, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    let motivationalStrings = [
        "Fizzing tasks, sparkling goals, your productivity refreshingly unfolds.",
        "Write your to dread list containing everything you probably should do but really don't want to - Chris Guillebeau",
        "Small progress is still progress.",
        "Change your life trajectory",
        "Do it now. Sometimes later becomes never.",
        "Believe you can and you're halfway there. - Theodore Roosevelt",
        "Focus on progress, not perfection.",
        "Don't let yesterday take up too much of today. - Will Rogers",
        "The secret of getting ahead is getting started. - Mark Twain",
        "The future depends on what you do today. - Mahatma Gandhi",
        "You don't have to be great to start, but you have to start to be great.",
        "Wake up with determination, go to bed with satisfaction.",
        "A good way to predict the future is to create it. - Peter Drucker",
        "Don't waste your time living someone else's life. - Steve Jobs",
        "Don't wait for opportunity. Create it.",
        "The difference between ordinary and extraordinary is that little extra.",
        "The man who moves a mountain begins by carrying away small stones. - Confucius",
        "The doubts we hold today are the only thing that can limit tomorrow's potential.",
        "The best time to plant a tree was 20 years ago. The second-best time is now. - Chinese proverb",
        "Actions speak louder than words",
        "Humans really could solve all of their major problems if they were better at  prioritizing. - Philipp Dettmer (Creator of Kurzgesagt in a Nutshell)",
        "Do not ignore daunting but necessary tasks, they will not resolve themselves, and they still exist",
        "You can't teach tired brains - Terry Doyle",
        "Are you owning or avoiding, making progress or excuses - Scott Mautz",
        "The road to success is dotted with many tempting parking spaces - Will Rogers",
        "Get rid of worrying by taking action instead - Chris Croft",
        "You Don't Reap What You Don't Sow",
        "We look for distraction to escape an uncomfortable emotional sensation, are you resolving or avoiding? - Nir Eyal",
        "What would be the thing that at the end of the day if I didn't do it, I would be upset with myself about? - Pete Mockaitis",
        "Spoil your movie and get to it",
        "Addressing or avoiding?",
        "Fall out of the range of negative, unworthy, and undesired influence",
        "Exploitation infection? Take action like Neutrophils! Heal the host.",
        "Taking part in the wrong battle damages the host.  Know the real enemy and put it away.",
        "Some viruses and bacteria have developed ways to evade or suppress the immune response of the host. Including silencing the cells of the body to avoid detection by white blood cells such as T cells. The host can be cleared once the enemy is properly detected and dealt with.",
        "When a virus manages to evade detection by the immune system it can kill the host"
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
    
    let songNames = [ "LIFI PowerPod", "Night Snow Cleats", "VIBROV", "Chromed & Neutralized", "Supreme Commander", "Southern Dark N' Oily", "Space Race",]
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
        UIColor.green,
        UIColor.green,
        UIColor.clear,
        UIColor.clear
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
        let Back_randomTopAlpha = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomTopColor = UIColor(red: Back_randomTopRed, green: Back_randomTopGreen, blue: Back_randomTopBlue, alpha: Back_randomTopAlpha)
        
        if let Back_encodedTopColorData = try? NSKeyedArchiver.archivedData(withRootObject: Back_randomTopColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(Back_encodedTopColorData, forKey: "Top_selected_Background")
        }
        
        let Back_randomBottomRed = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomBottomGreen = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomBottomBlue = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomBottomAlpha = CGFloat(Float.random(in: 0.0...1.0))
        let Back_randomBottomColor = UIColor(red: Back_randomBottomRed, green: Back_randomBottomGreen, blue: Back_randomBottomBlue, alpha: Back_randomBottomAlpha)
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
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("Speech synthesis cancelled")
    }
    
    lazy var speechSynthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        return synthesizer
    }()

    @IBAction func EcoS2(_ sender: UIButton) {
        let speechUtterance = AVSpeechUtterance(string: "Remember to do the tasks named:")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        
        // Speak the utterance
        speechSynthesizer.speak(speechUtterance)
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
                        print("\n\nGreat job for the year, you current day times 50 is \(currentDayTimes50) and you met your quota at \(newYearActions)")
                        self.Points_YearLabel.textColor = self.New_Years_Satisfied[self.colorIndex]
                        self.colorIndex = (self.colorIndex + 1) % self.New_Years_Satisfied.count
                    }, completion: nil)
                }
                else {
                    print("Your current day times 50 is \(currentDayTimes50) and you are currently at \(newYearActions)")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isSilent {
            Song_Radio?.volume = 1
        }
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.colorProgress += 0.03
            if self.colorProgress > 1.0 {
                self.colorProgress = 0.0
            }
            Play_List_Sounds()
            self.tableView.reloadData()
        }
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
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
            Current_AI.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            Current_AI.transform = Current_AI.transform.concatenating(CGAffineTransform(translationX: 3.3, y: 0))
            Current_AI.contentMode = .scaleAspectFit
            Scribble.layer.opacity = 0.0
        }
        if selectedEntity == "Starship & TORQ" {
            Current_AI.layer.zPosition = -1
            GifPlayer().playGif(named: "Starship & TORQ", in: Current_AI)
            Current_AI.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            Current_AI.transform = Current_AI.transform.concatenating(CGAffineTransform(translationX: 3.3, y: 0))
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
            Current_AI.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            Current_AI.contentMode = .scaleAspectFill
            GifPlayer().playGif(named: "Sketches_Valid", in: Current_AI)
            Scribble.layer.opacity = 0.0
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            tableView.reloadData()
        }
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
    
    var isSilent = false
    @IBAction func silent(_ sender: UIButton) {
        isSilent.toggle()
        if isSilent {
            Song_Radio?.volume = 0.0
                UIView.transition(with: CurrentSong, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                    if self.DAY_transitioningToRed {
                        self.CurrentSong.textColor = .clear
                    } else {
                        self.CurrentSong.textColor = .red
                    }
                    self.DAY_transitioningToRed.toggle()
                }, completion: nil)
            print("OFF")
        } else {
            Song_Radio?.volume = 1
            print("ON")
        }
    }
    
    var colorTransitionTimer: Timer?
    let radio_colors: [UIColor] = [.red, .red, .blue, .green, .yellow, .yellow, .cyan]

    
    func attributedText(with text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        for (index, character) in text.enumerated() {
            let color = radio_colors[(index + currentIndex) % radio_colors.count]
            let range = NSRange(location: index, length: 1)
            attributedString.addAttribute(.foregroundColor, value: color, range: range)
        }
        return attributedString
    }
    
    func playNextSong() {
        shuffleSongNamesIfNeeded()
        let songName = shuffledSongNames[currentSongIndex]
        CurrentSong.attributedText = nil
        colorTransitionTimer?.invalidate()
        CurrentSong.text = songName
        colorTransitionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            self.currentIndex = (self.currentIndex + 1) % self.radio_colors.count
            self.CurrentSong.attributedText = self.attributedText(with: songName)
        }
        pausePlayback()
        do {
            let audioPath = Bundle.main.path(forResource: songName, ofType: "mp3")
            if let audioPath = audioPath {
                if !isSilent {
                    Song_Radio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
                    Song_Radio?.numberOfLoops = 0
                    Song_Radio?.prepareToPlay()
                    Song_Radio?.volume = 1
                    Song_Radio?.delegate = self
                    resumePlayback()
                    Song_Radio?.play()
                }
            } else {
                print("Audio file not found for \(songName)")
            }
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)

        let containerView = UIView(frame: CGRect(x: tapLocation.x, y: tapLocation.y, width: 200, height: 100))
        view.addSubview(containerView)

        let coloredRect = UIView(frame: CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height))
        containerView.addSubview(coloredRect)

        let animatedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        animatedLabel.textAlignment = .center

        var compliments = ["Great job!", "Keep up the good work!", "You're doing fantastic!", "New Year New Me", "You're making progress!", "🍾 Sparkling! 🍾", "Resolutions here I come!", "Bring productive in style", "??¿¿??", "!!¡¡!!", "Ɑ+˥˥ ⱭⱭ ", "EE¡¡ƎƎ¡¡EE",  "<0>___<0>", ">:(", "o_O", "X_X", ">.<", ";-)", ">:)", ">:D", ":-o", "=^.^=", "(¬_¬)", "(O.O)", "<|-_-|>", "<|^_^|>", "<(>_<)>", "(╯°□°）╯︵ ┻━┻", "ಠ_ಠ", "(✖╭╮✖)", "ψ(｀∇´)ψ", "(⊙_☉)", "(◣_◢)", "(∩｀-´)⊃━☆ﾟ.*･｡ﾟ"]
        let randomIndex = Int.random(in: 0..<compliments.count)
        let randomCompliment = compliments[randomIndex]
        animatedLabel.text = randomCompliment
        animatedLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 17.0)
        animatedLabel.numberOfLines = 0
        animatedLabel.lineBreakMode = .byWordWrapping
        containerView.addSubview(animatedLabel)

        UIView.animate(withDuration: 1.0, animations: {
            containerView.alpha = 0
            containerView.center.y -= 50
            coloredRect.backgroundColor = UIColor.red
            coloredRect.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        }) { _ in
            coloredRect.backgroundColor = UIColor.green
            coloredRect.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        }
        UIView.animate(withDuration: 1.0, animations: {
            coloredRect.backgroundColor = UIColor.blue
            coloredRect.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        }) { _ in
            coloredRect.backgroundColor = UIColor.yellow
            coloredRect.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        }
        UIView.animate(withDuration: 1.0, animations: {
            animatedLabel.alpha = 0
            animatedLabel.center.y -= 20
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

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func stopMotionDetection() {
        motionManager.stopDeviceMotionUpdates()
    }

    @objc func appDidEnterBackground() {
        stopMotionDetection()
    }

    @objc func appWillEnterForeground() {
        startMotionDetection()
    }
    
    var motionManager = CMMotionManager()
    func startMotionDetection() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let gravity = motion?.gravity else { return }

            let isTippingLeft = gravity.x > 0.7
            let isTippingRight = gravity.x < -0.7
            let soundFile = isTippingLeft ? "Pour Drank" : (isTippingRight ? "Ice" : nil)
            let shuffleList = true

            if let file = soundFile, let mp3URL = Bundle.main.url(forResource: file, withExtension: "wav") {
                print("Currently tipping")
                do {
                    list_deletion_sound = try AVAudioPlayer(contentsOf: mp3URL)
                    list_deletion_sound?.prepareToPlay()
                    list_deletion_sound?.volume = 0.3
                    list_deletion_sound?.play()
                } catch {
                }
                if shuffleList {
                    Combined_missions.shuffle()
                }
            }
        }
    }
    
    func showBlurredImage() {
        let image = UIImage(named: "Sparkling_Logo.png") // "launcher.jpg")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.addSubview(imageView)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageView.bounds
        imageView.addSubview(blurEffectView)
        imageView.alpha = 1.0
        blurEffectView.alpha = 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            UIView.animate(withDuration: 7.0, animations: {
                imageView.alpha = 0.0
                blurEffectView.alpha = 1.0
            }) { _ in
                imageView.removeFromSuperview()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
        showBlurredImage()
        startMotionDetection()
        becomeFirstResponder()
        let request: NSFetchRequest<Gradient> = Gradient.fetchRequest()
        request.fetchLimit = 1
        do {
            _ = try context.fetch(request)
        } catch {
        }

        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        GifPlayer().playGif(named: "The Primal Dexxacon", in: The_Primal_Dexxacon)
        GifPlayer().playGif(named: "Volume", in: Volume_Bars)
        CurrentSong.adjustsFontSizeToFitWidth = true
        Current_AI_Presented()
        shuffledSongNames = songNames.shuffled()
        tableView.register(Shopping_Cells.self, forCellReuseIdentifier: "Repeat_Cell")
        tableView.register(Shopping_Cells.self, forCellReuseIdentifier: "MissionCell")
        fetchData()
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
            print("Resetting daily goals")
            UserDefaults.standard.set("", forKey: "Operation")
            points = 0
            let nextTomorrowDate = Calendar.current.date(byAdding: .hour, value: 23, to: tomorrowDate!)!
            defaults.set(nextTomorrowDate, forKey: "tomorrowDate")
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
                    Points_DayLabel.textColor = UIColor(
                        red: CGFloat.random(in: 0...1),
                        green: CGFloat.random(in: 0...1),
                        blue: CGFloat.random(in: 0...1),
                        alpha: 1.0
                    )
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

    @objc func fetchData() {
        do {
            Combined_missions = try context.fetch(MissionEntity.fetchRequest())
            self.tableView.reloadData()
        } catch _ as NSError {
        }
        Combined_missions.shuffle()
    }
    
    var cellcolorIndex = 0
    let cellcolors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]
    func transitionColor(from startColor: UIColor, to endColor: UIColor, progress: CGFloat) -> UIColor {
        var startRed: CGFloat = 0.0, startGreen: CGFloat = 0.0, startBlue: CGFloat = 0.0, startAlpha: CGFloat = 0.0
        var endRed: CGFloat = 0.0, endGreen: CGFloat = 0.0, endBlue: CGFloat = 0.0, endAlpha: CGFloat = 0.0
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        let currentRed = startRed + (endRed - startRed) * progress
        let currentGreen = startGreen + (endGreen - startGreen) * progress
        let currentBlue = startBlue + (endBlue - startBlue) * progress
        let currentAlpha = startAlpha + (endAlpha - startAlpha) * progress
        return UIColor(red: currentRed, green: currentGreen, blue: currentBlue, alpha: currentAlpha)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        checkIfTomorrow()
        tableView.separatorStyle = .singleLine
        let cell: UITableViewCell
        
        if indexPath.row < Combined_missions.count {
            let task = Combined_missions[indexPath.row]
            if let missionEntity = task as? MissionEntity {
                cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? Main_Cells ?? UITableViewCell()
                
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    self.cellcolorIndex = (self.cellcolorIndex + 1) % self.cellcolors.count
                    let nextColor = self.cellcolors[self.cellcolorIndex]
                    let gradientProgress = CGFloat(indexPath.row) / CGFloat(tableView.numberOfRows(inSection: indexPath.section))
                    let leftColor = UIColor.red
                    let rightColor = UIColor.blue
                    let newColor = leftColor.interpolateColorTo(rightColor, fraction: gradientProgress)
                    cell.layer.borderColor = newColor.cgColor
                }
                cell.layer.borderColor = cellcolors[cellcolorIndex].cgColor
                cell.layer.borderWidth = 4.0
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
    
    
    
    func fadeOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
        UIView.animate(withDuration: 0.3, animations: {
            tableView.cellForRow(at: indexPath)?.alpha = 0.0
        }) { _ in
            // Inside the completion block, perform your deletion logic
            if indexPath.row < Combined_missions.count {
                if let task = Combined_missions[indexPath.row] as? MissionEntity {
                    let attributeKey = "mission_1"
                    task.setValue("", forKey: attributeKey)
                    self.context.delete(task)
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                } else if let _ = Combined_missions[indexPath.row] as? String {
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                }
                self.points += 1
            }
        }
    }

    func slideOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
        UIView.animate(withDuration: 0.3, animations: {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.frame = CGRect(x: cell?.frame.width ?? 0, y: cell?.frame.minY ?? 0, width: cell?.frame.width ?? 0, height: cell?.frame.height ?? 0)
        }) { _ in
            // Inside the completion block, perform your deletion logic
            if indexPath.row < Combined_missions.count {
                if let task = Combined_missions[indexPath.row] as? MissionEntity {
                    let attributeKey = "mission_1"
                    task.setValue("", forKey: attributeKey)
                    self.context.delete(task)
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                } else if let _ = Combined_missions[indexPath.row] as? String {
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                }
                self.points += 1
            }
        }
    }

    func scaleDownAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
        UIView.animate(withDuration: 0.3, animations: {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            // Inside the completion block, perform your deletion logic
            if indexPath.row < Combined_missions.count {
                if let task = Combined_missions[indexPath.row] as? MissionEntity {
                    let attributeKey = "mission_1"
                    task.setValue("", forKey: attributeKey)
                    self.context.delete(task)
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                } else if let _ = Combined_missions[indexPath.row] as? String {
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                }
                self.points += 1
            }
        }
    }

    func flipAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
        UIView.transition(with: tableView.cellForRow(at: indexPath) ?? UITableViewCell(), duration: 0.3, options: .transitionFlipFromRight, animations: {
            tableView.cellForRow(at: indexPath)?.alpha = 0.0
        }) { _ in
            // Inside the completion block, perform your deletion logic
            if indexPath.row < Combined_missions.count {
                if let task = Combined_missions[indexPath.row] as? MissionEntity {
                    let attributeKey = "mission_1"
                    task.setValue("", forKey: attributeKey)
                    self.context.delete(task)
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                } else if let _ = Combined_missions[indexPath.row] as? String {
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                }
                self.points += 1
            }
        }
    }
    
    func bounceOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
        UIView.animate(withDuration: 0.3, animations: {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.transform = CGAffineTransform(translationX: 0, y: -(cell?.frame.height ?? 11) ?? 0)
        }) { _ in
            // Inside the completion block, perform your deletion logic
            if indexPath.row < Combined_missions.count {
                if let task = Combined_missions[indexPath.row] as? MissionEntity {
                    let attributeKey = "mission_1"
                    task.setValue("", forKey: attributeKey)
                    self.context.delete(task)
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                } else if let _ = Combined_missions[indexPath.row] as? String {
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                }
                self.points += 1
            }
        }
    }
    
    func rotateAndFadeOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
        UIView.animate(withDuration: 0.3, animations: {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            cell?.alpha = 0.0
        }) { _ in
            // Inside the completion block, perform your deletion logic
            if indexPath.row < Combined_missions.count {
                if let task = Combined_missions[indexPath.row] as? MissionEntity {
                    let attributeKey = "mission_1"
                    task.setValue("", forKey: attributeKey)
                    self.context.delete(task)
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                } else if let _ = Combined_missions[indexPath.row] as? String {
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                }
                self.points += 1
            }
        }
    }

    
    func zoomOutAndFadeOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
        UIView.animate(withDuration: 0.3, animations: {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            cell?.alpha = 0.0
        }) { _ in
            // Inside the completion block, perform your deletion logic
            if indexPath.row < Combined_missions.count {
                if let task = Combined_missions[indexPath.row] as? MissionEntity {
                    let attributeKey = "mission_1"
                    task.setValue("", forKey: attributeKey)
                    self.context.delete(task)
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                } else if let _ = Combined_missions[indexPath.row] as? String {
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                }
                self.points += 1
            }
        }
    }

    
    func slideUpAndFadeOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
        UIView.animate(withDuration: 0.3, animations: {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.transform = CGAffineTransform(translationX: 0, y: -(cell?.frame.height ?? 100) ?? 0)
            cell?.alpha = 0.0
        }) { _ in
            // Inside the completion block, perform your deletion logic
            if indexPath.row < Combined_missions.count {
                if let task = Combined_missions[indexPath.row] as? MissionEntity {
                    let attributeKey = "mission_1"
                    task.setValue("", forKey: attributeKey)
                    self.context.delete(task)
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                } else if let _ = Combined_missions[indexPath.row] as? String {
                    Combined_missions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.saveData()
                }
                self.points += 1
            }
        }
    }




    func randomDeleteAnimation(at indexPath: IndexPath, in tableView: UITableView) {
        let randomIndex = Int.random(in: 0..<3) // Generate a random number between 0 and 2
        switch randomIndex {
        case 0:
            fadeOutAndDeleteCell(at: indexPath, in: tableView)
        case 1:
            slideOutAndDeleteCell(at: indexPath, in: tableView)
        case 2:
            scaleDownAndDeleteCell(at: indexPath, in: tableView)
        case 3:
            flipAndDeleteCell(at: indexPath, in: tableView)
        case 4:
            bounceOutAndDeleteCell(at: indexPath, in: tableView)
        case 5:
            rotateAndFadeOutAndDeleteCell(at: indexPath, in: tableView)
        case 6:
            zoomOutAndFadeOutAndDeleteCell(at: indexPath, in: tableView)
        case 7:
            slideUpAndFadeOutAndDeleteCell(at: indexPath, in: tableView)
        default:
            break
        }
    }

    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        heavy_haptic.impactOccurred()

        tableView.deselectRow(at: indexPath, animated: true)
        
        randomDeleteAnimation(at: indexPath, in: tableView)
        
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
    
    let placeholder_strings = [
        "Immune support",
        "Fix a worry",
        "Let go of it",
        "Deal with your to dread list",
        "Remove distraction",
        "Expand past comfort zone",
        "Replace something disliked",
        "Cooldown reward",
        "Be kind to yourself",
        "Explore new ideas",
        "Cultivate a positive mindset",
        "Engage in self-reflection",
        "Embrace creativity",
        "Practice self-care",
        "Savor the moment",
        "Nurture relationships",
        "Find inspiration in daily life",
        "Pursue a passion project",
        "Discover new possibilities",
        "Celebrate small victories",
        "Seek personal growth",
        "For a positive atmosphere",
        "Embrace curiosity",
        "A way to destress",
        "Build meaningful connections",
        "Discover your strengths",
        "Cultivate resilience",
        "Encourage self-expression",
        "Spend time in nature",
        "Nourish your soul",
        "Express kindness to others",
        "Invest time in self-improvement",
        "Explore your passions",
        "Outcome Visualization",
        "Learn in mutual symbiosis"
    ]
    var selectedPlaceholders = Set<String>()
    
    func randomPlaceholder() -> String {
        var availablePlaceholders = placeholder_strings.filter { !selectedPlaceholders.contains($0) }
        if availablePlaceholders.isEmpty {
            selectedPlaceholders.removeAll()
            availablePlaceholders = placeholder_strings
        }
        let randomIndex = Int(arc4random_uniform(UInt32(availablePlaceholders.count)))
        let selectedPlaceholder = availablePlaceholders[randomIndex]
        selectedPlaceholders.insert(selectedPlaceholder)
        return selectedPlaceholder
    }
    
    var currentIndex = 0
    let userDefaults = UserDefaults.standard
    var Quote_Index: Int {
        get {
            return userDefaults.integer(forKey: "Quote_Index")
        }
        set {
            userDefaults.set(newValue, forKey: "Quote_Index")
        }
    }

    @IBAction func addTaskButtonTapped(_ sender: Any) {
        medium_haptic.impactOccurred()
        Quote_Index += 1

        if currentIndex >= motivationalStrings.count {
            Quote_Index = 0
        }
        
        let NextMotivationalString = motivationalStrings[Quote_Index]
        print("\(Quote_Index) of \(motivationalStrings.count)")
        
        
        
        guard let soundURL = Bundle.main.url(forResource: "ComputerAlert", withExtension: "wav") else { return }
        do {
            Extra_sounds = try AVAudioPlayer(contentsOf: soundURL)
            Extra_sounds?.prepareToPlay()
            Extra_sounds?.volume = 0.7
            Extra_sounds?.play()
        } catch {
        }

                let alertController = UIAlertController(title: "", message: NextMotivationalString, preferredStyle: .alert)
        
        
        let pastelColor = randomPastelColor()
        let color_titleAttributes = [NSAttributedString.Key.foregroundColor: pastelColor]
        let color_attributedTitle = NSAttributedString(string: userTextInput ?? "", attributes: color_titleAttributes)
        alertController.setValue(color_attributedTitle, forKey: "attributedTitle")
        let font = UIFont(name: selectedFont ?? "Chalkduster", size: 20)
        for _ in 0..<5 {
            let placeholder = randomPlaceholder()
            alertController.addTextField { [self] (textField) in
                textField.placeholder = placeholder
                textField.font = font
                textField.textColor = randomPastelColor()
                textField.delegate = self
                textField.textAlignment = .center
                textField.autocorrectionType = .yes
                textField.spellCheckingType = .yes
                textField.adjustsFontSizeToFitWidth = true
            }
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
                    medium_haptic.impactOccurred()
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
        let motivationalAttributedString = NSAttributedString(string: "\n\"\(NextMotivationalString)\"", attributes: motivationalAttributes)
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

extension CGColor {
    var uiColor: UIColor {
        return UIColor(cgColor: self)
    }
}
