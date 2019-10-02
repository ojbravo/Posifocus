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
    
    var gratitudesMissed: Int = 0
    
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
    @IBOutlet weak var missedGratitudeLabel: UILabel!
    @IBOutlet weak var currentProjectCount: UILabel!
    @IBOutlet weak var currentTaskCount: UILabel!
    
    // Buttons
    @IBOutlet weak var GratitudeButtonView: UIView!
    @IBOutlet weak var PrioritiesButtonView: UIView!
    @IBOutlet weak var RelationshipButtonView: UIView!
    @IBOutlet weak var TodaysTasksButtonView: UIView!
    @IBOutlet weak var ProjectsButtonView: UIView!
    @IBOutlet weak var TasksButtonView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavBarImage()
        backgroundImage.image = UIImage(named: "bdlp-paradise-wallpaper.jpg")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.alpha = 0.1
        
        // Button Colors
        GratitudeButtonView.backgroundColor = UIColor.pfGratitude
        PrioritiesButtonView.backgroundColor = UIColor.pfPriority
        ProjectsButtonView.backgroundColor = UIColor.pfProject
        TasksButtonView.backgroundColor = UIColor.pfTask
        RelationshipButtonView.backgroundColor = UIColor.pfRelationship
        TodaysTasksButtonView.backgroundColor = UIColor.pfToday
        
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
        
        NotificationCenter.default.addObserver(self, selector:#selector(updateBadgeCounter), name:.NSCalendarDayChanged, object:nil)
        
        missedGratitudeLabel.layer.masksToBounds = true
        missedGratitudeLabel.layer.cornerRadius = 13
        
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
        
        updateBadgeCounter()
        missedGratitudeLabel.text = "\(gratitudesMissed)"
        if (gratitudesMissed == 0) {
            missedGratitudeLabel.isHidden = true
        } else {
            missedGratitudeLabel.isHidden = false
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
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        profilePicture.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = profilePicture.image!.jpegData(compressionQuality: 80) {
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
    
    //  Sets Notification Badge = Missed Gratitudes
    @objc func updateBadgeCounter()
    {
        gratitudes = realm.objects(Gratitude.self).sorted(byKeyPath: "day", ascending: false)
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if (gratitudes?.count == 0) {
            gratitudesMissed = 1
        } else {
            let startDate = gratitudes?[0].day
            let today = Date()
            gratitudesMissed = Calendar.current.dateComponents([.day], from: startDate!, to: today).day!
        }
        

        UIApplication.shared.applicationIconBadgeNumber = gratitudesMissed
    }
    
    
    @IBAction func unwindToDashboard(segue:UIStoryboardSegue) { }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
