//
//  ViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit

class PrioritiesViewController: UITableViewController {

    var itemArray = ["Faith", "Family", "Friends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrioritiesCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
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
    
    // Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Priority", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Priority"
            textField = alertTextField
        }
        
        
        let action = UIAlertAction(title: "Add Priority", style: .default) { (action) in
            // this is where we say what happens once the button is clicked
            
            print(textField.text)
            
            self.itemArray.append(textField.text!)
            
            self.tableView.reloadData()
        }
        
        
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}

