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
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var notesOpen = false
    let audioCaptureService = AudioCaptureService()
    
    var previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "save-icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.isEnabled = true
        return button
    }()
    
    lazy var notesField: UITextView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let tv = UITextView()
        tv.layer.cornerRadius = 8
        tv.font = UIFont.boldSystemFont(ofSize: 14)
        tv.backgroundColor = .white
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
    
    let typeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleType), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "write").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hero.isEnabled = true
        
        navigationController?.isNavigationBarHidden = true
        
        setupLayout()
        
    }
    
    fileprivate func setupLayout() {
        
        view.addSubview(previewImageView)
        previewImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        view.addSubview(saveButton)
        saveButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 12, width: 30, height: 30)
        
        view.addSubview(typeButton)
        typeButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 45, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 30, height: 30)
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 45, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
        
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
        
        //If user has notes, prompt to go back.
        if notesField.text.count > 0 {
            let alertController = UIAlertController(title: "Are you sure?", message: "You will delete all of your notes for this picture if you say yes.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
                print("perform cancel")
            }))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
            
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleSave() {
        
        startActivityIndicator()
        
        saveButton.isEnabled = false
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
                picNote.date = Date()
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(picNote)
                }
                
                self.stopActivityIndicator()
                self.displaySaveComplatedLabel()

            })
        }
    }
    
    fileprivate func startActivityIndicator(){
        DispatchQueue.main.async {
            // Add it to the view where you want it to appear
            self.view.addSubview(self.activityIndicator)
            
            // Set up its size (the super view bounds usually)
            self.activityIndicator.frame = self.view.bounds
            // Start the loading animation
            self.activityIndicator.startAnimating()
        }
    }
    
    fileprivate func stopActivityIndicator(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    fileprivate func displaySaveComplatedLabel() {
        DispatchQueue.main.async {
            let savedLabel = UILabel()
            savedLabel.text = "Saved Successfully"
            savedLabel.textColor = .white
            savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
            savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
            savedLabel.numberOfLines = 0
            savedLabel.textAlignment = .center
            savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
            savedLabel.center = self.view.center
            self.view.addSubview(savedLabel)
            
            savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: { (complated) in
                //Complated
                UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    savedLabel.alpha = 0
                }, completion: { (_) in
                    savedLabel.removeFromSuperview()
                    self.saveButton.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleNotesView()
    }


    
}
