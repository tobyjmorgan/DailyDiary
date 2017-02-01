//
//  DiaryFetchedResultsManager.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/31/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DiaryFetchedResultsManager: NSObject, NSFetchedResultsControllerDelegate {
    
    // any search text to be used in the fetch request
    var searchString: String = "" {
        didSet {
            resetFetchedResultsController()
        }
    }
    
    // dependency injection
    let tableView: UITableView
    let managedObjectContext: NSManagedObjectContext
    let onUpdateCell: (UITableViewCell, DiaryEntry) -> Void
    
    init(managedObjectContext: NSManagedObjectContext, tableView: UITableView, onUpdateCell: @escaping (UITableViewCell, DiaryEntry) -> Void) {
        self.managedObjectContext = managedObjectContext
        self.tableView = tableView
        self.onUpdateCell = onUpdateCell
        
        super.init()
    }
    
    private var _fetchedResultsController: NSFetchedResultsController<DiaryEntry>? = nil
    
    func resetFetchedResultsController() {

        // reset fetchedResultsController
        _fetchedResultsController = nil
        
        // reload the table view
        tableView.reloadData()
    }
    
    var fetchedResultsController: NSFetchedResultsController<DiaryEntry> {
    
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let request: NSFetchRequest<DiaryEntry> = DiaryEntry.fetchRequest()
        let sectionNameKeyPath = "sectionIdentifier"
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]

        // Set the batch size to a suitable number.
        request.fetchBatchSize = 20
        
        
        if searchString.characters.count > 0 {
            
            let predicate = NSPredicate(format: "diaryEntryText contains[cd] %@", argumentArray: [searchString])
            request.predicate = predicate
            
        } else {
            
            request.predicate = nil
        }
        
        
        let frc: NSFetchedResultsController<DiaryEntry> = NSFetchedResultsController(fetchRequest: request,
                                                                                     managedObjectContext: managedObjectContext,
                                                                                     sectionNameKeyPath: sectionNameKeyPath,
                                                                                     cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            let nsError = error as NSError
            let message = "Failed to fetch data: \(nsError.localizedDescription)"
            print(message)
            
            let errorUserInfo = nsError.userInfo
            print(errorUserInfo)
            
            // post a notification for anyone interested in error messages for failed save requests
            let userInfo = [CoreDataError.ErrorKey : CoreDataError(message: message, fatal: false)]
            NotificationCenter.default.post(name: CoreDataError.ErrorNotification, object: self, userInfo: userInfo)
        }
        
        _fetchedResultsController = frc
        
        return _fetchedResultsController!
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! DiaryCell
            onUpdateCell(cell, anObject as! DiaryEntry)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
