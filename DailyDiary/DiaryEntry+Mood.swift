//
//  DiaryEntry+Mood.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/27/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import UIKit

enum Mood: Int {
    case bad = 1
    case average
    case good
}

extension DiaryEntry {
    
    var mood: Mood? {
        get {
            if let newMood = Mood(rawValue: Int(moodInteger)) {
                return newMood
            }
            
            return nil
        }
        set {
            if let newValue = newValue {
                self.moodInteger = Int16(newValue.rawValue)
            } else {
                self.moodInteger = 0
            }
        }
    }
    
    var imageForMood: UIImage {
        
        guard let mood = mood else { return UIImage() }

        switch mood {
        case .bad:
            return #imageLiteral(resourceName: "icn_bad")
        case .average:
            return #imageLiteral(resourceName: "icn_average")
        case .good:
            return #imageLiteral(resourceName: "icn_happy")
        }
    }

}
