//
//  ViewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/16/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController : UIViewController, AVCapturePhotoCaptureDelegate {
    
    
    var captureSession = AVCaptureSession()
    var backCamera : AVCaptureDevice?
    var frontCamera : AVCaptureDevice?
    var currentDevice : AVCaptureDevice?
    var captureDeviceInput: AVCaptureDeviceInput?
    var captureDeviceInputBack:AVCaptureDeviceInput?
    var captureDeviceInputFront:AVCaptureDeviceInput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var output = AVCapturePhotoOutput()
    
    var cameraFacingback: Bool = true
    var ImageCaptured: UIImage!
    var cameraState:Bool = true
    var flashOn:Bool = false
    
    let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePressed), for: .touchUpInside)
        return button
    }()
    
    let flipCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "Camera flip-2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleFlipCamera), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        //Handle camera setup in this order.
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
        //Now handle view setup
        setupView()
        
        
    }
    
    // MARK: Setting up view/buttons on screen
    fileprivate func setupView() {
        view.addSubview(captureButton)
        captureButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 75, paddingRight: 0, width:100, height: 100)
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(flipCameraButton)
        flipCameraButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 45, paddingLeft: 0, paddingBottom: 0, paddingRight: 30, width: 30, height: 30)
    
    }
    
    // MARK: Camera Setup
    fileprivate func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    
    //The method to load camera.
    fileprivate func setupDevice() {
        //captureSession.startRunning()
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentDevice = backCamera
        
    }
    
    fileprivate func setupInputOutput() {
        do {
            
            guard let backCamera = backCamera else {
                print("could not unwrap back camera")
                return
            }
            captureDeviceInputBack = try AVCaptureDeviceInput(device: backCamera)
            
            guard let frontCamera = frontCamera else {
                print("could not unwrap front camera")
                return
            }
            captureDeviceInputFront = try AVCaptureDeviceInput(device: frontCamera)
            captureSession.addInput(captureDeviceInputBack!)
            output.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(output)
        } catch {
            print("Could not setup input/output for device")
            return
        }
    }
    
    fileprivate func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    fileprivate func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    // MARK: Button Handlers
    @objc func handleCapturePressed() {
        print("capturing photo")
        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else {
            print("unable to get first preview format type")
            return
        }
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("failed to conved pixel buffer")
            return
        }
        let previewImage = UIImage(data: imageData)
        
        let containerView = PreviewController()
        containerView.previewImageView.image = previewImage
        
        let previewVC = PreviewController()
        previewVC.previewImageView.image = previewImage
        let navController = UINavigationController(rootViewController: previewVC)
        self.present(navController, animated: true, completion: nil)
        
        print("Finishing processing photo sample buffer...")
    }
    
    @objc func handleFlipCamera(){
        
        cameraFacingback = !cameraFacingback
        if cameraFacingback {
            displayBackCamera()
            
        } else {
            displayFrontCamera()
        }
    }
    
    func displayBackCamera(){
        if captureSession.canAddInput(captureDeviceInputBack!) {
            captureSession.addInput(captureDeviceInputBack!)
        } else {
            captureSession.removeInput(captureDeviceInputFront!)
            if captureSession.canAddInput(captureDeviceInputBack!) {
                captureSession.addInput(captureDeviceInputBack!)
            }
        }
        
    }
    
    func displayFrontCamera(){
        if captureSession.canAddInput(captureDeviceInputFront!) {
            captureSession.addInput(captureDeviceInputFront!)
        } else {
            captureSession.removeInput(captureDeviceInputBack!)
            if captureSession.canAddInput(captureDeviceInputFront!) {
                captureSession.addInput(captureDeviceInputFront!)
            }
        }
    }
    
    /**
     The method to realise camera focusing.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchpoint = touches.first
        //        var screenSize = previewView.bounds.size
        //        let location = touchpoint?.location(in: self.view)
        let x = (touchpoint?.location(in: self.view).x)! / self.view.bounds.width
        let y = (touchpoint?.location(in: self.view).y)! / self.view.bounds.height
        
        //        var locationX = location?.x
        //        var locationY = location?.y
        
        focusOnPoint(x: x, y: y)
    }
    
    /**
     The algorithm to reasise autofocus .
     */
    func focusOnPoint(x: CGFloat, y:CGFloat){
        
        guard var currentDevice = self.currentDevice else {return}
        guard let backCamera = self.backCamera else {return}
        guard let frontCamera = self.frontCamera else {return}
        
        let focusPoint = CGPoint(x: x, y: y)
        if cameraFacingback {
            currentDevice = backCamera
        }
        else {
            currentDevice = frontCamera
        }
        do {
            try currentDevice.lockForConfiguration()
        }catch {
            
        }
        
        if currentDevice.isFocusPointOfInterestSupported{
            
            currentDevice.focusPointOfInterest = focusPoint
        }
        if currentDevice.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus)
        {
            currentDevice.focusMode = AVCaptureDevice.FocusMode.autoFocus
        }
        if currentDevice.isExposurePointOfInterestSupported
        {
            currentDevice.exposurePointOfInterest = focusPoint
        }
        if currentDevice.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose) {
            currentDevice.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
        }
        currentDevice.unlockForConfiguration()
        
    }
    
}

