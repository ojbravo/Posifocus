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
            let markComplete = SwipeAction(style: .destructive, title: "Complete") { action, indexPath in
                // handle action by updating model with deletion
                
                self.updateModel(at: indexPath)
                
            }
            
            // customize the action appearance
            markComplete.image = UIImage(named: "complete-icon")
            markComplete.backgroundColor = UIColor(hexString: "59d66e")
            
            return [markComplete]
        
        } else {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                
                self.updateModel(at: indexPath)
                
            }
            
            // customize the action appearance
            deleteAction.image = UIImage(named: "delete-icon")
            deleteAction.backgroundColor = UIColor(hexString: "f93f40")
            
            let editAction = SwipeAction(style: .destructive, title: "Edit") { action, indexPath in
                // handle action by updating model with deletion
                
                self.updateModel(at: indexPath)
                
            }
            
            // customize the action appearance
            editAction.image = UIImage(named: "edit-icon")
            editAction.backgroundColor = UIColor(hexString: "2180f7")
            
            return [deleteAction, editAction]
        }
        
        
        //guard orientation == .right else { return nil }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        
    }
}

