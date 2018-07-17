//
//  NotesViewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/17/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Hero

class PreviewNotesController: PreviewControllerBase {
    
    let contentView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 8
        view.addSubview(contentView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = CGRect(x: (view.bounds.width - 250) / 2, y: 140, width: 250, height: view.bounds.height - 280)
    }
    
    
}
