//
//  ManagedObjectTests.swift
//  DailyDiary
//
//  Created by redBred LLC on 2/2/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import XCTest
import CoreData

@testable import DailyDiary

class ManagedObjectTests: XCTestCase {

    func getNewInMemoryPersistentContainer() -> NSPersistentContainer {

        let container = NSPersistentContainer(name: "DailyDiary")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        description.configuration = "Default"
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            XCTAssertNotNil(storeDescription, "Failed to create persistent container")
            XCTAssertNil(error, "Failed to create persistent container")
        })
        
        return container
    }
    
    var container: NSPersistentContainer?
    var managedObjectContext: NSManagedObjectContext?

    override func setUp() {
        super.setUp()
        
        container = getNewInMemoryPersistentContainer()
        managedObjectContext = container!.viewContext
        
        XCTAssertNotNil(managedObjectContext, "Failed to create managed object context for testing")
    }
    
    override func tearDown() {
        managedObjectContext = nil
        container = nil
        
        super.tearDown()
    }

    func testInsertDiaryEntryMissingEntryText() {
        
        let diaryEntryEntityDescription = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedObjectContext!)!
        let diaryEntry = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext!)
        
        diaryEntry.createDate = Date() as NSDate
        diaryEntry.moodInteger = 0
        
        do {
            try managedObjectContext!.save()
            XCTAssert(false, "Should not have saved DiaryEntry with no entry text")
        } catch {
            print("Correctly caught DiaryEntry with no entry text")
        }
    }

    func testInsertDiaryEntryMissingCreationDate() {
        
        let diaryEntryEntityDescription = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedObjectContext!)!
        let diaryEntry = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        
        diaryEntry.diaryEntryText = "Some text"
        diaryEntry.moodInteger = 0
        
        do {
            try managedObjectContext!.save()
            XCTAssert(false, "Should not have saved DiaryEntry with no creation date")
        } catch {
            print("Correctly caught DiaryEntry with no creation date")
        }
    }

    func testInsertDiaryEntryMissingMoodInteger() {
        
        let diaryEntryEntityDescription = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedObjectContext!)!
        let diaryEntry = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        
        diaryEntry.diaryEntryText = "Some text"
        diaryEntry.createDate = Date() as NSDate
        
        do {
            try managedObjectContext!.save()
            XCTAssert(diaryEntry.moodInteger == 0, "Should have defaulted moodInteger to 0")
        } catch let error {
            XCTAssert(false, "Should not have failed to insert DiaryEntry, just because moodInteger was not set: \(error)")
        }
    }
    
    func testInsertBasicDiaryEntry() {
        
        let diaryEntryEntityDescription = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedObjectContext!)!
        let diaryEntry = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        
        diaryEntry.diaryEntryText = "Some text"
        diaryEntry.createDate = Date() as NSDate
        diaryEntry.moodInteger = 2
        
        do {
            try managedObjectContext!.save()
            print("Correctly saved basic DiaryEntry object")
        } catch let error {
            XCTAssert(false, "Failed to save basic DiaryEntry object \(error)")
        }
    }
    
    func testInsertBasicPhoto() {

        let diaryEntryEntityDescription = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedObjectContext!)!
        let diaryEntry = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        
        diaryEntry.diaryEntryText = "Some text"
        diaryEntry.createDate = Date() as NSDate
        diaryEntry.moodInteger = 2
        
        do {
            try managedObjectContext!.save()
            print("Correctly saved basic DiaryEntry object")
        } catch {
            XCTAssert(false, "Failed to save basic DiaryEntry object")
        }
        
        let photoEntityDescription = NSEntityDescription.entity(forEntityName: "Photo", in: managedObjectContext!)!
        let photo1 = Photo(entity: photoEntityDescription, insertInto: managedObjectContext)
        
        photo1.diaryEntry = diaryEntry
        photo1.image = UIImagePNGRepresentation(#imageLiteral(resourceName: "icn_noimage"))! as NSData
        
        do {
            try managedObjectContext!.save()
            print("Correctly saved basic Photo object as child of DiaryEntry object")
        } catch {
            XCTAssert(false, "Failed to save basic Photo object as child of DiaryEntry object")
        }
        
        XCTAssertNotNil(diaryEntry.photos?.firstObject, "Failed to save Photo object for DiaryEntry")
        
        let photo2 = Photo(entity: photoEntityDescription, insertInto: managedObjectContext)
        photo2.diaryEntry = diaryEntry
        photo2.image = UIImagePNGRepresentation(#imageLiteral(resourceName: "icn_happy"))! as NSData
        
        do {
            try managedObjectContext!.save()
            print("Correctly saved second basic Photo object as child of DiaryEntry object")
        } catch {
            XCTAssert(false, "Failed to save second basic Photo object as child of DiaryEntry object")
        }
        
        XCTAssert(diaryEntry.photos?.count == 2, "Expected two photo objects")
    }

    func testInsertBasicLocation() {
        
        let diaryEntryEntityDescription = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedObjectContext!)!
        let diaryEntry = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        
        diaryEntry.diaryEntryText = "Some text"
        diaryEntry.createDate = Date() as NSDate
        diaryEntry.moodInteger = 2
        
        do {
            try managedObjectContext!.save()
            print("Correctly saved basic DiaryEntry object")
        } catch {
            XCTAssert(true, "Failed to save basic DiaryEntry object")
        }
        
        let locationEntityDescription = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectContext!)!
        let location = Location(entity: locationEntityDescription, insertInto: managedObjectContext)
        location.latitude = 52.4153
        location.longitude = 4.0829
        
        diaryEntry.location = location
        
        do {
            try managedObjectContext!.save()
            print("Correctly saved basic Location object as child of DiaryEntry object")
        } catch {
            XCTAssert(false, "Failed to save basic Location object as child of DiaryEntry object")
        }
        
        XCTAssertNotNil(diaryEntry.location, "Failed to save Location object for DiaryEntry")
    }
}
