//
//  Location+CoreDataProperties.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/27/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var diaryEntry: DiaryEntry

}
