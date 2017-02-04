//
//  DiaryCell.swift
//  DiaryApp
//
//  Created by redBred LLC on 1/20/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import CoreLocation

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
    
    let geocoder = CLGeocoder()
    
    func setLocation(latitude: Double, longitude: Double) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            // make sure this happens on the main queue
            // just in case there is any GUI code inside the completion handler
            DispatchQueue.main.async {
                guard let placemark = placemarks?.first,
                    let _ = placemark.name,
                    let city = placemark.locality,
                    let area = placemark.administrativeArea else {
                        
                        self.locationTextLabel.text = "Unknown location"
                        return
                }
                
                self.locationTextLabel.text = "\(city), \(area)"
            }
            
        }
    }
    
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
