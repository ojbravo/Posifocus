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
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(gestureRecognizer:)))
        self.tableView.addGestureRecognizer(longpress)

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .left {
            let markCompleteButton = SwipeAction(style: .default, title: "Done") { action, indexPath in
                // handle action by updating model with deletion
                
                self.markItemComplete(at: indexPath)
                
            }
            
            // customize the action appearance
            markCompleteButton.image = UIImage(named: "complete-icon")
            markCompleteButton.backgroundColor = UIColor.btnGreen
            markCompleteButton.hidesWhenSelected = true
            
            return [markCompleteButton]
        
        } else {
            let deleteButton = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                
                self.deleteItem(at: indexPath)
                
            }
            
            // customize the action appearance
            deleteButton.image = UIImage(named: "delete-icon")
            deleteButton.backgroundColor = UIColor.btnRed
            
            let editButton = SwipeAction(style: .default, title: "Edit") { action, indexPath in
                // handle action by updating model with deletion
                
                self.editItem(at: indexPath)
                
                
            }
            
            // customize the action appearance
            editButton.image = UIImage(named: "edit-icon")
            editButton.backgroundColor = UIColor.btnBlue
            editButton.hidesWhenSelected = true
            
            return [deleteButton, editButton]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = .border
        return options
    }
    
    func deleteItem(at indexPath: IndexPath) {}
    func editItem(at indexPath: IndexPath) {}
    func markItemComplete(at indexPath: IndexPath) { print("Marked Complete") }
    func setDataSource(at indexPath: IndexPath, initialIndex: Int) {}
    
    
    // Reorder Table Cells with longPressGesture
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        
        let longpress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longpress.state
        let locationInView = longpress.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: locationInView)
        
        switch state {
        case .began:
            if indexPath != nil {

                Path.initialIndexPath = indexPath
                let cell = self.tableView.cellForRow(at: indexPath!) as! SwipeTableViewCell
                My.cellSnapShot = snapshopOfCell(inputView: cell)
                var center = cell.center
                My.cellSnapShot?.center = center
                My.cellSnapShot?.alpha = 0.0
                self.tableView.addSubview(My.cellSnapShot!)
                
                UIView.animate(withDuration: 0.25, animations: {
                    center.y = locationInView.y
                    My.cellSnapShot?.center = center
                    My.cellSnapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapShot?.alpha = 0.98
                    cell.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell.isHidden = true
                    }
                })
            }
            
        case .changed:
            var center = My.cellSnapShot?.center
            center?.y = locationInView.y
            My.cellSnapShot?.center = center!
            
            
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                
                let initialIndex: Int = Int(Path.initialIndexPath!.row)
                self.setDataSource(at: indexPath!, initialIndex: initialIndex)
                
                self.tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                Path.initialIndexPath = indexPath
            }
            
        default:
            let cell = self.tableView.cellForRow(at: Path.initialIndexPath!) as! SwipeTableViewCell
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                My.cellSnapShot?.center = cell.center
                My.cellSnapShot?.transform = .identity
                My.cellSnapShot?.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapShot?.removeFromSuperview()
                    My.cellSnapShot = nil
                }
            })
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4

        return cellSnapshot
    }
    
    struct My {
        static var cellSnapShot: UIView? = nil
    }
    
    struct Path {
        static var initialIndexPath: IndexPath? = nil
    }
    // end Reorder with longPressGesture
    
    
}

extension UIColor {
    
    // Setup custom colours we can use throughout the app using hex values
    static let pfYellow = UIColor(red:0.99, green:0.75, blue:0.18, alpha:1.0)
    static let pfOrange = UIColor(red:0.99, green:0.35, blue:0.19, alpha:1.0)
    static let pfGreen = UIColor(red:0.55, green:0.76, blue:0.32, alpha:1.0)
    static let pfBerry = UIColor(red:0.92, green:0.08, blue:0.41, alpha:1.0)
    static let pfBlue = UIColor(red:0.05, green:0.56, blue:0.87, alpha:1.0)
    static let pfFrosted = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.25)
    
    static let btnGreen = UIColor(red:0.35, green:0.84, blue:0.43, alpha:1.0)
    static let btnBlue = UIColor(red:0.15, green:0.60, blue:0.98, alpha:1.0)
    static let btnRed = UIColor(red:0.98, green:0.25, blue:0.25, alpha:1.0)
    
    
    // Create a UIColor from RGB
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    // Create a UIColor from a hex value (E.g 0x000000)
    convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }
    
    func darker(darkness: CGFloat) -> UIColor {
        guard darkness <= 1.0 else { return self }
        
        let scalingFactor: CGFloat = darkness
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let newR = CGFloat.maximum(r * scalingFactor, 0.0),
        newG = CGFloat.maximum(g * scalingFactor, 0.0),
        newB = CGFloat.maximum(b * scalingFactor, 0.0)
        return UIColor(red: newR, green: newG, blue: newB, alpha: 1.0)
    }
}
