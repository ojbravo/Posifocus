//
//  TodayTaskViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 7/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class TodayTaskViewController: TaskViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.pfTask
        profiles = realm.objects(Profile.self)
        loadTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Today's Tasks"
    }
    
    // Queries Tasks from Database
    override func loadTasks() {
        tasks = realm.objects(Task.self).filter("today == true").sorted(byKeyPath: "order", ascending: true)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Captures sender and saves it as indexPath
        if let identifier = segue.identifier {
            if (identifier == "ShowTaskModalView2") {
                if let viewController = segue.destination as? TaskModalViewController {
                    if let indexPath = sender as? NSIndexPath {
                        // Handles Tapped Item
                        if (tableView.indexPathForSelectedRow != nil) {
                            viewController.indexPath = tableView.indexPathForSelectedRow!
                            viewController.itemList = tasks
                        }
                            // Handles Swipe - Edit Button
                        else if (indexPath.row != -1) {
                            viewController.indexPath = indexPath as IndexPath
                            viewController.itemList = tasks
                        }
                    }
                    
                    viewController.delegate = self as TaskModalViewControllerDelegate
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
        }
    }
    
    // Handles when item in list is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowTaskModalView2", sender: indexPath);
    }
    
    
    // Handles when Swipe - Edit Button is tapped
    override func editButtonPressed(at indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowTaskModalView2", sender: indexPath);
    }
    
}
