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
    
    
    var selectedProject : Project? {
        didSet{
            loadTasks()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"TaskCell", for: indexPath)
        
        cell.textLabel?.text = tasks?[indexPath.row].name ?? "No Tasks Added Yet"
        
        return cell
    }
    
    
    // Marks cells with checkmark
    
    
    
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
