//
//  SwipeTableViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/7/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    var cell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .left {
            let markCompleteButton = SwipeAction(style: .destructive, title: "Done") { action, indexPath in
                // handle action by updating model with deletion
                
                self.markItemComplete(at: indexPath)
                
            }
            
            // customize the action appearance
            markCompleteButton.image = UIImage(named: "complete-icon")
            markCompleteButton.backgroundColor = UIColor(hexString: "59d66e")
            markCompleteButton.hidesWhenSelected = true
            
            return [markCompleteButton]
        
        } else {
            let deleteButton = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                
                self.deleteItem(at: indexPath)
                
            }
            
            // customize the action appearance
            deleteButton.image = UIImage(named: "delete-icon")
            deleteButton.backgroundColor = UIColor(hexString: "f93f40")
            
            let editButton = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
                // handle action by updating model with deletion
                
                self.editItem(at: indexPath)
                
                
            }
            
            // customize the action appearance
            editButton.image = UIImage(named: "edit-icon")
            editButton.backgroundColor = UIColor(hexString: "2180f7")
            editButton.hidesWhenSelected = true
            
            return [deleteButton, editButton]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func deleteItem(at indexPath: IndexPath) {}
    func editItem(at indexPath: IndexPath) {}
    func markItemComplete(at indexPath: IndexPath) {}
}

