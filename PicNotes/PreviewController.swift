//
//  PreviewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/17/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit

class PreviewController: PreviewControllerBase {
    
    private let notesButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleOpenNotes), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(notesButton)
        notesButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 12, width: 50, height: 50)
        
        notesButton.hero.isEnabled = true
        notesButton.hero.id = "heroId"
    }
    
    @objc func handleOpenNotes(){
        let pnc = PreviewNotesController()
        pnc.previewImageView.image = self.previewImageView.image

        pnc.hero.isEnabled = true
        pnc.contentView.hero.id = "heroId"
        
        pnc.contentView.hero.modifiers = [.scale()]
        pnc.contentView.backgroundColor = .white
        
        pnc.hero.modalAnimationType = .auto
        present(pnc, animated: true, completion: nil)
    }
}
