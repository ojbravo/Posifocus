//
//  TodayTaskViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 7/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class TodayTaskViewController: TaskViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.pfTask
        profiles = realm.objects(Profile.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfTask
        navigationController?.navigationBar.isTranslucent = false
        title = "Today's Tasks"
        loadTasks()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfBlue
    }
    
    // Queries Tasks from Database
    override func loadTasks() {
        tasks = realm.objects(Task.self).filter("today == true").sorted(by: [SortDescriptor(keyPath: "todayOrder", ascending: true)])
        tableView.reloadData()
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
                    self.tasks![(newRow)].setValue(-1, forKey: "todayOrder")
                    self.tasks![(originalRow)].setValue(newRow, forKey: "todayOrder")
                    self.tableView.reloadData()
                    self.tasks![0].setValue(originalRow, forKey: "todayOrder")
                } else {
                    self.tasks![(newRow)].setValue(tasks?.count, forKey: "todayOrder")
                    self.tasks![(originalRow)].setValue(newRow, forKey: "todayOrder")
                    self.tableView.reloadData()
                    self.tasks![(tasks?.count)! - 1].setValue(originalRow, forKey: "todayOrder")
                }
                self.tableView.reloadData()
            }
        } catch {
            print("Error saving new items, \(error)")
        }
    }
    
    
    override func markItemComplete(at indexPath: IndexPath) {
        
        // Mark Item Complete
        if (tasks![indexPath.row].completed == false) {
            
            // Mark item complete and move to the end of the list
            do {
                try realm.write {
                    let lastPosition = (tasks?.count)!
                    tasks![indexPath.row].setValue(true, forKey: "completed")
                    tasks![indexPath.row].setValue(lastPosition, forKey: "todayOrder")
                    
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
                            tasks![i].setValue(shiftUp, forKey: "todayOrder")
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
                    tasks![indexPath.row].setValue((-1), forKey: "todayOrder")
                    
                    var tasksCompleted = profiles![0].tasksCompleted
                    tasksCompleted = tasksCompleted - 1
                    profiles![0].tasksCompleted = tasksCompleted
                    print(tasksCompleted)
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
                        tasks![i].setValue(shiftDown, forKey: "todayOrder")
                    }
                } catch {
                    print("Error updating items after marked complete, \(error)")
                }
                i = i - 1
            }
            
            // Set item order to 0
            do {
                try self.realm.write {
                    tasks![0].setValue(0, forKey: "todayOrder")
                }
            } catch {
                print("Error updating items after marked complete, \(error)")
            }
            loadTasks()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Captures sender and saves it as indexPath
        if let identifier = segue.identifier {
            if (identifier == "ShowTaskModalView2") {
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
        self.performSegue(withIdentifier: "ShowTaskModalView2", sender: indexPath);
    }
    
    
    // Handles when Swipe - Edit Button is tapped
    override func editButtonPressed(at indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowTaskModalView2", sender: indexPath);
    }
    
}
