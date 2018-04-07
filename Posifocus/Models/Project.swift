//
//  Projects.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class Project: Object {
    @objc dynamic var name: String = ""
    var parentPriority = LinkingObjects(fromType: Priority.self, property: "projects")
    let tasks = List<Task>()
}
