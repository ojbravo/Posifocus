//
//  ContactViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 6/21/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ContactViewController: SwipeTableViewController, ContactModalViewControllerDelegate {
    
    var itemList: Results<Contact>?
    
    var parentItem : Relationship? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 130.0
        self.tableView.backgroundColor = UIColor.pfContact.darker(darkness: 0.9)
        
        loadItems()
        
        updateTableViewBackground(itemList: itemList!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfContact
        navigationController?.navigationBar.isTranslucent = false
        title = (parentItem?.name)!
        
        if (itemList?.count == 0) {
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "contacts-instructions-tableview.png"))
            self.tableView.backgroundView?.contentMode = UIViewContentMode.scaleAspectFit
            self.tableView.backgroundView?.alpha = 0.5
        }
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfRelationship
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList?.count ?? 1
    }
    
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotesCell
        cell.delegate = self
        cell.backgroundColor = UIColor.clear
        
        let shadowPath = UIBezierPath(rect: cell.itemView.bounds).cgPath
        cell.itemView.backgroundColor = UIColor.pfContact
        cell.itemView.layer.cornerRadius = 2
        cell.itemView.clipsToBounds = false
        cell.itemView.layer.shadowColor = UIColor.black.cgColor
        cell.itemView.layer.shadowOffset = CGSize(width: 0, height: 0);
        cell.itemView.layer.shadowOpacity = 0.5
        cell.itemView.layer.shadowRadius = 1
        cell.itemView.layer.shadowPath = shadowPath
        
        cell.itemName?.text = (itemList?[indexPath.row].name)!
        cell.itemName.textColor = UIColor.white
        
        cell.itemNotes?.text = (itemList?[indexPath.row].notes)!
        cell.itemNotes.textColor = UIColor.white
        
        let day = itemList![indexPath.row].day
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        cell.itemDate?.text = "\(dateFormatter.string(from: day))"
        cell.itemDate.textColor = UIColor.white
        
        return cell
    }
    
    
    // Queries Database for Table Items
    func loadItems() {
        itemList = parentItem?.contacts.sorted(byKeyPath: "day", ascending: false)
        tableView.reloadData()
    }
    
    func addNewItem(itemName: String, itemNotes: String, itemDate: Date) {
        print("Adding New Contact")
        // Create New Item
        if let currentParent = self.parentItem {
            do {
                try self.realm.write {
                    let newItem = Contact()
                    newItem.name = itemName
                    newItem.notes = itemNotes
                    newItem.day = itemDate
                    currentParent.contacts.append(newItem)
                    if (itemDate > currentParent.lastContact) {
                      currentParent.lastContact = itemDate
                    }
                    
                }
            } catch {
                print("Error saving new items, \(error)")
            }
        }
        
        updateLastContact()
        self.tableView.reloadData()
        updateTableViewBackground(itemList: itemList!)
    }
    
    
    func editItem(itemName: String, itemNotes: String, itemDate: Date, indexPath: IndexPath) {
        if let currentParent = self.parentItem {
            do {
                try self.realm.write {
                    itemList![(indexPath.row)].name = itemName
                    itemList![(indexPath.row)].notes = itemNotes
                    itemList![(indexPath.row)].day = itemDate
                    if (itemDate > currentParent.lastContact) {
                        currentParent.lastContact = itemDate
                    }
                }
            } catch {
                print("Error saving new items, \(error)")
            }
        }
        updateLastContact()
        self.tableView.reloadData()
    }
    
    func updateLastContact() {
        if let currentParent = self.parentItem {
            print(itemList![0].day)
            do {
                try self.realm.write {
                    currentParent.lastContact = itemList![0].day
                }
            } catch {
                print("Error setting last contact, \(error)")
            }
        }
    }
    
    override func deleteButtonPressed(at indexPath: IndexPath) {
        self.deleteItems(at: indexPath, itemList: self.itemList!)
        updateTableViewBackground(itemList: itemList!)
        updateLastContact()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Captures sender and saves it as indexPath
        if let identifier = segue.identifier {
            if identifier == "ShowContactModalView" {
                if let viewController = segue.destination as? ContactModalViewController {
                    if let indexPath = sender as? NSIndexPath {
                        // Handles Tapped Item
                        if (tableView.indexPathForSelectedRow != nil) {
                            viewController.indexPath = tableView.indexPathForSelectedRow!
                            viewController.itemList = itemList
                        }
                            // Handles Swipe - Edit Button
                        else if (indexPath.row != -1) {
                            viewController.indexPath = indexPath as IndexPath
                            viewController.itemList = itemList
                        }
                    }
                    
                    viewController.delegate = self as ContactModalViewControllerDelegate
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
        }
    }
    
    
    // Handles when item in list is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowContactModalView", sender: indexPath);
    }
    
    
    // Handles when Swipe - Edit Button is tapped
    override func editButtonPressed(at indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowContactModalView", sender: indexPath);
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
    
    
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindContactsToDashboard", sender: self)
    }
    
    
}

class NotesCell: SwipeTableViewCell {
    
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var itemNotes: UITextView!
    @IBOutlet weak var itemDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
