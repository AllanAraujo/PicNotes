//
//  Message.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/26/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import Foundation
import RealmSwift

class PicNote: Object {
    @objc dynamic var text =  ""
    @objc dynamic var pictureFilePath = ""
    @objc dynamic var date = Date()
}
