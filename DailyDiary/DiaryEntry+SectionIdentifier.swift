//
//  DiaryEntry+SectionIdentifier.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/30/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension DiaryEntry {
    
    var sectionIdentifier: String {
        let returnDate = (createDate as Date).prettyDateStringYYYYMM
        
        return returnDate
    }
    
    static func prettySectionIdentifier(sectionIdentifier: String) -> String {
    
        guard sectionIdentifier.characters.count == 6 else { return "" }
        
        var components = DateComponents()
        
        let index = sectionIdentifier.index(sectionIdentifier.startIndex, offsetBy: 4)
        
        components.year = Int(sectionIdentifier.substring(to: index))
        components.month = Int(sectionIdentifier.substring(from: index))
        
        let calendar = Calendar.current
        
        let reconstructedDate = calendar.date(from: components)!
        
        let formatter = DateFormatter()
        
        // get pretty month
        formatter.dateFormat = "MMMM"
        let prettyMonth = formatter.string(from: reconstructedDate)
        
        // get year
        formatter.dateFormat = "YYYY"
        let year = formatter.string(from: reconstructedDate)
        
        return prettyMonth + " " + year
    }
}
