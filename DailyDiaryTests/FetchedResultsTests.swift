//
//  FetchedResultsTests.swift
//  DailyDiary
//
//  Created by redBred LLC on 2/3/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import XCTest
import CoreData

@testable import DailyDiary

class FetchedResultsTests: XCTestCase {

    class MockUITableView: UITableView { }
    
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
    var frcManager: DiaryFetchedResultsManager?
    var tableView: MockUITableView?
    let configureCell: (UITableViewCell, DiaryEntry) -> Void = { (cell, entry) in
        print("configureCell")
    }
    
    override func setUp() {
        super.setUp()
        
        container = getNewInMemoryPersistentContainer()
        managedObjectContext = container!.viewContext
        
        XCTAssertNotNil(managedObjectContext, "Failed to create managed object context for testing")

        
        let diaryEntryEntityDescription = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedObjectContext!)!
        
        let diaryEntry1 = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        let diaryEntry2 = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        let diaryEntry3 = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        let diaryEntry4 = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)
        let diaryEntry5 = DiaryEntry(entity: diaryEntryEntityDescription, insertInto: managedObjectContext)

        diaryEntry1.diaryEntryText = "Test Entry 1: Apple"
        diaryEntry1.createDate = Date() as NSDate
        diaryEntry1.moodInteger = 1
        
        diaryEntry2.diaryEntryText = "Test Entry 2: Banana"
        diaryEntry2.createDate = Date() as NSDate
        diaryEntry2.moodInteger = 1

        diaryEntry3.diaryEntryText = "Test Entry 3: Cherry"
        diaryEntry3.createDate = Date() as NSDate
        diaryEntry3.moodInteger = 1
        
        diaryEntry4.diaryEntryText = "Test Entry 4: Date"
        diaryEntry4.createDate = Date() as NSDate
        diaryEntry4.moodInteger = 1
        
        diaryEntry5.diaryEntryText = "Test Entry 5: Eaten Apple"
        diaryEntry5.createDate = Date() as NSDate
        diaryEntry5.moodInteger = 1
        
        do {
            try managedObjectContext!.save()
            print("Successfully saved DiaryEntry objects")
        } catch let error {
            XCTAssert(false, "Failed to save DiaryEntry objects \(error)")
        }
        
        tableView = MockUITableView()
        frcManager = DiaryFetchedResultsManager(managedObjectContext: managedObjectContext!, tableView: tableView!, onUpdateCell: configureCell)
    }
    
    override func tearDown() {
        tableView = nil
        frcManager = nil
        managedObjectContext = nil
        container = nil
        
        super.tearDown()
    }
    
    func testAllDiaryAllEntriesArePresent() {
        
        // force a call to build and execute the fetched results controller
        let frc = frcManager!.fetchedResultsController
        
        let sections = frc.sections!.count
        XCTAssert(sections == 1, "Should only be one section in table view")
        
        let sectionInfo = frc.sections![0]
        let rows = sectionInfo.numberOfObjects
        XCTAssert(rows == 5, "Should be 5 rows in section: \(rows) rows")
    }
    
    func testFetchSearchStringForApples() {

        frcManager!.searchString = "apple"
        
        // force a call to build and execute the fetched results controller
        let frc = frcManager!.fetchedResultsController
        
        let sections = frc.sections!.count
        XCTAssert(sections == 1, "Should only be one section in table view")
        
        let sectionInfo = frc.sections![0]
        let rows = sectionInfo.numberOfObjects
        XCTAssert(rows == 2, "Should be 2 rows in section which match search string 'apple': \(rows) rows")
    }

    func testFetchSearchStringForBanana() {
        
        frcManager!.searchString = "banana"
        
        // force a call to build and execute the fetched results controller
        let frc = frcManager!.fetchedResultsController
        
        let sections = frc.sections!.count
        XCTAssert(sections == 1, "Should only be one section in table view")
        
        let sectionInfo = frc.sections![0]
        let rows = sectionInfo.numberOfObjects
        XCTAssert(rows == 1, "Should be 1 row in section which matches search string 'apple': \(rows) rows")
        
    }
}
