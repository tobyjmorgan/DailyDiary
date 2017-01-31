//
//  DiaryViewController.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/31/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import CoreData

class DiaryViewController: UIViewController {
    
    @IBOutlet var seachBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var detailViewController: DetailViewController? = nil
    
    let dataController = CoreDataController.sharedInstance

    var _fetchedResultsController: NSFetchedResultsController<DiaryEntry>? = nil
    
    lazy var locationManager: LocationManager = {
        return LocationManager(alertPresentingViewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // change view controller title to current date
        self.title = Date().prettyDateStringMMMM_NTH_YYYY
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.onCoreDataError(notification:)), name: CoreDataError.ErrorNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        tableView.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                // change view controller title to current date
                controller.title = Date().prettyDateStringMMMM_NTH_YYYY
            }
        }
    }
}




// MARK: Helper methods
extension DiaryViewController {

    func insertNewObject(_ sender: Any) {
        
        let newDiaryEntry = DiaryEntry(context: dataController.managedObjectContext)
        
        newDiaryEntry.createDate = NSDate()
        newDiaryEntry.diaryEntryText = "What happened today?"
        
        dataController.saveContext()
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        performSegue(withIdentifier: "showDetail", sender: self)
    }

    func configureCell(_ cell: DiaryCell, withEntry entry: DiaryEntry) {
    
        cell.headingLabel!.text = (entry.createDate as Date).prettyDateStringEEEE_NTH_MMMM
        cell.thoughtsLabel!.text = entry.diaryEntryText
        cell.moodImageView.image = entry.imageForMood
        
        if let photo = entry.photos?.lastObject as? Photo, let image = UIImage(data: photo.image as Data) {
            cell.mainImageView.image = image
        }
        
        if let location = entry.location {
            
            cell.isLocationInfoShowing = true
            
            locationManager.getPlacement(latitude: location.latitude, longitude: location.longitude) { (placeName) in
                
                cell.locationTextLabel.text = placeName
            }
        }
    }

}



// MARK: - Table View
extension DiaryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell", for: indexPath) as! DiaryCell
        
        cell.resetCell()
        
        let entry = self.fetchedResultsController.object(at: indexPath)
        
        self.configureCell(cell, withEntry: entry)
        
        // ensure the cell's layout is updated
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sections = fetchedResultsController.sections {
            
            let currentSection = sections[section]
            let prettySectionName = DiaryEntry.prettySectionIdentifier(sectionIdentifier: currentSection.name)
            
            return prettySectionName
        }
        
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            dataController.saveContext()
        }
    }
    
}



// MARK: - Fetched results controller
extension DiaryViewController: NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<DiaryEntry> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<DiaryEntry> = DiaryEntry.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.managedObjectContext, sectionNameKeyPath: "sectionIdentifier", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
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
            self.configureCell(cell, withEntry: anObject as! DiaryEntry)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     self.tableView.reloadData()
     }
     */
    
    func changePredicate(searchString: String) {
        
    }
}

extension DiaryViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            
            
        }
    }
}






