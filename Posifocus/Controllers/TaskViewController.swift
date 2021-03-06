//
//  TaskViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/7/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class TaskViewController: SwipeTableViewController, TaskModalViewControllerDelegate  {

    //let realm = try! Realm()
    var tasks: Results<Task>?
    var profiles: Results<Profile>?
    var indexPath: IndexPath? = nil
    var completedTasks: Results<Task>?

    
    var selectedProject : Project? {
        didSet{
            loadTasks()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.pfTask
        profiles = realm.objects(Profile.self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfTask
        navigationController?.navigationBar.backgroundColor = UIColor.pfTask
        navigationController?.navigationBar.isTranslucent = false
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.pfTask
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        title = (selectedProject?.name)! + " Tasks"
        
        self.tableView.reloadData()
        
        if (tasks?.count == 0) {
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "tasks-instructions-tableview.png"))
            self.tableView.backgroundView?.contentMode = UIView.ContentMode.scaleAspectFit
            self.tableView.backgroundView?.alpha = 0.5
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfProject
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = tasks?[indexPath.row].name ?? "No Tasks Added Yet"
        let cellRange = NSMakeRange(0, (cell.textLabel?.text?.count)!)
        let attributedText = NSMutableAttributedString(string: (cell.textLabel?.text)!)
        
        if (tasks?[indexPath.row].completed)! {
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.lightGray
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                        value: NSUnderlineStyle.single.rawValue, range: cellRange)
            
            
            cell.textLabel?.attributedText =  attributedText
            
        } else {
            let numberOfRows = 1 - (CGFloat(indexPath.row) / CGFloat(tasks!.count + 3))
            
                
            cell.backgroundColor = UIColor.pfTask.darker(darkness: numberOfRows)
            cell.textLabel?.textColor = UIColor.white
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                        value: [], range: cellRange)
        }
        
        return cell
    }
    
    
    // Queries Tasks from Database
    func loadTasks() {
        tasks = selectedProject?.tasks.sorted(byKeyPath: "order", ascending: true)
        tableView.reloadData()
    }
    
    
    func addNewItem(itemName: String, todaySwitchStatus: Bool, todayOrder: Int) {
        // Create New Item
        if let currentProject = self.selectedProject {
            do {
                try self.realm.write {
                    let newItem = Task()
                    newItem.name = itemName
                    newItem.order = (tasks?.count)!
                    newItem.today = todaySwitchStatus
                    newItem.todayOrder = todayOrder
                    currentProject.tasks.append(newItem)
                }
            } catch {
                print("Error saving task, \(error)")
            }
        }
        
        self.tableView.reloadData()
        
        updateTableViewBackground(itemList: tasks!)
    }
    
    
    func editItem(itemName: String, todaySwitchStatus: Bool, todayOrder: Int, indexPath: IndexPath) {
        do {
            try self.realm.write {
                tasks![(indexPath.row)].name = itemName
                tasks![(indexPath.row)].today = todaySwitchStatus
                if (todaySwitchStatus) {
                    tasks![(indexPath.row)].todayOrder = todayOrder
                }
                
            }
        } catch {
            print("Error editing task, \(error)")
        }
    }
    
    
    override func deleteButtonPressed(at indexPath: IndexPath) {
        self.deleteItems(at: indexPath, itemList: self.tasks!)
    }
    

    
    override func markItemComplete(at indexPath: IndexPath) {

        // Mark Item Complete
        if (tasks![indexPath.row].completed == false) {
            
            // Mark item complete and move to the end of the list
            do {
                try realm.write {
                    let lastPosition = (tasks?.count)!
                    tasks![indexPath.row].setValue(true, forKey: "completed")
                    tasks![indexPath.row].setValue(lastPosition, forKey: "order")
                    
                    var tasksCompleted = profiles![0].tasksCompleted
                    tasksCompleted = tasksCompleted + 1
                    profiles![0].tasksCompleted = tasksCompleted
                }
            } catch {
                print("Error updating items after marked complete, \(error)")
            }
            
            
            // Shift all items up in the list by one position
            var i = 0
            while i < ((tasks?.count)!) {
                if (i >= indexPath.row) {
                    do {
                        try self.realm.write {
                            let shiftUp = i
                            tasks![i].setValue(shiftUp, forKey: "order")
                        }
                    } catch {
                        print("Error updating items after marked complete, \(error)")
                    }
                }
                i = i + 1
            }
            tableView.reloadData()
            loadTasks()
        }
        
        // Mark Item NOT Complete
        else {
            
            // Mark item NOT Completed
            do {
                try self.realm.write {
                    
                    tasks![indexPath.row].setValue(false, forKey: "completed")
                    tasks![indexPath.row].setValue((-1), forKey: "order")
                    
                    var tasksCompleted = profiles![0].tasksCompleted
                    tasksCompleted = tasksCompleted - 1
                    profiles![0].tasksCompleted = tasksCompleted
                }
            } catch {
                print("Error updating items after marked complete, \(error)")
            }
            tableView.reloadData()
            
            
            // Shift all items down the list by one position
            var i = indexPath.row
            while i > 0 {
                do {
                    try self.realm.write {
                        let shiftDown = i
                        tasks![i].setValue(shiftDown, forKey: "order")
                    }
                } catch {
                    print("Error updating items after marked complete, \(error)")
                }
                i = i - 1
            }
            
            // Set item order to 0
            do {
                try self.realm.write {
                    tasks![0].setValue(0, forKey: "order")
                }
            } catch {
                print("Error updating items after marked complete, \(error)")
            }
            loadTasks()
        }
    }
    
    
    
    
    // Reorder Items
    override func setDataSource(at indexPath: IndexPath, initialIndex: Int) {
        var tasksList = Array(self.tasks!)
        tasksList.swapAt((indexPath.row), (Path.initialIndexPath?.row)!)
        
        do {
            try self.realm.write {
                let originalRow: Int = (Path.initialIndexPath?.row)!
                let newRow: Int = indexPath.row;
                
                if (newRow < originalRow) {
                    self.tasks![(newRow)].setValue(-1, forKey: "order")
                    self.tasks![(originalRow)].setValue(newRow, forKey: "order")
                    self.tableView.reloadData()
                    self.tasks![0].setValue(originalRow, forKey: "order")
                } else {
                    self.tasks![(newRow)].setValue(tasks?.count, forKey: "order")
                    self.tasks![(originalRow)].setValue(newRow, forKey: "order")
                    self.tableView.reloadData()
                    self.tasks![(tasks?.count)! - 1].setValue(originalRow, forKey: "order")
                }
                self.tableView.reloadData()
            }
        } catch {
            print("Error saving new items, \(error)")
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Captures sender and saves it as indexPath
        if let identifier = segue.identifier {
            if (identifier == "ShowTaskModalView" || identifier == "ShowTaskModalView2") {
                if let viewController = segue.destination as? TaskModalViewController {
                    if let indexPath = sender as? NSIndexPath {
                        // Handles Tapped Item
                        if (tableView.indexPathForSelectedRow != nil) {
                            viewController.indexPath = tableView.indexPathForSelectedRow!
                            viewController.itemList = tasks
                        }
                            // Handles Swipe - Edit Button
                        else if (indexPath.row != -1) {
                            viewController.indexPath = indexPath as IndexPath
                            viewController.itemList = tasks
                        }
                    }
                    
                    viewController.delegate = self as TaskModalViewControllerDelegate
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
        }
    }
    
    
    // Handles when item in list is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowTaskModalView", sender: indexPath);
    }
    
    
    // Handles when Swipe - Edit Button is tapped
    override func editButtonPressed(at indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowTaskModalView", sender: indexPath);
    }
    
    
    
    
    // Removes Blurred Background when Modal is dismissed
    func removeBlurredBackgroundView() {
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
        tableView.reloadData()
    }
    
    // Home Button
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindTasksToDashboard", sender: self)
    }

    // Clear Completed Tasks
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        completedTasks = selectedProject?.tasks.filter("completed == true")
        if (scrollView.contentOffset.y > 150.0) {
            deleteCompletedTasks(itemList: completedTasks!)
        }
    }
}


