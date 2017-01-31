//
//  DiaryCell.swift
//  DiaryApp
//
//  Created by redBred LLC on 1/20/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class DiaryCell: UITableViewCell {

    static let locationSpacerViewHeightWhenShowing: CGFloat = 10
    static let locationContainerViewHeightWhenShowing: CGFloat = 20
    
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var mainImageContainer: UIView!
    @IBOutlet var moodImageView: UIImageView!
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var thoughtsLabel: UILabel!
    @IBOutlet var locationTextLabel: UILabel!
    
    @IBOutlet var locationSpacerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var locationContainerViewHeightConstraint: NSLayoutConstraint!
    
    var isLocationInfoShowing: Bool = false {
        
        didSet {
            
            if isLocationInfoShowing {
                
                locationSpacerViewHeightConstraint.constant = DiaryCell.locationSpacerViewHeightWhenShowing
                locationContainerViewHeightConstraint.constant = DiaryCell.locationContainerViewHeightWhenShowing

            } else {
                
                locationSpacerViewHeightConstraint.constant = 0
                locationContainerViewHeightConstraint.constant = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        mainImageContainer.layer.cornerRadius = mainImageContainer.frame.size.width/2
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func resetCell() {        
        mainImageView.image = UIImage(named: "icn_noimage")
        moodImageView.image = UIImage()
        headingLabel.text = ""
        thoughtsLabel.text = ""
        isLocationInfoShowing = false
    }
}
