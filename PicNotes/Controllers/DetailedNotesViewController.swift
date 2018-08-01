//
//  DetailedNotesViewController.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/31/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Hero

class DetailedNotesViewController: UIViewController {
    
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.hero.isEnabled = true
        
        view.addSubview(imageView)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(gr:))))
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
    
}
