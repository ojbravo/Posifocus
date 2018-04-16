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

    let realm = try! Realm()
    var tasks: Results<Task>?
    
    let themeColor: String = "FC5830"  //orange
    
    
    var selectedProject : Project? {
        didSet{
            loadTasks()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(hexString: themeColor)?.darken(byPercentage: 0.25)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(hexString: themeColor)
        navigationController?.navigationBar.isTranslucent = false
        title = (selectedProject?.name)! + " Tasks"
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "FDC02F")
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = tasks?[indexPath.row].name ?? "No Tasks Added Yet"
        
        if let bgcolor = UIColor(hexString: themeColor)?.darken(byPercentage:
            CGFloat(indexPath.row) / CGFloat(tasks!.count + 3)) {
            
            cell.backgroundColor = bgcolor
            cell.textLabel?.textColor = UIColor.white
        }
        
        return cell
    }
    
    
    // Marks cells with checkmark
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
            else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
            tableView.deselectRow(at: indexPath, animated: true)
    
        }
    
    // Queries Projects from Database
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
    
    override func deleteItem(at indexPath: IndexPath) {
        if let deleteTask = self.tasks?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(deleteTask)
                    
                    var i = 0
                    while i < ((tasks?.count)!) {
                        self.tasks![i].setValue(i, forKey: "order")
                        i = i + 1
                    }
                }
            } catch {
                print("Couldn't delete task \(error)")
            }
        }

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


