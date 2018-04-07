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
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
    var parentProject = LinkingObjects(fromType: Project.self, property: "tasks")
}
