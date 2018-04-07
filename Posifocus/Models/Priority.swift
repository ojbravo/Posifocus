//
//  Priorities.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class Priority: Object {
    @objc dynamic var name: String = ""
    let projects = List<Project>()
    
}
