//
//  TaskModalViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 6/1/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

protocol TaskModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
    func addNewItem(itemName: String, todaySwitchStatus: Bool)
    func editItem(itemName: String, todaySwitchStatus: Bool, indexPath: IndexPath)
}

class TaskModalViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    let realm = try! Realm()
    var itemList: Results<Task>?
    
    var indexPath: IndexPath? = nil
    weak var delegate: TaskModalViewControllerDelegate?
    
    var todaySwitchStatus: Bool = false
    
    
    override func viewDidLoad() {
        self.setupHideKeyboardOnTap()
        itemName.delegate = self
        
        // Add blurEffect to background
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        
        // Add Vibrancy to Modal Contents
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(vibrancyView)
        
        NSLayoutConstraint.activate([
            vibrancyView.heightAnchor.constraint(equalTo: blurView.contentView.heightAnchor),
            vibrancyView.widthAnchor.constraint(equalTo: blurView.contentView.widthAnchor),
            vibrancyView.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            vibrancyView.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
            ])
        
        
        //itemList = realm.objects(Task.self).sorted(byKeyPath: "order", ascending: false)
        
        if (indexPath != nil) {
            itemName.text = itemList![(indexPath?.row)!].name
            itemName.textColor = UIColor.white
            todaySwitchStatus = itemList![(indexPath?.row)!].today
            if (todaySwitchStatus == true) {
                todaySwitch.isOn = true
            }
            
        } else {
            // Initialize Placeholders for Gratitude Name and Details
            itemName.textColor = UIColor.lightGray
            itemName.delegate = self
            itemName.text = "Send Party Invite..."
        }
        
        // Set Save Button Color
        saveButton.backgroundColor = UIColor.pfTask
        
        
    }
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var todaySwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (indexPath == nil) {
            itemName.text = ""
            itemName.textColor = UIColor.white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.text = "Send Party Invite..."
            textField.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func todaySwitchChanged(_ sender: UISwitch) {
        todaySwitchStatus = todaySwitch.isOn
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if (indexPath != nil) {
            delegate?.editItem(itemName: itemName.text!, todaySwitchStatus: todaySwitchStatus, indexPath: indexPath!)
        }
        else {
            delegate?.addNewItem(itemName: itemName.text!, todaySwitchStatus: todaySwitchStatus)
        }
        
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

