//
//  PriorityList.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/12/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import Foundation
import RealmSwift

class PriorityList: Object {
    @objc dynamic var name: String = ""
    let priorities = List<Priority>()
}
