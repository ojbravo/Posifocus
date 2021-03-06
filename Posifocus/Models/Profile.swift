//
//  Profile.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 5/11/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class Profile: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var motto: String = ""
    @objc dynamic var profilePic: String = ""
    @objc dynamic var tasksCompleted: Int = 0
    @objc dynamic var lastContact: Int = 0
    
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}

