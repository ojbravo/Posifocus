//
//  Relationship.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 6/21/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class Relationship: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var birthday: Date = Date()
    @objc dynamic var lastContact: Date = Date()
    @objc dynamic var notes: String = ""
    let contacts = List<Contact>()
}
