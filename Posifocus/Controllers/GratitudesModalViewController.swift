//
//  GratitudesModalViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 5/2/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

protocol GratitudesModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}


class GratitudesModalViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    let realm = try! Realm()
    var gratitudes: Results<Gratitude>?
    var indexPath: IndexPath? = nil
    
    weak var delegate: GratitudesModalViewControllerDelegate?
    
    override func viewDidLoad() {
        
        self.setupHideKeyboardOnTap()
        itemName.delegate = self
        itemNotes.delegate = self
        
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
        
        
        gratitudes = realm.objects(Gratitude.self).sorted(byKeyPath: "day", ascending: false)
        
        if (indexPath != nil) {
            itemName.text = gratitudes![(indexPath?.row)!].name
            itemNotes.text = gratitudes![(indexPath?.row)!].notes
            
            itemName.textColor = UIColor.white
            itemNotes.textColor = UIColor.white
            
        } else {
            // Initialize Placeholders for Gratitude Name and Details
            itemName.textColor = UIColor.lightGray
            itemName.delegate = self
            itemName.text = "Family / Clean Water / etc..."
            
            itemNotes.text = "My kids surprised me today by..."
            itemNotes.textColor = UIColor.lightGray
            itemNotes.delegate = self
        }
        
        // Set Save Button Color
        saveButton.backgroundColor = UIColor.pfGratitude
        
    }
    
    
    // Initialize Cancel Button
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    // Gratitude Name Text Field
    @IBOutlet weak var itemName: UITextField!
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (indexPath == nil) {
            itemName.text = ""
            itemName.textColor = UIColor.white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.text = "Family / Clean Water / etc..."
            textField.textColor = UIColor.lightGray
        }
    }
    
    
    // Gratitude Notes Text View
    @IBOutlet weak var itemNotes: UITextView!
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "My kids surprised me today by..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func saveGratitude(_ sender: UIButton) {
        
        // Update Existing Gratitude
        if (indexPath != nil) {
            do {
                try self.realm.write {
                    gratitudes![(indexPath?.row)!].name = itemName.text!
                    gratitudes![(indexPath?.row)!].notes = itemNotes.text
                }
            } catch {
                print("Error saving new items, \(error)")
            }
            
            
            
        }
        // Create New Gratitude
        else {
            do {
                try self.realm.write {
                    let newGratitude = Gratitude()
                    newGratitude.name = itemName.text!
                    newGratitude.notes = itemNotes.text!
                    realm.add(newGratitude)
                }
            } catch {
                print("Error saving new items, \(error)")
            }
        }

        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
}
