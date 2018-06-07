//
//  DashboardViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 5/10/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardViewController: UIViewController {
    
    
    var cell: UITableViewCell?
    var gratitudes: Results<Gratitude>?
    var profiles: Results<Profile>?
    let profile = Profile()
    
    
    @IBOutlet weak var gratituteCount: UILabel!
    @IBOutlet weak var tasksCompleted: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let realm = try! Realm()
        
        if (realm.objects(Profile.self).count == 0) {
            try! realm.write {
                realm.add(profile)
            }
        }
        profiles = realm.objects(Profile.self)
        
        gratituteCount.text = String(realm.objects(Gratitude.self).count)
        tasksCompleted.text = String(profiles![0].tasksCompleted)
    }
    
    
}
