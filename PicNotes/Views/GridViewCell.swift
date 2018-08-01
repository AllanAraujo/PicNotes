//
//  GridViewCell.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/31/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import SDWebImage
import Hero


class GridViewCell: UICollectionViewCell {
    
    var picNote: PicNote? {
        didSet {
            guard let filepath = picNote?.pictureFilePath else {
                print("could not locate filepath for picnote")
                return
            }
            imageView.sd_setImage(with: URL(string: filepath), placeholderImage: UIImage(named: "placeholder.png"))
            imageView.hero.id = picNote?.filename
        }
    }
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
