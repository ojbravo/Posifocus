//
//  DashboardViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 5/10/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardViewController: UIViewController, UITextFieldDelegate {
    
    
    var cell: UITableViewCell?
    var gratitudes: Results<Gratitude>?
    var profiles: Results<Profile>?
    let profile = Profile()
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    
    @IBOutlet weak var profileName: UITextField!
    @IBOutlet weak var gratituteCount: UILabel!
    @IBOutlet weak var tasksCompleted: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (realm.objects(Profile.self).count == 0) {
            try! realm.write {
                realm.add(profile)
            }
        }
        
        profiles = realm.objects(Profile.self)
        
        profileName.backgroundColor = UIColor.clear
        profileName.borderStyle = .none
        profileName.textColor = UIColor.white
        profileName.text = "FirstName LastName"
        profileName.delegate = self
        profileName.text = profiles![0].name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        gratituteCount.text = String(realm.objects(Gratitude.self).count)
        tasksCompleted.text = String(profiles![0].tasksCompleted)
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (profileName.isFirstResponder == true && profiles![0].name == "") {
            profileName.text = ""
        }
        textField.textColor = UIColor.white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.text = "FirstName LastName"
            textField.textColor = UIColor.lightGray
            do {
                try realm.write {
                    profiles![0].name = ""
                }
            } catch {
                print("Error writing empty profile name to Realm, \(error)")
            }
        } else {
            
            do {
                try realm.write {
                    profiles![0].name = profileName.text!
                }
            } catch {
                print("Error writing profile name to Realm, \(error)")
            }
            textField.textColor = UIColor.white
        }
    }
    
    
}
