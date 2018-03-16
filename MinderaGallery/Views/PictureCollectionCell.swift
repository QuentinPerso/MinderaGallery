//
//  PictureCollectionCell.swift
//  MinderaGallery
//
//  Created by Quentin Beaudouin on 14/03/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

/* COMMENT:
 * I didn't put this class in the storyBoard so that it could be easily reused (althought I didn't need it in this project...)
 */

class PictureCollectionCell: UICollectionViewCell {
    
    static let nameAndId = "PictureCollectionCell"
    
    @IBOutlet weak var picture: UIImageView!
    
    override var isHighlighted: Bool {
        
        didSet { UIView.animate(withDuration: 0.15) { self.alpha = self.isHighlighted ? 0.8 : 1 } }
        
    }

}
