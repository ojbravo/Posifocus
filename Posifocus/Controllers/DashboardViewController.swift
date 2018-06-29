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
    var relationships: Results<Relationship>?
    var projects: Results<Project>?
    var tasks: Results<Task>?
    var profiles: Results<Profile>?
    let profile = Profile()
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
    

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileName: UITextField!
    @IBOutlet weak var profileMotto: UITextView!
    @IBOutlet weak var gratitudeCount: UILabel!
    @IBOutlet weak var tasksCompleted: UILabel!
    @IBOutlet weak var lastContact: UILabel!
    @IBOutlet weak var currentProjectCount: UILabel!
    @IBOutlet weak var currentTaskCount: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBarImage()
        backgroundImage.image = UIImage(named: "bdlp-paradise-wallpaper.jpg")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha = 0.1
        
        //self.view.backgroundColor = UIColor.pfGreen.darker(darkness: 0.9)
        
        
        if (realm.objects(Profile.self).count == 0) {
            try! realm.write {
                realm.add(profile)
            }
        }
        
        profiles = realm.objects(Profile.self)
        
        if (profiles![0].profilePic == "") {
            profilePicture.image = UIImage(named: "blank-user.png")
        }
        else {
            let imagePath = getDocumentsDirectory().appendingPathComponent(profiles![0].profilePic)
            // Throws BOMStream Warning
            profilePicture.image = UIImage(contentsOfFile: imagePath.path)
        }
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.borderColor = UIColor.white.cgColor
        
        
        profileName.backgroundColor = UIColor.clear
        profileName.borderStyle = .none
        profileName.delegate = self
        
        if (profiles![0].name == "") {
            profileName.text = "FirstName LastName"
            profileName.textColor = UIColor.white
        } else {
            profileName.text = profiles![0].name
            profileName.textColor = UIColor.white
        }
        
        
        profileMotto.delegate = self
        profileMotto.textContainerInset = UIEdgeInsets.zero
        profileMotto.textContainer.lineFragmentPadding = 0
        
        if (profiles![0].motto == "") {
            profileMotto.text = "Catchphrase, Slogan, or Inspirational Quote"
            profileMotto.textColor = UIColor.white
        } else {
            profileMotto.text = profiles![0].motto
            profileMotto.textColor = UIColor.white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.barTintColor = UIColor.pfBlue
        navigationController?.navigationBar.isTranslucent = false
        
        gratitudeCount.text = String(realm.objects(Gratitude.self).count)
        tasksCompleted.text = String(profiles![0].tasksCompleted)
        currentProjectCount.text = String(realm.objects(Project.self).count)
        currentTaskCount.text = String(realm.objects(Task.self).count)
        
        relationships = realm.objects(Relationship.self).sorted(byKeyPath: "lastContact", ascending: true)
        if (relationships?.count == 0) {
            lastContact.text = "n/a"
        }
        else {
            let startDate = relationships![0].lastContact
            let today = Date()
            let daysBetween = Calendar.current.dateComponents([.day], from: startDate, to: today).day
            
            lastContact.text = "\(daysBetween!)"
        }
        
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
            textField.textColor = UIColor.white
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
        if (profiles![0].motto == "") {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Catchphrase, Slogan, or Inspirational Quote"
            textView.textColor = UIColor.white
            
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
    
    
    func addNavBarImage() {
        let navController = navigationController!
        
        let image = #imageLiteral(resourceName: "posifocus-logo.png")
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image.size.width / 2
        let bannerY = bannerHeight / 2 - image.size.height / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
        
    }
    
    
}
