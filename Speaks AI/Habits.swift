import UIKit
import CoreData
var Combined_missions_and_habits: [AnyObject] = []

class Habits: UIViewController {
    
    @IBOutlet weak var Habit_1_Load: UITextField!
    @IBOutlet weak var Habit_2_Load: UITextField!
    @IBOutlet weak var Habit_3_Load: UITextField!
    @IBOutlet weak var Habit_4_Load: UITextField!
    @IBOutlet weak var Habit_5_Load: UITextField!
    var onSave: (([String], [String]) -> Void)?
    var habitKeys: [String] = []
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view controller as the delegate for text fields
        Habit_1_Load.delegate = self
        Habit_2_Load.delegate = self
        Habit_3_Load.delegate = self
        Habit_4_Load.delegate = self
        Habit_5_Load.delegate = self

        loadHabits()
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func loadHabits() {
        do {
            let fetchRequest: NSFetchRequest<MissionEntity> = MissionEntity.fetchRequest()
            let missions = try context.fetch(fetchRequest)
            if let mission = missions.first, missions.count >= 1 {
                Habit_1_Load.text = mission.habit_1
                Habit_2_Load.text = mission.habit_2
                Habit_3_Load.text = mission.habit_3
                Habit_4_Load.text = mission.habit_4
                Habit_5_Load.text = mission.habit_5
                
                for attribute in mission.entity.attributesByName {
                    if let value = mission.value(forKey: attribute.key) as? String {
                        Combined_missions_and_habits.append("\(attribute.key): \(value)" as AnyObject)
                    }
                }
                print("All attributes combined:\n\(Combined_missions_and_habits)")
            }
        } catch {
            print("Error fetching missions: \(error)")
        }
    }


    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Update MissionEntity attributes with habit texts
        if let mission = fetchMissionEntity() {
            mission.habit_1 = Habit_1_Load.text
            mission.habit_2 = Habit_2_Load.text
            mission.habit_3 = Habit_3_Load.text
            mission.habit_4 = Habit_4_Load.text
            mission.habit_5 = Habit_5_Load.text
            do {
                try context.save()
                print("Habits updated and saved successfully!")
            } catch {
                print("Error saving habits: \(error)")
            }
        }
        
        let habitsTexts = [
            Habit_1_Load.text ?? "",
            Habit_2_Load.text ?? "",
            Habit_3_Load.text ?? "",
            Habit_4_Load.text ?? "",
            Habit_5_Load.text ?? ""
        ]
        onSave?(habitsTexts, habitKeys)
    }
    
    func fetchMissionEntity() -> MissionEntity? {
        let fetchRequest: NSFetchRequest<MissionEntity> = MissionEntity.fetchRequest()
        do {
            let missions = try context.fetch(fetchRequest)
            return missions.first
        } catch {
            print("Error fetching missions: \(error)")
            return nil
        }
    }
}

extension Habits: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
