//
//  PreviewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/17/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Speech
import Motion
import Firebase
import RealmSwift


class PreviewController: UIViewController {
    
    
    var notesOpen = false
    let audioCaptureService = AudioCaptureService()
    
    var previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "save-picnote").withRenderingMode(.alwaysOriginal), for: .normal)
        button.isEnabled = true
        return button
    }()
    
    lazy var notesField: UITextView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let tv = UITextView()
        tv.layer.cornerRadius = 8
        tv.font = UIFont.boldSystemFont(ofSize: 12)
        tv.backgroundColor = .white
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
    
    let typeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleType), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "text").withRenderingMode(.alwaysOriginal), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        
        setupLayout()
        
    }
    
    fileprivate func setupLayout() {
        
        view.addSubview(previewImageView)
        previewImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        view.addSubview(saveButton)
        saveButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 24, width: 64, height: 64)
        
        view.addSubview(typeButton)
        typeButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 64, height: 64)
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 64, height: 64)
        
        view.addSubview(notesField)
        notesField.translatesAutoresizingMaskIntoConstraints = false
        notesField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        notesField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    //MARK: Handlers
    fileprivate func toggleNotesView(){
        if !notesOpen {
            let size = CGSize(width: 300, height: 450)
            notesField.animate(.size(size))
        } else if notesOpen {
            notesField.resignFirstResponder()
            let size = CGSize(width: 0, height: 0)
            notesField.animate(.size(size))
        }
        notesOpen = !notesOpen
    }
    
    fileprivate func openNotes() {
        if !notesOpen {
            let size = CGSize(width: 300, height: 450)
            notesField.animate(.size(size))
            notesOpen = true
        }
    }
    
    fileprivate func closeNotes() {
        if notesOpen {
            notesField.resignFirstResponder()
            let size = CGSize(width: 0, height: 0)
            notesField.animate(.size(size))
            notesOpen = false
        }
    }
    
    @objc func handleType() {
        toggleNotesView()
    }
    
    @objc func handleCancel() {
        //self.dismiss(animated: true, completion: nil
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    @objc func handleSave() {
        //1. Store image
        guard let image = previewImageView.image else {return}
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else {return}
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("pictures").child(filename).putData(uploadData, metadata: nil) { (meta, err) in
            if let err = err {
                print("Failed to upload post image: ", err)
                return
            }
            let storageRef = Storage.storage().reference().child("pictures").child(filename)
            
            storageRef.downloadURL(completion: { (url, err) in
                if let err = err {
                    print("could not get url for image: ", err)
                    return
                }
                guard let imageURL = url?.absoluteString else {
                    print("could not unwrap URL: ")
                    return
                    
                }
                
                let picNote = PicNote()
                picNote.filename = filename
                picNote.pictureFilePath = imageURL
                picNote.text = self.notesField.text
                picNote.date = Date(timeIntervalSince1970: 1)
                
                print("imageURL: \(imageURL)")
                print("text: \(self.notesField.text)")
                print("imageURL: \(picNote.date)")
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(picNote)
                }
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleNotesView()
    }


    
}
