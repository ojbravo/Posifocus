//
//  TaskViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/7/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class TaskViewController: SwipeTableViewController  {

    //let realm = try! Realm()
    var tasks: Results<Task>?

    
    var selectedProject : Project? {
        didSet{
            loadTasks()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.pfOrange
        profile = realm.objects(Profile.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfOrange.darker(darkness: 0.90) //make 25% darker
        navigationController?.navigationBar.isTranslucent = false
        title = (selectedProject?.name)! + " Tasks"
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfYellow
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
            attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                        value: NSUnderlineStyle.styleSingle.rawValue, range: cellRange)
            
            
            cell.textLabel?.attributedText =  attributedText
            
        } else {
            let numberOfRows = 1 - (CGFloat(indexPath.row) / CGFloat(tasks!.count + 3))
            
                
            cell.backgroundColor = UIColor.pfOrange.darker(darkness: numberOfRows)
            cell.textLabel?.textColor = UIColor.white
            attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                        value: NSUnderlineStyle.styleNone.rawValue, range: cellRange)
        }
        
        return cell
    }
    
    
    // Queries Tasks from Database
    func loadTasks() {
        
        tasks = selectedProject?.tasks.sorted(byKeyPath: "order", ascending: true)
        
        tableView.reloadData()
    }
    
    
    
    // Save Projects to Database
    func save(task: Task) {
        do {
            try realm.write {
                realm.add(task)
            }
        }
        catch {
            print("Error writing priority \(error)")
        }
    }
    
    // Add New Projects Button
    @IBAction func addNewTask(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Task", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Task"
            textField = alertTextField
        }
        
        
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
            // this is where we say what happens once the button is clicked
            
            if let currentProject = self.selectedProject {
                do {
                    try self.realm.write {
                        let newTask = Task()
                        newTask.name = textField.text!
                        newTask.order = (self.tasks?.count)!
                        currentProject.tasks.append(newTask)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func deleteButtonPressed(at indexPath: IndexPath) {
        self.deleteItems(at: indexPath, itemList: self.tasks!)
    }
    
    override func editItem(at indexPath: IndexPath) {
        
        var textField = UITextField()
        let currentTask = tasks![indexPath.row].name
        
        let alert = UIAlertController(title: "Update Task", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.text = currentTask
            textField = alertTextField
        }
        
        
        
        let action = UIAlertAction(title: "Update", style: .default) { (action) in
            // this is where we say what happens once the button is clicked
            
            if self.selectedProject != nil {
                do {
                    try self.realm.write {
                    
                        self.tasks![indexPath.row].name = textField.text!
                        //newItem.dateCreated = Date()
                        
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
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
}


