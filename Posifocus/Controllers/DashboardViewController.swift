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
    
    let realm = try! Realm()
    var cell: UITableViewCell?
    var gratitudes: Results<Gratitude>?
    
    @IBOutlet weak var gratituteCount: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gratituteCount.text = String(realm.objects(Gratitude.self).count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gratituteCount.text = String(realm.objects(Gratitude.self).count)
    }
    
    
}
