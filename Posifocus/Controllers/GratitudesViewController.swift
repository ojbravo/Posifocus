//
//  GratitudesViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 5/1/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class GratitudesViewController: SwipeTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.pfBerry.darker(darkness: 0.9) //
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.pfBerry
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.pfBlue
    }
    
}
