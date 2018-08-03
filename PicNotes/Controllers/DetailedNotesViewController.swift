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
    
    var picNote: PicNote? {
        didSet {
            imageView.hero.id = picNote?.filename
            notesField.text = picNote?.text
        }
    }

    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var notesField: UITextView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let tv = UITextView()
        tv.layer.cornerRadius = 8
        tv.font = UIFont.boldSystemFont(ofSize: 18)
        tv.backgroundColor = .white
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
    

    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "trashcan").withRenderingMode(.alwaysOriginal), for: .normal)
        button.isEnabled = true
        return button
    }()
    
    let typeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleType), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "write").withRenderingMode(.alwaysOriginal), for: .normal)
        button.isEnabled = true
        return button
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
        
        view.addSubview(typeButton)
        typeButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 45, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 30, height: 30)
        
        view.addSubview(deleteButton)
        deleteButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 22, paddingRight: 12, width: 30, height: 30)
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
    
    @objc func handleType(){
        toggleNotesView()
    }
    
    @objc func handleDelete() {
        //Prompt if user is sure?
        let alertController = UIAlertController(title: "Are you sure?", message: "You want to delete this PicNote?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
            print("perform cancel")
        }))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            let realm = try! Realm()
            
            try! realm.write {
                realm.delete(self.picNote!)
            }
            self.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alertController, animated: true, completion: nil)
        
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
