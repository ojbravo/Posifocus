//
//  DashboardViewController.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 5/10/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var cell: UITableViewCell?
    var gratitudes: Results<Gratitude>?
    var profiles: Results<Profile>?
    let profile = Profile()
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileName: UITextField!
    @IBOutlet weak var profileMotto: UITextView!
    @IBOutlet weak var gratitudeCount: UILabel!
    @IBOutlet weak var tasksCompleted: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (realm.objects(Profile.self).count == 0) {
            try! realm.write {
                realm.add(profile)
            }
        }
        
        profiles = realm.objects(Profile.self)
        
        let imagePath = getDocumentsDirectory().appendingPathComponent(profiles![0].profilePic)
        profilePicture.image = UIImage(contentsOfFile: imagePath.path)
        
        profileName.backgroundColor = UIColor.clear
        profileName.borderStyle = .none
        profileName.delegate = self
        
        if (profiles![0].name == "") {
            profileName.text = "FirstName LastName"
            profileName.textColor = UIColor.lightGray
        } else {
            profileName.text = profiles![0].name
            profileName.textColor = UIColor.white
        }
        
        
        profileMotto.delegate = self
        profileMotto.textContainerInset = UIEdgeInsets.zero
        profileMotto.textContainer.lineFragmentPadding = 0
        
        if (profiles![0].motto == "") {
            profileMotto.text = "Catchphrase, Slogan, or Inspirational Quote"
            profileMotto.textColor = UIColor.lightGray
        } else {
            profileMotto.text = profiles![0].motto
            profileMotto.textColor = UIColor.white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        gratitudeCount.text = String(realm.objects(Gratitude.self).count)
        tasksCompleted.text = String(profiles![0].tasksCompleted)
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (profileName.isFirstResponder == true && profiles![0].name == "") {
            profileName.text = ""
            textField.textColor = UIColor.white
        }
        
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
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Catchphrase, Slogan, or Inspirational Quote"
            textView.textColor = UIColor.lightGray
            
            do {
                try realm.write {
                    profiles![0].motto = ""
                }
            } catch {
                print("Error writing empty profile motto to Realm, \(error)")
            }
        }
        else {
            do {
                try realm.write {
                    profiles![0].motto = profileMotto.text!
                }
            } catch {
                print("Error writing profile motto to Realm, \(error)")
            }
        }
    }
    
    
    
    
    // Selecting Profile Picture
    @IBAction func selectProfilePicture(_ sender: Any) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        profilePicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = UIImageJPEGRepresentation(profilePicture.image!, 80) {
            try? jpegData.write(to: imagePath)
        }
        
        do {
            try realm.write {
                print(imagePath)
                profiles![0].profilePic = imageName
            }
        } catch {
            print("Error writing profilePic url to Realm, \(error)")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
