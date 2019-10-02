//
//  Project.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class Project: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var completed: Bool = false
    var parentPriority = LinkingObjects(fromType: Priority.self, property: "projects")
    let tasks = List<Task>()
    
    @objc dynamic var isDeleted = false
    override class func primaryKey() -> String? {
        return "id"
    }
}
