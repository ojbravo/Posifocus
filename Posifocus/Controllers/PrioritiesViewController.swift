//
//  ViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class PrioritiesViewController: UITableViewController {

    let realm = try! Realm()
    
    var priorities: Results<Priority>?
    
    let themeColor: String = "8CC252"  //green
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPriorities()
        
        tableView.separatorStyle = .none
        navigationController?.navigationBar.barTintColor = UIColor(hexString: themeColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(hexString: themeColor)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priorities?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrioritiesCell", for: indexPath)
        
        cell.textLabel?.text = priorities?[indexPath.row].name ?? "No Priorities Added Yet"
        
        if let bgcolor = UIColor(hexString: themeColor)?.darken(byPercentage:
            CGFloat(indexPath.row) / CGFloat(priorities!.count + 3)) {
                
                cell.backgroundColor = bgcolor
                cell.textLabel?.textColor = UIColor.white
        }
        
        
        return cell
    }
    
    
    
    // Perform Segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToProjects", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ProjectViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedPriority = priorities?[indexPath.row]
        }
    }
    
    
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

