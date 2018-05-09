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

class GratitudesViewController: SwipeTableViewController, ModalViewControllerDelegate {

    let realm = try! Realm()
    var gratitudes: Results<Gratitude>?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100.0
        self.tableView.backgroundColor = UIColor.pfBerry.darker(darkness: 0.9)
        
        gratitudes = realm.objects(Gratitude.self).sorted(byKeyPath: "day", ascending: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfBerry
        navigationController?.navigationBar.isTranslucent = false
        
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
        cell.gratitudeView.backgroundColor = UIColor.pfBerry
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
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ShowModalView" {
                if let viewController = segue.destination as? ModalViewController {
                    viewController.delegate = self as ModalViewControllerDelegate
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
        }
    }
    
    

    
    
    func removeBlurredBackgroundView() {
        
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
        tableView.reloadData()
    }
    
}


class GratitudeCell: SwipeTableViewCell {
    
    
    @IBOutlet weak var gratitudeView: UIView!
    @IBOutlet weak var gratitudeName: UILabel!
    @IBOutlet weak var gratitudeNotes: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
