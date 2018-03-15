//
//  PictureCollectionCell.swift
//  MinderaGallery
//
//  Created by Quentin Beaudouin on 14/03/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

class PictureCollectionCell: UICollectionViewCell {
    
    static let nameAndId = "PictureCollectionCell"
    
    @IBOutlet weak var picture: UIImageView!
    
    override var isHighlighted: Bool {
        
        didSet { UIView.animate(withDuration: 0.15) { self.alpha = self.isHighlighted ? 0.8 : 1 } }
        
    }

}
