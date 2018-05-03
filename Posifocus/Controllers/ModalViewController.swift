//
//  ModalViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 5/2/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}


class ModalViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    weak var delegate: ModalViewControllerDelegate?
    
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
        
        
        
        // Initialize Placeholders for Gratitude Name and Details
        gratitudeName.textColor = UIColor.lightGray
        gratitudeName.delegate = self
        gratitudeName.text = "Family / Clean Water / etc..."
        
        gratitudeNotes.text = "My kids surprised me today by..."
        gratitudeNotes.textColor = UIColor.lightGray
        gratitudeNotes.delegate = self
    }
    
    
    // Initialize Cancel Button
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    // Gratitude Name Text Field
    @IBOutlet weak var gratitudeName: UITextField!
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if gratitudeName.isFirstResponder == true {
            gratitudeName.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            textField.text = "Family / Clean Water / etc..."
            textField.textColor = UIColor.lightGray
        }
    }
    
    
    // Gratitude Notes Text View
    @IBOutlet weak var gratitudeNotes: UITextView!
    
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
    
    
}
