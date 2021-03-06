//
//  ProjectViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectViewController: SwipeTableViewController, ProjectModalViewControllerDelegate {
    
    //let realm = try! Realm()
    var projects: Results<Project>?
    
    var selectedPriority : Priority? {
        didSet{
            loadProjects()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.pfProject.darker(darkness: 0.9)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfProject
        navigationController?.navigationBar.backgroundColor = UIColor.pfProject
        navigationController?.navigationBar.isTranslucent = false
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.pfProject
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        title = (selectedPriority?.name)! + " Projects"
        
        if (projects?.count == 0) {
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "projects-instructions-tableview.png"))
            self.tableView.backgroundView?.contentMode = UIView.ContentMode.scaleAspectFit
            self.tableView.backgroundView?.alpha = 0.5
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfPriority
    }
    
    // Defines number of cells to accomodate entire list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return projects?.count ?? 1
    }
    
    // Populates cells from database
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        //let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath)
        
        cell.textLabel?.text = projects?[indexPath.row].name ?? "No Projects Added Yet"
        
        let cellRange = NSMakeRange(0, (cell.textLabel?.text?.count)!)
        let attributedText = NSMutableAttributedString(string: (cell.textLabel?.text)!)
        
        if (projects?[indexPath.row].completed)! {
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.lightGray
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                        value: NSUnderlineStyle.single.rawValue, range: cellRange)
            
            
            cell.textLabel?.attributedText =  attributedText
            
        } else {
            let numberOfRows = 1 - (CGFloat(indexPath.row) / CGFloat(projects!.count + 3))
            
            cell.backgroundColor = UIColor.pfProject.darker(darkness: numberOfRows)
            cell.textLabel?.textColor = UIColor.white
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                        value: [], range: cellRange)
        }
        
        
        return cell
    }
    
    
    // Connects to Segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTasks", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // Sends Selected Project to Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Captures sender and saves it as indexPath
        if let identifier = segue.identifier {
            if identifier == "ShowProjectModalView" {
                if let viewController = segue.destination as? ProjectModalViewController {
                    if let indexPath = sender as? NSIndexPath {
                        if (indexPath.row != -1) {
                            viewController.indexPath = indexPath as IndexPath
                            viewController.itemList = projects
                        }
                    }
                    
                    viewController.delegate = self as ProjectModalViewControllerDelegate
                    viewController.modalPresentationStyle = .overFullScreen
                }
            }
            else if identifier == "goToTasks" {
                let destinationVC = segue.destination as! TaskViewController
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    destinationVC.selectedProject = projects?[indexPath.row]
                }
            }
        }
    }
    
    
    
    // Queries Projects from Database
    func loadProjects() {
        
        projects = selectedPriority?.projects.sorted(byKeyPath: "order", ascending: true)
        tableView.reloadData()
    }
    
//    // Save Projects to Database
//    func save(project: Project) {
//        do {
//            try realm.write {
//                realm.add(project)
//            }
//        }
//        catch {
//            print("Error writing priority \(error)")
//        }
//    }
//
//    // Add New Projects Button
//    @IBAction func addNewProject(_ sender: UIBarButtonItem) {
//
//        var textField = UITextField()
//
//        let alert = UIAlertController(title: "Add Project", message: "", preferredStyle: .alert)
//
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "Add New Project"
//            textField = alertTextField
//        }
//
//
//        let action = UIAlertAction(title: "Add Project", style: .default) { (action) in
//            // this is where we say what happens once the button is clicked
//
//            if let currentPriority = self.selectedPriority {
//                do {
//                    try self.realm.write {
//                        let newProject = Project()
//                        newProject.name = textField.text!
//                        newProject.order = (self.projects?.count)!
//                        currentPriority.projects.append(newProject)
//                    }
//                } catch {
//                    print("Error saving new items, \(error)")
//                }
//            }
//
//            self.tableView.reloadData()
//
//        }
//
//        alert.addAction(action)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        present(alert, animated: true, completion: nil)
//    }
    
    override func deleteButtonPressed(at indexPath: IndexPath) {
        self.deleteItems(at: indexPath, itemList: self.projects!)
    }
    
    
    
//    override func deleteItem(at indexPath: IndexPath) {
//
//        if let deleteProject = self.projects?[indexPath.row] {
//            do {
//                try self.realm.write {
//                    if deleteProject.tasks.count != 0 {
//                        self.realm.delete(deleteProject.tasks)
//                    }
//                    self.realm.delete(deleteProject)
//
//                    var i = 0
//                    while i < ((projects?.count)!) {
//                        self.projects![i].setValue(i, forKey: "order")
//                        i = i + 1
//                    }
//                }
//            } catch {
//                print("Couldn't delete project \(error)")
//            }
//        }
//
//    }
    
