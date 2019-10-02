//
//  Contact.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 6/21/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class Contact: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var day = Date()
    var parentRelationship = LinkingObjects(fromType: Relationship.self, property: "contacts")
    
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}
