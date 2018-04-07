//
//  TaskViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/7/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class TaskViewController: UITableViewController {

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
        
        tableView.separatorStyle = .none
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"TaskCell", for: indexPath)
        
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
        
        tasks = selectedProject?.tasks.sorted(byKeyPath: "name", ascending: true)
        
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
                        //newItem.dateCreated = Date()
                        currentProject.tasks.append(newTask)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}