//    override func editButtonPressed(at indexPath: IndexPath) {
//
//        var textField = UITextField()
//        let currentProject = projects![indexPath.row].name
//
//        let alert = UIAlertController(title: "Update Project", message: "", preferredStyle: .alert)
//
//        alert.addTextField { (alertTextField) in
//            alertTextField.text = currentProject
//            textField = alertTextField
//        }
//
//
//        let action = UIAlertAction(title: "Update", style: .default) { (action) in
//            // this is where we say what happens once the button is clicked
//
//            if self.selectedPriority != nil {
//                do {
//                    try self.realm.write {
//                        self.projects![indexPath.row].name = textField.text!
//                    }
//                } catch {
//                    print("Error saving new items, \(error)")
//                }
//            }
//
//            self.tableView.reloadData()
//
//        }
//
//        alert.addAction(action)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        present(alert, animated: true, completion: nil)
//
//    }
    
    
    
    
    func addNewItem(itemName: String) {
        // Create New Item
        if let currentPriority = self.selectedPriority {
            do {
                try self.realm.write {
                    let newItem = Project()
                    newItem.name = itemName
                    newItem.order = (projects?.count)!
                    currentPriority.projects.append(newItem)
                }
            } catch {
                print("Error saving new items, \(error)")
            }
        }
        
        self.tableView.reloadData()
        
        updateTableViewBackground(itemList: projects!)
    }
    
    
    func editItem(itemName: String, indexPath: IndexPath) {
        do {
            try self.realm.write {
                projects![(indexPath.row)].name = itemName
            }
        } catch {
            print("Error saving new items, \(error)")
        }
    }
    
    
    override func markItemComplete(at indexPath: IndexPath) {
        
        // Mark Item Complete
        if (projects![indexPath.row].completed == false) {
            
            // Mark item complete and move to the end of the list
            do {
                try realm.write {
                    let lastPosition = (projects?.count)!
                    projects![indexPath.row].setValue(true, forKey: "completed")
                    projects![indexPath.row].setValue(lastPosition, forKey: "order")
                    
                }
            } catch {
                print("Error updating items after marked complete, \(error)")
            }
            
            
            // Shift all items up in the list by one position
            var i = 0
            while i < ((projects?.count)!) {
                if (i >= indexPath.row) {
                    do {
                        try self.realm.write {
                            let shiftUp = i
                            projects![i].setValue(shiftUp, forKey: "order")
                        }
                    } catch {
                        print("Error updating items after marked complete, \(error)")
                    }
                }
                
                i = i + 1
            }
            tableView.reloadData()
            
            
            
            loadProjects()
        }
            
            // Mark Item NOT Complete
        else {
            
            // Mark item NOT Completed
            do {
                try self.realm.write {
                    
                    projects![indexPath.row].setValue(false, forKey: "completed")
                    projects![indexPath.row].setValue((-1), forKey: "order")
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
                        projects![i].setValue(shiftDown, forKey: "order")
                    }
                } catch {
                    print("Error updating items after marked complete, \(error)")
                }
                
                
                i = i - 1
            }
            
            // Set item order to 0
            do {
                try self.realm.write {
                    projects![0].setValue(0, forKey: "order")
                }
            } catch {
                print("Error updating items after marked complete, \(error)")
            }
            
            loadProjects()
        }
    }
    
    
    override func setDataSource(at indexPath: IndexPath, initialIndex: Int) {
        var projectsList = Array(self.projects!)
        projectsList.swapAt((indexPath.row), (Path.initialIndexPath?.row)!)
        
        do {
            try self.realm.write {
                let originalRow: Int = (Path.initialIndexPath?.row)!
                let newRow: Int = indexPath.row;
                
                if (newRow < originalRow) {
                    self.projects![(newRow)].setValue(-1, forKey: "order")
                    self.projects![(originalRow)].setValue(newRow, forKey: "order")
                    self.tableView.reloadData()
                    self.projects![0].setValue(originalRow, forKey: "order")
                } else {
                    self.projects![(newRow)].setValue(projects?.count, forKey: "order")
                    self.projects![(originalRow)].setValue(newRow, forKey: "order")
                    self.tableView.reloadData()
                    self.projects![(projects?.count)! - 1].setValue(originalRow, forKey: "order")
                }
                self.tableView.reloadData()
            }
        } catch {
            print("Error saving new items, \(error)")
        }
    }
    

    // Handles when Swipe - Edit Button is tapped
    override func editButtonPressed(at indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowProjectModalView", sender: indexPath);
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
        performSegue(withIdentifier: "unwindProjectsToDashboard", sender: self)
    }
    
}
