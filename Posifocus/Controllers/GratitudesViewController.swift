//
//  GratitudesViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 5/1/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class GratitudesViewController: SwipeTableViewController, GratitudesModalViewControllerDelegate {

    //let realm = try! Realm()
    //var gratitudes: Results<Gratitude>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 130.0
        self.tableView.backgroundColor = UIColor.pfGratitude.darker(darkness: 0.9)
        
        gratitudes = realm.objects(Gratitude.self).sorted(byKeyPath: "day", ascending: false)
        
        updateTableViewBackground(itemList: gratitudes!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfGratitude
        navigationController?.navigationBar.isTranslucent = false
        
        if (gratitudes?.count == 0) {
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "gratitudes-instructions-tableview.png"))
            self.tableView.backgroundView?.contentMode = UIViewContentMode.scaleAspectFit
            self.tableView.backgroundView?.alpha = 0.5
        }
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfBlue
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return gratitudes?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GratitudeCell
        cell.delegate = self
        cell.backgroundColor = UIColor.clear
        
        let shadowPath = UIBezierPath(rect: cell.gratitudeView.bounds).cgPath
        cell.gratitudeView.backgroundColor = UIColor.pfGratitude
        cell.gratitudeView.layer.cornerRadius = 2
        cell.gratitudeView.clipsToBounds = false
        cell.gratitudeView.layer.shadowColor = UIColor.black.cgColor
        cell.gratitudeView.layer.shadowOffset = CGSize(width: 0, height: 0);
        cell.gratitudeView.layer.shadowOpacity = 0.5
        cell.gratitudeView.layer.shadowRadius = 1
        cell.gratitudeView.layer.shadowPath = shadowPath
        
        cell.gratitudeName?.text = (gratitudes?[indexPath.row].name)!
        cell.gratitudeName.textColor = UIColor.white
        
        cell.gratitudeNotes?.text = (gratitudes?[indexPath.row].notes)!
        cell.gratitudeNotes.textColor = UIColor.white
        
        let day = gratitudes![indexPath.row].day
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        cell.gratitudeDate?.text = "\(dateFormatter.string(from: day))"
        
        //cell.gratitudeDate?.text = day
        cell.gratitudeDate.textColor = UIColor.white
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .left {
            return nil
        } else {
            let deleteButton = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                // handle action by updating model with deletion
                
                self.deleteItems(at: indexPath, itemList: self.gratitudes!)
                
            }
            
            // customize the action appearance
            deleteButton.image = UIImage(named: "delete-icon")
            deleteButton.backgroundColor = UIColor.btnRed
            
            return [deleteButton]
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ShowGratitudesModalView" {
                if let viewController = segue.destination as? GratitudesModalViewController {
                    if (tableView.indexPathForSelectedRow != nil) {
                        viewController.indexPath = tableView.indexPathForSelectedRow!
                    }
                    viewController.delegate = self as GratitudesModalViewControllerDelegate
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowGratitudesModalView", sender: indexPath);
    }
    
    func removeBlurredBackgroundView() {
        
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
        tableView.reloadData()
        
        updateTableViewBackground(itemList: gratitudes!)
    }
    
}


class GratitudeCell: SwipeTableViewCell {
    
    
    @IBOutlet weak var gratitudeView: UIView!
    @IBOutlet weak var gratitudeName: UILabel!

    @IBOutlet weak var gratitudeNotes: UITextView!
    @IBOutlet weak var gratitudeDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
