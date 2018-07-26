//
//  PreviewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/17/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Speech
import Hero

class PreviewController: UIViewController {
    
    let audioCaptureService = AudioCaptureService()
    let notesId = "notedId"
    var notes = ""
    
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
    
    private let notesButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleOpenNotes), for: .touchUpInside)
        return button
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
        
        view.addSubview(notesButton)
        notesButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 12, width: 50, height: 50)
        
        microphoneButton.addTarget(self, action: #selector(handleRecord), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        if audioCaptureService.recordingEnabled() {
            print("audio enabled...")
            microphoneButton.setImage(#imageLiteral(resourceName: "microphone-full-white").withRenderingMode(.alwaysOriginal), for: .normal)
            microphoneButton.isEnabled = true
        }
    }
    
    
    @objc func handleOpenNotes(){
        if audioCaptureService.recordingEnabled() {
            //Open notes view and start recording
        }
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
        //textView.resignFirstResponder()
    }
    
}
