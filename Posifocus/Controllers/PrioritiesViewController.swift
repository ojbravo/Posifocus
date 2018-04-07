//
//  ViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class PrioritiesViewController: UITableViewController {

    let realm = try! Realm()
    
    var priorities: Results<Priority>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPriorities()
        
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priorities?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrioritiesCell", for: indexPath)
        
        cell.textLabel?.text = priorities?[indexPath.row].name ?? "No Priorities Added Yet"
        
        return cell
    }
    
    
    
    // Perform Segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToProjects", sender: self)
    }
    
    
    // Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ProjectViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedPriority = priorities?[indexPath.row]
        }
    }
    
    
    
    
//    // Marks cells with checkmark
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        }
//        else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//    }
    
    // Queries Database for Priorities
    func loadPriorities() {
        
        priorities = realm.objects(Priority.self)
        
        tableView.reloadData()
    }
    
    // Save Priority to Database
    func save(priority: Priority) {
        do {
            try realm.write {
                realm.add(priority)
            }
        }
        catch {
            print("Error writing priority \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    // Add Priority (+) Button Pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Priority", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Priority"
            textField = alertTextField
        }
        
        
        let action = UIAlertAction(title: "Add Priority", style: .default) { (action) in
            // this is where we say what happens once the button is clicked
            
            let newPriority = Priority()
            newPriority.name = textField.text!
        
            self.save(priority: newPriority)
        }
        
        
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}

