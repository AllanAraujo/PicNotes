//
//  DetailedNotesViewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/31/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Hero
import RealmSwift
import Motion

class DetailedNotesViewController: UIViewController {
    
    var notesOpen = false
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }

    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    var picNote: PicNote? {
        didSet {
            imageView.hero.id = picNote?.filename
            notesField.text = picNote?.text
        }
    }
    
    lazy var notesField: UITextView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let tv = UITextView()
        tv.layer.cornerRadius = 8
        tv.font = UIFont.boldSystemFont(ofSize: 12)
        tv.backgroundColor = .white
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.hero.isEnabled = true
        
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(notesField)
        notesField.translatesAutoresizingMaskIntoConstraints = false
        notesField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        notesField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:))))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gr:))))
    }
    
    @objc func handlePan(gr: UIPanGestureRecognizer) {
        let translation = gr.translation(in: view)
        let progress = translation.y / 2 / view.bounds.height
        
        switch gr.state {
        case .began:
            dismiss(animated: true, completion: nil)
        case .changed:
            Hero.shared.update(progress)
            
            let currentPos = CGPoint(x: translation.x + imageView.center.x, y: translation.y + imageView.center.y)
            Hero.shared.apply(modifiers: [.position(currentPos)], to: imageView)
        default:
            if progress + gr.velocity(in: nil).y / view.bounds.height > 0.2 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
    
    @objc func handleTap(gr: UITapGestureRecognizer) {
        toggleNotesView()
    }
    
    //MARK: Handlers
    fileprivate func toggleNotesView(){
        if !notesOpen {
            let size = CGSize(width: 300, height: 450)
            notesField.animate(.size(size))
        } else if notesOpen {
            notesField.resignFirstResponder()
            let size = CGSize(width: 0, height: 0)
            
            let realm = try! Realm()
            
            try! realm.write {
                picNote?.text = notesField.text
            }
            
            notesField.animate(.size(size))
        }
        notesOpen = !notesOpen
    }
    
    
    
}
