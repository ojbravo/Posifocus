//
//  Tasks.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var completed: Bool = false
    @objc dynamic var today: Bool = false
    @objc dynamic var todayOrder: Int = 0
    var parentProject = LinkingObjects(fromType: Project.self, property: "tasks")
    
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}
