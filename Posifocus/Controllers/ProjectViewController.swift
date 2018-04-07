//
//  ProjectViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectViewController: UITableViewController {
    
    let realm = try! Realm()
    var projects: Results<Project>?
    

    var selectedPriority : Priority? {
        didSet{
            loadProjects()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projects?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"ProjectCell", for: indexPath)
    
        cell.textLabel?.text = projects?[indexPath.row].name ?? "No Projects Added Yet"
        
        return cell
    }
    
    
    // Connects to Segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTasks", sender: self)
    }
    
    
    // Sends Selected Project to Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedProject = projects?[indexPath.row]
        }
    }
    
    
    // Marks cells with checkmark
    
    
    
    // Queries Projects from Database
    func loadProjects() {
        
        projects = selectedPriority?.projects.sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
    }
    
    // Save Projects to Database
    func save(project: Project) {
        do {
            try realm.write {
                realm.add(project)
            }
        }
        catch {
            print("Error writing priority \(error)")
        }
    }
    
    // Add New Projects Button
    @IBAction func addNewProject(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Project", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Project"
            textField = alertTextField
        }
        
        
        let action = UIAlertAction(title: "Add Project", style: .default) { (action) in
            // this is where we say what happens once the button is clicked
            
            if let currentPriority = self.selectedPriority {
                do {
                    try self.realm.write {
                        let newProject = Project()
                        newProject.name = textField.text!
                        //newItem.dateCreated = Date()
                        currentPriority.projects.append(newProject)
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
