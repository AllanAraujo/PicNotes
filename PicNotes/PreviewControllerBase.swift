//
//  PreviewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/16/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Hero
import Speech

class PreviewControllerBase: UIViewController, SFSpeechRecognizerDelegate{
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var isRecordingEnabled = false
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    private let microphoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "muted-white").withRenderingMode(.alwaysOriginal), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(recordButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.boldSystemFont(ofSize: 18)
        tv.text = ""
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSpeechRecognition()
        setupLayout()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func setupLayout() {
        view.addSubview(previewImageView)
        previewImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        view.addSubview(microphoneButton)
        microphoneButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 32, height: 32)
        
        view.addSubview(textView)
        textView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 12, paddingBottom: 50, paddingRight: 12, width: 0, height: 0)
    }
    
    fileprivate func setupSpeechRecognition() {
        
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            switch authStatus {  //5
            case .authorized:
                self.isRecordingEnabled = true
                
            case .denied:
                self.isRecordingEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                self.isRecordingEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                self.isRecordingEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.setImage(#imageLiteral(resourceName: "microphone-full-white").withRenderingMode(.alwaysOriginal), for: .normal)
                self.microphoneButton.isEnabled = self.isRecordingEnabled
            }
        }
    }
    
    @objc func handleCancel() {
        print("Cancel button pressed")
        //self.dismiss(animated: true, completion: nil
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("tapped")
    }

    // MARK: Recording Methods
    @objc fileprivate func recordButtonPressed() {
        if isRecordingEnabled {
            self.record()
        }
    }
    
    fileprivate func record() {
        if audioEngine.isRunning {
            audioEngine.stop()
            microphoneButton.setImage(#imageLiteral(resourceName: "microphone-full-white").withRenderingMode(.alwaysOriginal), for: .normal)
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
            print("stopped recording...")
        } else {
            startRecording()
            print("start recording...")
            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func startRecording() {
        
        microphoneButton.setImage(#imageLiteral(resourceName: "microphone-red").withRenderingMode(.alwaysOriginal), for: .normal)
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = ""
        
    }
    
    // MARK: Speech Recognizer Delegate Methods
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
            isRecordingEnabled = true
        } else {
            microphoneButton.isEnabled = false
            isRecordingEnabled = false
        }
    }

    
    
}
