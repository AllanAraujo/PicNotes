//
//  AudioCaptureService.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/23/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Speech

protocol AudioCaptureServiceDelegate {
    func record()
    func checkIsEnabled()
}

class AudioCaptureService: NSObject, SFSpeechRecognizerDelegate {
    
    var delegate: AudioCaptureServiceDelegate?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var isRecordingEnabled = false
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func enableSpeechRecognition(){
        
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
        }
    }
    
    func recordingEnabled() -> Bool{
        return self.isRecordingEnabled
    }
    
    // MARK: Recording Methods
    @objc func recordButtonPressed() {
        if isRecordingEnabled {
            self.record()
        }
    }
    
    fileprivate func record() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            print("stopped recording...")
        } else {
            startRecording()
            print("start recording...")
        }
    }
    
    func startRecording() {
        
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
                
                //self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //self.microphoneButton.isEnabled = true
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
        
        //textView.text = ""
        
    }
    
    // MARK: Speech Recognizer Delegate Methods
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            isRecordingEnabled = true
        } else {
            isRecordingEnabled = false
        }
    }
    
}
