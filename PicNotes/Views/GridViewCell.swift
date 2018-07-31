//
//  GridViewCell.swift
//  PicNotes
//
//  Created by Allan Araujo on 7/31/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit

class GridViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        self.layer.cornerRadius = 16
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
