//
//  ProjectModalViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 6/5/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

protocol ProjectModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
    func addNewItem(itemName: String)
    func editItem(itemName: String, indexPath: IndexPath)
}

class ProjectModalViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    let realm = try! Realm()
    var itemList: Results<Project>?
    
    var indexPath: IndexPath? = nil
    weak var delegate: ProjectModalViewControllerDelegate?
    
    
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
        
        if (indexPath != nil) {
            itemName.text = itemList![(indexPath?.row)!].name
            itemName.textColor = UIColor.white
            
        } else {
            // Initialize Placeholders for Gratitude Name and Details
            itemName.textColor = UIColor.lightGray
            itemName.delegate = self
            itemName.text = "Backyard BBQ..."
        }
        
    }
    
    @IBOutlet weak var itemName: UITextField!
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if itemName.isFirstResponder == true {
            itemName.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.text = "Backyard BBQ..."
            textField.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if (indexPath != nil) {
            delegate?.editItem(itemName: itemName.text!, indexPath: indexPath!)
        }
        else {
            delegate?.addNewItem(itemName: itemName.text!)
        }
        
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    
}