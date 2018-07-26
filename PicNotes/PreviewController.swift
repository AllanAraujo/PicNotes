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

class PreviewController: UIViewController {
    
    let audioCaptureService = AudioCaptureService()
    
    var notesOpen = false
    
    var previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    
    let microphoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleRecord), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "muted-white").withRenderingMode(.alwaysOriginal), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    lazy var textView: UITextView = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let tv = UITextView()
        tv.layer.cornerRadius = 8
        tv.font = UIFont.boldSystemFont(ofSize: 12)
        tv.backgroundColor = .white
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        audioCaptureService.enableSpeechRecognition()
        
        setupLayout()
        
    }
    
    fileprivate func setupLayout() {
        
        view.addSubview(previewImageView)
        previewImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(microphoneButton)
        microphoneButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 32, height: 32)
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        if audioCaptureService.recordingEnabled() {
            print("audio enabled...")
            microphoneButton.setImage(#imageLiteral(resourceName: "microphone-full-white").withRenderingMode(.alwaysOriginal), for: .normal)
            microphoneButton.isEnabled = true
        }
    }
    
    
    fileprivate func openNotes(){
        if !notesOpen {
            let size = CGSize(width: 300, height: 450)
            textView.animate(.size(size))
        } else if notesOpen {
            textView.resignFirstResponder()
            let size = CGSize(width: 0, height: 0)
            textView.animate(.size(size))
        }
        notesOpen = !notesOpen
    }
    
    @objc func handleRecord() {
        print("record button pressed")
        
    }
    
    @objc func handleCancel() {
        print("Cancel button pressed")
        //self.dismiss(animated: true, completion: nil
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        openNotes()
    }
    
}
