//
//  ProjectViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

//import UIKit
//import RealmSwift
//
//class ProjectViewController: UITableViewController {
//    
//    let realm = try! Realm()
//    
//    var projects = Results<Project>
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        loadProjects()
//    }
//    
//    // Defines number of cells to accomodate entire list
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        return projects.count ?? 1
//    }
//    
//    // Populates cells from database
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier:"ProjectCell", for: indexPath)
//        
//        cell.textLabel?.text = projects?[indexPath.row].name ?? "No Projects Added Yet"
//        
//        return cell
//    }
//    
//    
//    // Marks cells with checkmark
//    
//    
//    
//    // Load Projects from Database
//    func loadProjects() {
//        
//        projects = realm.objects(Project.self)
//        
//        tableView.reloadData()
//    }
//    
//    
//    // Add New Projects
//    
//    
//    
//    
//}
