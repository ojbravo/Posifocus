//
//  ViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift
//import ChameleonFramework

class PrioritiesViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var priorities: Results<Priority>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.pfGreen.darker(darkness: 0.9)
        
        priorities = realm.objects(Priority.self).sorted(byKeyPath: "order", ascending: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfGreen.darker(darkness: 0.9)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfBlue
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priorities?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = priorities?[indexPath.row].name ?? "No Priorities Added Yet"
        
        let cellRange = NSMakeRange(0, (cell.textLabel?.text?.count)!)
        let attributedText = NSMutableAttributedString(string: (cell.textLabel?.text)!)
        
        if (priorities?[indexPath.row].completed)! {
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.lightGray
            attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                        value: NSUnderlineStyle.styleSingle.rawValue, range: cellRange)
            
            
            cell.textLabel?.attributedText =  attributedText
            
        } else {
            let numberOfRows = 1 - (CGFloat(indexPath.row) / CGFloat(priorities!.count + 3))

            cell.backgroundColor = UIColor.pfGreen.darker(darkness: numberOfRows)
            cell.textLabel?.textColor = UIColor.white
            attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                        value: NSUnderlineStyle.styleNone.rawValue, range: cellRange)
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
        
        priorities = realm.objects(Priority.self).sorted(byKeyPath: "order", ascending: true)
        
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
            newPriority.order = (self.priorities?.count)!
        
            self.save(priority: newPriority)
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func deleteItem(at indexPath: IndexPath) {
        if let deletePriority = self.priorities?[indexPath.row] {
            let deleteProjectsCount = deletePriority.projects.count
            
            //if tasks.count, if projects.count
            
            do {
                try self.realm.write {
                    if deleteProjectsCount != 0 {
                        for i in 0...(deleteProjectsCount - 1) {
                            if deletePriority.projects[i].tasks.count != 0 {
                                self.realm.delete(deletePriority.projects[i].tasks)
                            }
                        }
                        self.realm.delete(deletePriority.projects)
                    }
                    self.realm.delete(deletePriority)
                }
            } catch {
                print("Couldn't delete priority \(error)")
            }
        }
    }
    
    override func editItem(at indexPath: IndexPath) {
        
        var textField = UITextField()
        let currentPriority = priorities![indexPath.row].name
        
        let alert = UIAlertController(title: "Update Priority", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.text = currentPriority
            textField = alertTextField
        }
        
        
        let action = UIAlertAction(title: "Update", style: .default) { (action) in
            // this is where we say what happens once the button is clicked
            
            do {
                try self.realm.write {
                    self.priorities![indexPath.row].name = textField.text!
                }
            } catch {
                print("Error saving new items, \(error)")
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    override func markItemComplete(at indexPath: IndexPath) {
        
        // Mark Item Complete
        if (priorities![indexPath.row].completed == false) {
            
            // Mark item complete and move to the end of the list
            do {
                try realm.write {
                    let lastPosition = (priorities?.count)!
                    priorities![indexPath.row].setValue(true, forKey: "completed")
                    priorities![indexPath.row].setValue(lastPosition, forKey: "order")
                    
                }
            } catch {
                print("Error updating items after marked complete, \(error)")
            }
            
            
            // Shift all items up in the list by one position
            var i = 0
            while i < ((priorities?.count)!) {
                if (i >= indexPath.row) {
                    do {
                        try self.realm.write {
                            let shiftUp = i
                            priorities![i].setValue(shiftUp, forKey: "order")
                        }
                    } catch {
                        print("Error updating items after marked complete, \(error)")
                    }
                }
                
                i = i + 1
            }
            tableView.reloadData()
            
            
            
            loadPriorities()
        }
            
            // Mark Item NOT Complete
        else {
            
            // Mark item NOT Completed
            do {
                try self.realm.write {
                    
                    priorities![indexPath.row].setValue(false, forKey: "completed")
                    priorities![indexPath.row].setValue((-1), forKey: "order")
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
                        priorities![i].setValue(shiftDown, forKey: "order")
                    }
                } catch {
                    print("Error updating items after marked complete, \(error)")
                }
                
                
                i = i - 1
            }
            
            // Set item order to 0
            do {
                try self.realm.write {
                    priorities![0].setValue(0, forKey: "order")
                }
            } catch {
                print("Error updating items after marked complete, \(error)")
            }
            
            loadPriorities()
        }
    }
    
    
    // Reorder Table Cells
    override func setDataSource(at indexPath: IndexPath, initialIndex: Int) {
        var prioritiesList = Array(self.priorities!)
        prioritiesList.swapAt((indexPath.row), (Path.initialIndexPath?.row)!)
        
        
        do {
            try self.realm.write {
                let originalRow: Int = (Path.initialIndexPath?.row)!
                let newRow: Int = indexPath.row;
                
                if (newRow < originalRow) {
                    self.priorities![(newRow)].setValue(-1, forKey: "order")
                    self.priorities![(originalRow)].setValue(newRow, forKey: "order")
                    self.tableView.reloadData()
                    self.priorities![0].setValue(originalRow, forKey: "order")
                } else {
                    self.priorities![(newRow)].setValue(priorities?.count, forKey: "order")
                    self.priorities![(originalRow)].setValue(newRow, forKey: "order")
                    self.tableView.reloadData()
                    self.priorities![(priorities?.count)! - 1].setValue(originalRow, forKey: "order")
                }
                self.tableView.reloadData()
            }
        } catch {
            print("Error saving new items, \(error)")
        }
    }
}

