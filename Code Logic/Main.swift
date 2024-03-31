import UIKit
import StoreKit
import CoreData
import Foundation
import CoreMotion
import AVFoundation

//Scroll Store:
//MEMORIZE FROM MAIN LIST:
// scroll view at 0 , 0 , 0 , 0. Add 4 constraints (SCROLL VIEW 4)
// mini view contraints 0 , 0 , 0 , 0, specify height of SHOP. Add 5 constraints (MINI 5)
// mini view control drag to main view , equal widths, equal heights (MINI DRAG)
// 1800
var opacity: CGFloat = 100
class Main_Cells: UITableViewCell {
}

let heavy_haptic = UIImpactFeedbackGenerator(style: .heavy)
let medium_haptic = UIImpactFeedbackGenerator(style: .medium)
var Combined_missions: [MissionEntity] = []
var list_deletion_sound: AVAudioPlayer?
var Song_Radio: AVAudioPlayer?
var Extra_sounds: AVAudioPlayer?
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
    let motivators = [
        "Write your to dread list containing everything you probably should do but really don't want to - Chris Guillebeau",
        "Strive for high ethics and know your enemy well, as an immune cell",
        "Change your life trajectory",
        "Do it now. Sometimes later becomes never.",
        "The secret of getting ahead is getting started. - Mark Twain",
        "The future depends on what you do today. - Mahatma Gandhi",
        "Wake up with determination, go to bed with satisfaction.",
        "A good way to predict the future is to create it. - Peter Drucker",
        "Don't wait for opportunity. Create it.",
        "The difference between ordinary and extraordinary is that little extra.",
        "The man who moves a mountain begins by carrying away small stones. - Confucius",
        "The best time to plant a tree was 20 years ago. The second-best time is now. - Chinese proverb",
        "Actions speak louder than words",
        "Humans really could solve all of their major problems if they were better at  prioritizing. - Philipp Dettmer (Creator of Kurzgesagt in a Nutshell)",
        "Do not ignore daunting but necessary tasks, they will not resolve themselves, and they may still exist",
        "You can't teach tired brains - Terry Doyle",
        "Are you owning or avoiding, making progress or excuses - Scott Mautz",
        "The road to success is dotted with many tempting parking spaces - Will Rogers",
        "Get rid of worrying by taking action instead - Chris Croft",
        "You Don't Reap What You Don't Sow",
        "We look for distraction to escape an uncomfortable emotional sensation, are you resolving or avoiding? - Nir Eyal",
        "Spoil your movie and get to it?",
        "Addressing or avoiding?",
        "Fall out of the range of negative, deceptive, and undesired influence.",
        "Taking part in the wrong battle adds up in wasted time.  Know that real enemy and put it away.",
        "Some viruses and bacteria have developed ways to evade or suppress the immune response of the host. Including silencing the cells of the body to avoid detection by white blood cells such as T cells. The host can be at peace once the cause is properly detected and dealt with. Not the symptoms.",
        "The tumor does not deserve resources earned at the expense of exploiting, starve it out of the host",
        "Fragmentation is fear. Come together. Be self-dependent.",
        "Mutual symbiosis over parasitic possession",
        "Know the right form to take and methods to use to be relatable and understood",
        "Distractions. Distractions. Put your foot down.",
        "What are you going to do about the life you want?",
        "International, interplanetary, interstellar",
        "International PROBiotics"
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
    
    let SongNames = [ "Night Snow Cleats", "Neutrophil Alert and SWAT", "Supreme Commander", "All Chromed Out", "DROID DOGLET", "Paranormal Starship", "Astrally Slipped Out"]
    //"Space Race",
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var CurrentActions = UserDefaults.standard.integer(forKey: "New_Year_Actions")
    var RemainingActions: Int?
    var TomorrowDateString: String = ""
    //var years_actions_goal = 18250
    var ShuffledSongNames = [String]()
    var currentSongIndex = 0
    var User_Aimed_DayGoal = UserDefaults.standard.string(forKey:"Day goal resets")
    let InitialDayGoalPlaceholder = "Today, I'll:"
    var StartColor: UIColor = .systemCyan
    var EndColor: UIColor = .systemPurple
    let CurrentDate = Date()
    var ColorProgress: CGFloat = 0.0
    var timer: Timer?
    var ColorIndex = 0
    var selectedDeleteSoundIndex = 0
    var repeatExecutionTimer: Timer?
    weak var Carbonation_timer: Timer?
    var DAY_transitioningToRed = true
    var YEAR_transitioningToRed = true
    let transitionDuration = 2.0
    var rainbowTimer: Timer?
    var isSilent = false
    let New_Years_Satisfied: [UIColor] = [
        UIColor.green,
        UIColor.green,
        UIColor.clear,
        UIColor.clear
    ]

    // MARK: ACTIONS LOGIC
    //var years_actions_goal = 18250

    var years_actions_goal: Int {
        let calendar = Calendar.current
        let currentDayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        // Calculate the remaining days from the current day to the end of the year
        let remainingDays = 365 - currentDayOfYear + 1
        
        // Calculate the total actions expected from the day of installation to the 365th day
        let actionsFromInstallationTo365thDay = 50 * remainingDays
        
        return actionsFromInstallationTo365thDay
    }



    var day_actions_goal: Int {
        let calendar = Calendar.current
        let currentDayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let remainingDays = 365 - currentDayOfYear
        return calculateDayActions_to_meet_goal(newYearActions: UserDefaults.standard.integer(forKey: "New_Year_Actions"), remainingDays: remainingDays)
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


    // MARK: ACTIONS LOGIC
    
    
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
            UserDefaults.standard.set(CurrentDate, forKey: "lastOpenDate")
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
    
    @objc func Sparkling_Label_Color_Status() {
        Points_DayLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 15.0)
        Points_YearLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 15.0)
        CurrentSong.font = UIFont(name: selectedFont ?? "Chalkduster", size: 24.0)
        day_goal.font = UIFont(name: selectedFont ?? "Chalkduster", size: 24.0)
        if points >= day_actions_goal {
            UIView.transition(with: Points_DayLabel, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                self.Points_DayLabel.textColor = self.New_Years_Satisfied[self.ColorIndex]
                self.ColorIndex = (self.ColorIndex + 1) % self.New_Years_Satisfied.count
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
            if let dayOfYear = calendar.ordinality(of: .day, in: .year, for: CurrentDate) {
                let currentDayTimes50 = dayOfYear * 50
                if currentDayTimes50 <= newYearActions {
                    UIView.transition(with: Points_YearLabel, duration: transitionDuration, options: .transitionCrossDissolve, animations: {
                        print("\n\nGreat job for the year, you current day times 50 is \(currentDayTimes50) and you met your quota at \(newYearActions)")
                        self.Points_YearLabel.textColor = self.New_Years_Satisfied[self.ColorIndex]
                        self.ColorIndex = (self.ColorIndex + 1) % self.New_Years_Satisfied.count
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
        Play_List_Sounds()
        Points_DayLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 15.0)
        Points_YearLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 15.0)
        if let topColorData = UserDefaults.standard.data(forKey: "topColor"),
           let bottomColorData = UserDefaults.standard.data(forKey: "bottomColor"),
           let topColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(topColorData) as? UIColor,
           let bottomColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(bottomColorData) as? UIColor {
            StartColor = topColor
            EndColor = bottomColor
        } else {    var subscriptionProduct: SKProduct?
            print("Colors not found in UserDefaults")
        }
        refresh()
        rainbowTimer = Timer.scheduledTimer(timeInterval: transitionDuration, target: self, selector: #selector(Sparkling_Label_Color_Status), userInfo: nil, repeats: true)
        let currentPoints = self.points
        The_Primal_Dexxacon.layer.zPosition = -1
        let pointsLabelText = "Sodas reset on: \(TomorrowDateString) \n+\(currentPoints) / \(day_actions_goal) sparkling waters today"
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

        
        // MARK: SODA
        // ===========================================================
//        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
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
                opacity = CGFloat(points) / CGFloat(day_actions_goal)
            }
            let opacityPercentage = Int(opacity * 100)
            print("\n\n\n\n** Soda Gradient at \(points) of \(day_actions_goal)\n**  Soda from 0...1: \(opacity)\n**  Soda Opacity percentage: \(opacityPercentage)%")
        //}
            //===========================================================
        
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.ColorProgress += 0.03
            if self.ColorProgress > 1.0 {
                self.ColorProgress = 0.0
            }
            Play_List_Sounds()
            self.tableView.reloadData()
        }
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self?.Current_Companion()
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Current_Companion()
                let defaults = UserDefaults.standard
                var tomorrowDate = defaults.object(forKey: "tomorrowDate") as? Date
                if tomorrowDate == nil {
                    tomorrowDate = Calendar.current.date(byAdding: .hour, value: 23, to: Date())!
                    defaults.set(tomorrowDate, forKey: "tomorrowDate")
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMM d, 'at' h:mm a"
                TomorrowDateString = dateFormatter.string(from: tomorrowDate!)
            }
        }
    }
    
    func Current_Companion() {
        let goalQuarter = years_actions_goal / 4
        
        if (CurrentActions < goalQuarter && selectedEntity == "ASTRAL") || (selectedEntity == nil) {
            Scribble.layer.opacity = 1.0
            Scribble.layer.zPosition = 0
            GifPlayer().PlayGif(named: "ASTRAL_ZERO", within: Current_AI)
            GifPlayer().PlayGif(named: "Scribble", within: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
        }
        
        if CurrentActions > goalQuarter && CurrentActions < goalQuarter * 2 && selectedEntity == "ASTRAL" {
            Scribble.layer.opacity = 1.0
            GifPlayer().PlayGif(named: "ASTRAL_LOW", within: Current_AI)
            GifPlayer().PlayGif(named: "Scribble", within: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
        }
        
        if CurrentActions > goalQuarter * 2 && CurrentActions < goalQuarter * 3 && selectedEntity == "ASTRAL" {
            Scribble.layer.opacity = 1.0
            GifPlayer().PlayGif(named: "ASTRAL_MEDIUM", within: Current_AI)
            GifPlayer().PlayGif(named: "Scribble", within: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
        }
        
        if CurrentActions > goalQuarter * 3 && CurrentActions < goalQuarter * 4 && selectedEntity == "ASTRAL" {
            Scribble.layer.opacity = 1.0
            GifPlayer().PlayGif(named: "ASTRAL_RISING", within: Current_AI)
            GifPlayer().PlayGif(named: "Scribble", within: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
        }
        
        if CurrentActions >= years_actions_goal && selectedEntity == "ASTRAL" {
            Scribble.layer.opacity = 1.0
            GifPlayer().PlayGif(named: "ASTRAL_OPTIMAL", within: Current_AI)
            GifPlayer().PlayGif(named: "Scribble", within: Scribble)
            Current_AI.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            Current_AI.contentMode = .scaleAspectFill
            print("You've reached the OPTIMAL level by achieving \(years_actions_goal) actions or more.")
        }
        
        print("To reach the first level ZERO, you need to reach \(goalQuarter) actions.")
        print("To reach the second level LOW, you need to reach \(goalQuarter * 2) actions.")
        print("To reach the third level MEDIUM, you need to reach \(goalQuarter * 3) actions.")
        print("To reach the fourth level RISING, you need to reach \(goalQuarter * 4) actions.")
        print("To reach the OPTIMAL level you need to reach \(years_actions_goal) actions or more.")
    

        if selectedEntity == "Scribble" {
            Current_AI.layer.zPosition = 2
            GifPlayer().PlayGif(named: "Scribble", within: Current_AI)
            Current_AI.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
        if selectedEntity == "Sketches" && points < day_actions_goal {
            Current_AI.layer.zPosition = -1
            Current_AI.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            Current_AI.contentMode = .scaleAspectFill
            GifPlayer().PlayGif(named: "SketchesRED", within: Current_AI)
            Scribble.layer.opacity = 0.0
        }
        if selectedEntity == "Sketches" && points > day_actions_goal {
            Current_AI.layer.zPosition = -1
            Current_AI.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            Current_AI.contentMode = .scaleAspectFill
            GifPlayer().PlayGif(named: "Sketches_Valid", within: Current_AI)
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
        if ShuffledSongNames.isEmpty {
            ShuffledSongNames = SongNames.shuffled()
        }
    }

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
    let radio_colors: [UIColor] = [.red, .red, .blue, .green, .yellow, .systemMint]
    
    func attributedText(with text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        for (index, character) in text.enumerated() {
            let color = radio_colors[(index + CurrentRadioIndex) % radio_colors.count]
            let range = NSRange(location: index, length: 1)
            attributedString.addAttribute(.foregroundColor, value: color, range: range)
        }
        return attributedString
    }
    
    func PlayNextSong() {
        shuffleSongNamesIfNeeded()
        let SongName = ShuffledSongNames[currentSongIndex]
        CurrentSong.attributedText = nil
        colorTransitionTimer?.invalidate()
        CurrentSong.text = SongName
        colorTransitionTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { timer in
            self.CurrentRadioIndex = (self.CurrentRadioIndex + 1) % self.radio_colors.count
            self.CurrentSong.attributedText = self.attributedText(with: SongName)
        }
        PausePlayback()
        do {
            let audioPath = Bundle.main.path(forResource: SongName, ofType: "mp3")
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
                print("Audio file not found for \(SongName)")
            }
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
        currentSongIndex += 1
        if currentSongIndex >= ShuffledSongNames.count {
            currentSongIndex = 0
            ShuffledSongNames.removeAll()
        }
    }

    func PausePlayback() {
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
        PlayNextSong()
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

        // Create a label to display the compliment
        let complimentLabel = UILabel()
        complimentLabel.textAlignment = .center
        complimentLabel.textColor = UIColor.white
        complimentLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        complimentLabel.layer.cornerRadius = 10
        complimentLabel.clipsToBounds = true
        complimentLabel.numberOfLines = 0
        complimentLabel.lineBreakMode = .byWordWrapping

        // Set the text of the compliment
        let compliments = ["🌏", "🇧🇷", "🇸🇰", "🇯🇵", "🇰🇷", "Great job!", "Keep up the good work!", "You're doing fantastic!", "New Year New Me", "You're making progress!", "🍾 Sparkling! 🍾", "Resolutions here I come!", "Bring productive in style", "??¿¿??", "!!¡¡!!", "Ɑ+˥˥ ⱭⱭ ", "EE¡¡ƎƎ¡¡EE",  "<0>___<0>", ">:(", "o_O", "X_X", ">.<", ";-)", ">:)", ">:D", ":-o", "=^.^=", "(¬_¬)", "(O.O)", "<|-_-|>", "<|^_^|>", "<(>_<)>", "(╯°□°）╯︵ ┻━┻", "ಠ_ಠ", "(✖╭╮✖)", "ψ(｀∇´)ψ", "(⊙_☉)", "(◣_◢)", "(∩｀-´)⊃━☆ﾟ.*･｡ﾟ"]
        let randomIndex = Int.random(in: 0..<compliments.count)
        complimentLabel.text = compliments[randomIndex]

        // Set the font
        complimentLabel.font = UIFont(name: selectedFont ?? "Chalkduster", size: 17.0)

        // Calculate label size after setting text
        complimentLabel.sizeToFit()

        // Set the frame of the label based on tap location
        let labelWidth = complimentLabel.frame.width
        let labelHeight = complimentLabel.frame.height

        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        let labelX = (screenWidth - labelWidth) / 2
        let labelY = (screenHeight - labelHeight) / 2

        complimentLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)


        // Add the label to the view
        view.addSubview(complimentLabel)

        // Animate the label
        UIView.animate(withDuration: 2.0, animations: {
            complimentLabel.alpha = 0
            complimentLabel.center.y -= 50
        }) { _ in
            complimentLabel.removeFromSuperview()
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
        // Create and add a white activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        // Add a black view
        let blackView = UIView(frame: view.bounds)
        blackView.backgroundColor = .black
        blackView.layer.zPosition = 2
        view.addSubview(blackView)

        // Add the image view
        let image = UIImage(named: "The Primal Dexxacon.gif")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        imageView.layer.zPosition = 3
        view.addSubview(imageView)

        // Add blur effect view
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageView.bounds
        imageView.addSubview(blurEffectView)

        // Initial alpha settings
        imageView.alpha = 1.0
        blurEffectView.alpha = 0.0
        blackView.alpha = 1.0
        activityIndicator.alpha = 1.0

        // Animation
        UIView.animate(withDuration: 7.0, animations: {
            imageView.alpha = 0.0
            blurEffectView.alpha = 1.0
            activityIndicator.alpha = 0.0
            activityIndicator.center.y -= 300 // Adjust this value to control how much the indicator levitates
        })

        // Delay the animation that fades out the black view and the image view
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            UIView.animate(withDuration: 5.0, animations: {
                blackView.alpha = 0.0
                imageView.alpha = 0.0
            }) { _ in
                blackView.removeFromSuperview()
                imageView.removeFromSuperview()
            }
        }
    }






    override func viewDidLoad() {
        super.viewDidLoad()
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
        GifPlayer().PlayGif(named: "The Primal Dexxacon", within: The_Primal_Dexxacon)
        GifPlayer().PlayGif(named: "Volume", within: Volume_Bars)
        CurrentSong.adjustsFontSizeToFitWidth = true
        Current_Companion()
        ShuffledSongNames = SongNames.shuffled()
        tableView.register(Shopping_Cells.self, forCellReuseIdentifier: "Repeat_Cell")
        tableView.register(Shopping_Cells.self, forCellReuseIdentifier: "MissionCell")
        fetchData()
        Song_Radio?.delegate = self
        PlayNextSong()
        Points_DayLabel.adjustsFontSizeToFitWidth = true
        Points_YearLabel.adjustsFontSizeToFitWidth = true
        Points_DayLabel.layer.zPosition = 1
        Points_YearLabel.layer.zPosition = 1
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

        if let savedUserTextInput = UserDefaults.standard.string(forKey:"Day goal resets") {
            User_Aimed_DayGoal = savedUserTextInput
            day_goal.text = "\(InitialDayGoalPlaceholder) \(User_Aimed_DayGoal ?? "")"
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
        _ = dateFormatter.string(from: CurrentDate)
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
            self.StartColor = storedStartColor
            self.EndColor = storedEndColor
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
        TomorrowDateString = dateFormatter.string(from: tomorrowDate!)
        if Date() >= tomorrowDate! {
            print("Resetting daily goals")
            UserDefaults.standard.set("", forKey: "Day goal resets")
            points = 0
            let nextTomorrowDate = Calendar.current.date(byAdding: .hour, value: 23, to: tomorrowDate!)!
            defaults.set(nextTomorrowDate, forKey: "tomorrowDate")
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
    
    //var cellcolorIndex = 0
    //let cellcolors: [UIColor] = [.white]

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        checkIfTomorrow()
        tableView.separatorStyle = .singleLine
        let cell: UITableViewCell
        if indexPath.row < Combined_missions.count {
            let task = Combined_missions[indexPath.row]
            if let missionEntity = task as? MissionEntity {
                cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? Main_Cells ?? UITableViewCell()

                cell.layer.borderColor = UIColor.clear.cgColor
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
            let progress = (CGFloat(indexPath.row) / CGFloat(Combined_missions.count) + ColorProgress).truncatingRemainder(dividingBy: 1.3)
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

    func FadeOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
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

    func SlideOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
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

    func FlipAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
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
    
    func BounceOutAndDeleteCell(at indexPath: IndexPath, in tableView: UITableView) {
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
            FadeOutAndDeleteCell(at: indexPath, in: tableView)
        case 1:
            SlideOutAndDeleteCell(at: indexPath, in: tableView)
        case 2:
            scaleDownAndDeleteCell(at: indexPath, in: tableView)
        case 3:
            FlipAndDeleteCell(at: indexPath, in: tableView)
        case 4:
            BounceOutAndDeleteCell(at: indexPath, in: tableView)
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
            } catch {}
        } else if let wavURL = Bundle.main.url(forResource: list_sound, withExtension: "wav") {
            do {
                Extra_sounds = try AVAudioPlayer(contentsOf: wavURL)
                Extra_sounds?.prepareToPlay()
                Extra_sounds?.volume = 0.3
                Extra_sounds?.enableRate = true
                Extra_sounds?.rate = Float.random(in: 0.1...2.0)
                Extra_sounds?.play()
            } catch {}
        }
        let pointsLabelText = "Sodas reset on: \(TomorrowDateString) \n+\(points) / \(day_actions_goal) sparkling waters today"
        Points_DayLabel.text = pointsLabelText
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let tapLocation = cell.contentView.center
        let tapGesture = UITapGestureRecognizer()
        handleTap(tapGesture)
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
        "Reward yourself",
        "Explore new ideas",
        "For a positive mindset",
        "Engage in self-reflection",
        "Embrace creativity",
        "Practice self-care",
        "Find inspiration",
        "Pursue a creative project",
        "Discover new possibilities",
        "Celebrate victories",
        "Seek personal growth",
        "For a positive atmosphere",
        "A way to destress",
        "Build meaningful connections",
        "Discover your strengths",
        "Cultivate resilience",
        "Encourage self-expression",
        "Spend time with lifeforms",
        "Nourishing your soul",
        "Express kindness to others",
        "Invest time in self-improvement",
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
    
    var CurrentRadioIndex = 0
    let User_Default_Mode = UserDefaults.standard
    var Quote_Index: Int {
        get {
            return User_Default_Mode.integer(forKey: "Quote_Index")
        }
        set {
            User_Default_Mode.set(newValue, forKey: "Quote_Index")
        }
    }

    @IBAction func AddTaskButtonTapped(_ sender: Any) {
        medium_haptic.impactOccurred()
        Quote_Index += 1
        if Quote_Index >= motivators.count {
            Quote_Index = 0
        }
        let NextMotivationalString = motivators[Quote_Index]
                let alertController = UIAlertController(title: "", message: NextMotivationalString, preferredStyle: .alert)
        let pastelColor = randomPastelColor()
        let color_titleAttributes = [NSAttributedString.Key.foregroundColor: pastelColor]
        let color_attributedTitle = NSAttributedString(string: User_Aimed_DayGoal ?? "", attributes: color_titleAttributes)
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
                //print("Mission added \(index + 1)")
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
        let attributedTitle = NSMutableAttributedString(string: InitialDayGoalPlaceholder, attributes: titleAttributes)
        let endOfDayAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: selectedFont ?? "", size: 20) ?? UIFont.systemFont(ofSize: 16.0)]
        let endOfDayAttributedString = NSAttributedString(string: "\n\(User_Aimed_DayGoal ?? "")\n", attributes: endOfDayAttributes)
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
            User_Aimed_DayGoal = todays_goal
            let prefixToRemove = "Today, I'll: "
            if User_Aimed_DayGoal?.hasPrefix(prefixToRemove) ?? false {
                User_Aimed_DayGoal = User_Aimed_DayGoal?.replacingOccurrences(of: prefixToRemove, with: "")
            }
            day_goal.text = "\(InitialDayGoalPlaceholder) \(User_Aimed_DayGoal ?? "")"
            UserDefaults.standard.set(User_Aimed_DayGoal, forKey:"Day goal resets")
        } else {
            User_Aimed_DayGoal = nil
            day_goal.text = User_Aimed_DayGoal
            UserDefaults.standard.set("", forKey:"Day goal resets")
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
