//
//  DiaryViewController.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/31/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class DiaryViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var detailViewController: DetailViewController? = nil
    
    // our core data singleton
    let dataController = CoreDataController.sharedInstance
    
    // will handle fetching core data results
    lazy var fetchedResultsManager: DiaryFetchedResultsManager = {
        
        let manager = DiaryFetchedResultsManager(managedObjectContext: self.dataController.managedObjectContext, tableView: self.tableView, onUpdateCell: self.configureCell)
        
        return manager
    }()
    
    // will handle fetching location info
    lazy var locationManager: LocationManager = {
        return LocationManager(alertPresentingViewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        // change view controller title to current date
        self.title = Date().prettyDateStringMMMM_NTH_YYYY
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // dynamically sized table view rows
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // listen for errors
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.onDailyDiaryError(notification:)), name: DailyDiaryError.ErrorNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //        tableView.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed

        // unselect anything that was previously selected when returning to this screen
        // but only if not in split view mode (both sides showing)
        if self.splitViewController!.isCollapsed {
            
            if let selections = tableView.indexPathsForSelectedRows {
                
                for selection in selections {
                    tableView.deselectRow(at: selection, animated: true)
                }
            }
        }
        
        tableView.reloadData()

        displayWelcome()

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
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsManager.fetchedResultsController.object(at: indexPath)
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

    static let beenRunBeforeKey = "BeenRunBefore"

    func displayWelcome() {
        
        let defaults = UserDefaults.standard
        
        let beenRunBefore = defaults.bool(forKey: DiaryViewController.beenRunBeforeKey)
        
        if !beenRunBefore {
            
            let alert = UIAlertController(title: "Welcome", message: "To add a diary entry for today, just click the Add button in the top right. Enjoy!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Will do!", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            defaults.set(true, forKey: DiaryViewController.beenRunBeforeKey)
            defaults.synchronize()
        }
    }
    
    func insertNewObject(_ sender: Any) {

        // clear out any search text so the new row will appear
        searchBar.text = ""
        fetchedResultsManager.searchString = ""
        
        // create new row
        let newDiaryEntry = DiaryEntry(context: dataController.managedObjectContext)
        
        // set properties and save
        newDiaryEntry.createDate = NSDate()
        newDiaryEntry.diaryEntryText = "What happened today?"
        dataController.saveContext()
        
        // automatically go to detail view to edit details
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    // configure the cell to represent the information in the row
    func configureCell(_ cell: UITableViewCell, withEntry entry: DiaryEntry) {
        
        guard let diaryCell = cell as? DiaryCell else { return }
        
        diaryCell.headingLabel!.text = (entry.createDate as Date).prettyDateStringEEEE_NTH_MMMM
        diaryCell.thoughtsLabel!.text = entry.diaryEntryText
        diaryCell.moodImageView.image = entry.imageForMood
        
        if let photo = entry.photos?.lastObject as? Photo, let image = UIImage(data: photo.image as Data) {
            diaryCell.mainImageView.image = image
        }
        
        if let location = entry.location {

            diaryCell.isLocationInfoShowing = true
            diaryCell.setLocation(latitude: location.latitude, longitude: location.longitude)
        }
        
        diaryCell.layoutIfNeeded()
    }
}




// MARK: - Table View
extension DiaryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sections = fetchedResultsManager.fetchedResultsController.sections?.count ?? 0
        
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsManager.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell", for: indexPath) as! DiaryCell
        
        cell.resetCell()
        
        let entry = fetchedResultsManager.fetchedResultsController.object(at: indexPath)
        
        configureCell(cell, withEntry: entry)
        
        // ensure the cell's layout is updated
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sections = fetchedResultsManager.fetchedResultsController.sections {
            
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
            let context = fetchedResultsManager.fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsManager.fetchedResultsController.object(at: indexPath))
            
            dataController.saveContext()
        }
    }
    
}



// MARK: UISearchBarDelegate
extension DiaryViewController: UISearchBarDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.showsCancelButton = true
        
        fetchedResultsManager.searchString = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        fetchedResultsManager.searchString = ""

        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
}






