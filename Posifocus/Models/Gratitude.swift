//
//  Gratitudes.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class Gratitude: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var day = Date()
    @objc dynamic var category: String = ""
    @objc dynamic var rating: Int = 0
    
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}
