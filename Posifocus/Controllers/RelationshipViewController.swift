//
//  RelationshipViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 6/21/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class RelationshipViewController: SwipeTableViewController, RelationshipModalViewControllerDelegate {

    var relationships: Results<Relationship>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.pfRelationship.darker(darkness: 0.9)
        
        loadItems()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfRelationship
        navigationController?.navigationBar.isTranslucent = false
        
        if (relationships?.count == 0) {
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "relationships-instructions-tableview.png"))
            self.tableView.backgroundView?.contentMode = UIViewContentMode.scaleAspectFit
            self.tableView.backgroundView?.alpha = 0.5
        }
        
        loadItems()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfBlue
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationships?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        let startDate = relationships?[indexPath.row].lastContact
        let today = Date()
        let daysBetween = Calendar.current.dateComponents([.day], from: startDate!, to: today).day
        let label = (relationships?[indexPath.row].name)! + " (" + "\(daysBetween ?? 100)" + " days)"
        
        cell.textLabel?.text = label
        
        let cellRange = NSMakeRange(0, (cell.textLabel?.text?.count)!)
        let attributedText = NSMutableAttributedString(string: (cell.textLabel?.text)!)
        

        let numberOfRows = 1 - (CGFloat(indexPath.row) / CGFloat(relationships!.count + 3))
        
        cell.backgroundColor = UIColor.pfRelationship.darker(darkness: numberOfRows)
        cell.textLabel?.textColor = UIColor.white
        attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                    value: NSUnderlineStyle.styleNone.rawValue, range: cellRange)
        
        
        
        return cell
    }
    
    
    
    
    
//    // Perform Segue
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        performSegue(withIdentifier: "goToContacts", sender: self)
//        
//        //tableView.deselectRow(at: indexPath, animated: true)
//    }
    
    
    // Sends Selected Project to Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Captures sender and saves it as indexPath
        if let identifier = segue.identifier {
            if identifier == "ShowRelationshipModalView" {
                if let viewController = segue.destination as? RelationshipModalViewController {
                    if let indexPath = sender as? NSIndexPath {
                        if (indexPath.row != -1) {
                            viewController.indexPath = indexPath as IndexPath
                            viewController.itemList = relationships
                        }
                    }
                    
                    viewController.delegate = self as RelationshipModalViewControllerDelegate
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
            else {
                let destinationVC = segue.destination as! ContactViewController
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.parentItem = relationships?[indexPath.row]
                }
            }
        }
    }
    
    
    // Queries Database for Table Items
    func loadItems() {
        relationships = realm.objects(Relationship.self).sorted(byKeyPath: "lastContact", ascending: true)
        tableView.reloadData()
    }
    
    
    func addNewItem(itemName: String) {
        // Create New Item
        do {
            try self.realm.write {
                let newItem = Relationship()
                newItem.name = itemName
                realm.add(newItem)
            }
        } catch {
            print("Error saving new items, \(error)")
        }
        
        tableView.reloadData()
        
        updateTableViewBackground(itemList: relationships!)
    }
    
    
    func editItem(itemName: String, indexPath: IndexPath) {
        do {
            try self.realm.write {
                relationships![(indexPath.row)].name = itemName
            }
        } catch {
            print("Error saving new items, \(error)")
        }
    }
    
    
    override func deleteButtonPressed(at indexPath: IndexPath) {
        self.deleteItems(at: indexPath, itemList: self.relationships!)
    }

    
    // Handles when Swipe - Edit Button is tapped
    override func editButtonPressed(at indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowRelationshipModalView", sender: indexPath);
    }
    
    
    // Removes Blurred Background when Modal is dismissed
    func removeBlurredBackgroundView() {
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
        tableView.reloadData()
    }
}

