//
//  ContactModalViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 6/21/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

protocol ContactModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
    func addNewItem(itemName: String, itemNotes: String)
    func editItem(itemName: String, itemNotes: String, indexPath: IndexPath)
}

class ContactModalViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    let realm = try! Realm()
    var itemList: Results<Contact>?
    
    var indexPath: IndexPath? = nil
    weak var delegate: ContactModalViewControllerDelegate?
    
    
    override func viewDidLoad() {
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
            itemNotes.text = itemList![(indexPath?.row)!].notes
            
            itemName.textColor = UIColor.white
            itemNotes.textColor = UIColor.white
            
        } else {
            // Initialize Placeholders for Gratitude Name and Details
            itemName.textColor = UIColor.lightGray
            itemName.delegate = self
            itemName.text = "Call / Text / Email / Lunch..."
            
            itemNotes.text = "Making plans to meet up this weekend..."
            itemNotes.textColor = UIColor.lightGray
            itemNotes.delegate = self
        }
        
        // Set Save Button Color
        saveButton.backgroundColor = UIColor.pfContact
        
    }
    
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemNotes: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if itemName.isFirstResponder == true {
            itemName.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.text = "Call / Text / Email / Lunch..."
            textField.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Making plans to meet up this weekend..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if (indexPath != nil) {
            delegate?.editItem(itemName: itemName.text!, itemNotes: itemNotes.text!, indexPath: indexPath!)
        }
        else {
            delegate?.addNewItem(itemName: itemName.text!, itemNotes: itemNotes.text!)
        }
        
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    
}
