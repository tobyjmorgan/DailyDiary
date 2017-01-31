//
//  PhotoCell.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/31/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet var photoContainerView: UIView!
    @IBOutlet var photo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoContainerView.layer.cornerRadius = photoContainerView.frame.size.width/2
    }
}
