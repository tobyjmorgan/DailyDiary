//
//  DetailViewController.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/26/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, MediaPickerManagerDelegate {

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var photoImageContainer: UIView!
    @IBOutlet var moodImageView: UIImageView!
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var thoughtsTextField: UITextView!
    @IBOutlet var wordCountLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!

    let dataController = CoreDataController.sharedInstance
    
    lazy var locationManager: LocationManager = {
        return LocationManager(alertPresentingViewController: self)
    }()
    
    var detailItem: DiaryEntry? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    lazy var mediaPickerManager: MediaPickerManager = {
        let manager = MediaPickerManager(presentingViewController: self)
        manager.delegate = self
        return manager
    }()
    
    let placeHolderText = "What happened today?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // for handling the character count
        thoughtsTextField.delegate = self
        
        // add save button to navigation bar
// TJM - decided to remove this - better to save the entry on dismiss
//        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanges))
//        self.navigationItem.rightBarButtonItem = saveButton
        
        // round corners for image
        photoImageContainer.layer.cornerRadius = photoImageContainer.layer.frame.size.width / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.onCoreDataError(notification:)), name: CoreDataError.ErrorNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureView()
        
        determinePlaceholderTextForInactiveState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveChanges()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Photos" {

            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            if let controller = segue.destination as? PhotosViewController {
                
                controller.detailItem = detailItem
            }
        }
    }
}
    
    
// MARK: Helper Methods

extension DetailViewController {

    func configureView() {
        // Update the user interface for the detail item.
        
        // unwrap the detail item
        // then unwrap an outlet to see if they are ready for use, if not skip
        guard let detail = self.detailItem, let _ = locationLabel else { return }
        
        // change view controller title to the diary entry date
        self.title = (detail.createDate as Date).prettyDateStringMMMM_NTH_YYYY
        
        headingLabel.text = (detail.createDate as Date).prettyDateStringEEEE_NTH_MMMM
        thoughtsTextField.text = detail.diaryEntryText
        moodImageView.image = detail.imageForMood
        
        refreshCharacterCount()
        
        if let photo = detailItem?.photos?.lastObject as? Photo, let image = UIImage(data: photo.image as Data) {
            
            photoImageView.image = image
        }
        
        if let location = detailItem?.location {
           
            locationManager.getPlacement(latitude: location.latitude, longitude: location.longitude) { (placeName) in
                    
                self.locationLabel.text = placeName
            }
        }
    }
    
    func applyViewValuesToManagedObject() {
        if let detail = self.detailItem {
            
            if let newText = thoughtsTextField.text {
                
                detail.diaryEntryText =  newText
            }
        }
    }
    
    func saveChanges() {
        applyViewValuesToManagedObject()
        dataController.saveContext()
    }
    
    func refreshCharacterCount() {
        if thoughtsTextField.text == placeHolderText {
            
            wordCountLabel.text = "0/200"

        } else {
            
            wordCountLabel.text = "\(thoughtsTextField.text.characters.count)/200"
        }
    }
    
    func determinePlaceholderTextForInactiveState() {
        
        if thoughtsTextField.text == "" {
            
            thoughtsTextField.text = placeHolderText
            thoughtsTextField.textColor = UIColor.lightGray

        } else if thoughtsTextField.text == placeHolderText {
            
            thoughtsTextField.textColor = UIColor.lightGray
            
        } else {
            
            thoughtsTextField.textColor = UIColor.darkGray
        }
    }
    
    func determinePlaceholderTextForActiveState() {
        
        if thoughtsTextField.text == placeHolderText {
            thoughtsTextField.text = ""
        }

        thoughtsTextField.textColor = UIColor.darkGray
    }

}




// MARK: IBActions
extension DetailViewController {
    
    @IBAction func onAddLocation() {
        
        print("Add location....")
        
        locationManager.getLocation { (latitude, longitude) in
            
            print("Location: \(latitude), \(longitude)")
            
            if let diaryEntry = self.detailItem {
                
                let location: Location
            
                if let existingLocation = diaryEntry.location {
                    
                    location = existingLocation
                    
                } else {
                    
                    location = Location(entity: Location.entity(), insertInto: self.dataController.managedObjectContext)
                }
                
                location.diaryEntry = diaryEntry
                location.latitude = latitude
                location.longitude = longitude
                
                diaryEntry.location = location
                
                self.dataController.saveContext()

                DispatchQueue.main.async {
                    
                    self.configureView()
                }
            }
        }
    }
    
    @IBAction func onTappedPhoto() {
        print("Tapped photo....")
        //mediaPickerManager.presentImagePickerController(animated: true)
    }
    
    @IBAction func onMoodButton(_ sender: UIButton) {
        print("Mood button \(sender.tag) tapped...")
        
        // check the button tapped matches a valid Mood enumeration case
        if let newMood = Mood(rawValue: sender.tag) {
            detailItem?.mood = newMood
        } else {
            detailItem?.mood = nil
        }
        
        applyViewValuesToManagedObject()
        configureView()
    }
}




// MARK: UITextViewDelegate
extension DetailViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // limit length to 200 characters
        if textView == thoughtsTextField {
            // thanks to Mykola - http://stackoverflow.com/questions/2492247/limit-number-of-characters-in-uitextview
            return textView.text.characters.count + (text.characters.count - range.length) <= 200
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        determinePlaceholderTextForActiveState()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        determinePlaceholderTextForInactiveState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        // when text view changes, recalculate character count
        if textView == thoughtsTextField {
            refreshCharacterCount()
        }
    }
}



// MARK: MediaPickerManagerDelegate
extension DetailViewController {
    
    func mediaPickerManager(manager: MediaPickerManager, didFinishPickingImage image: UIImage) {
        
        // make sure we successfully resized the image, that we have a detail item to work with
        // and the resized image could be converted to data
        guard let resizedImage = MediaPickerManager.resizeImage(image: image, toWidth: 750),
              let diaryEntry = detailItem,
              let imageData = UIImagePNGRepresentation(resizedImage) else { return }
        
        // save new image to store
        let photo: Photo
        
        // update the existing Photo object (DB allows one-to-many, but GUI best fits 1:1)
        if let existingPhoto = diaryEntry.photos?.firstObject as? Photo {
            photo = existingPhoto
        } else {
            // create new Photo
            photo = Photo(entity: Photo.entity(), insertInto: dataController.managedObjectContext)
            diaryEntry.addToPhotos(photo)
            photo.diaryEntry = diaryEntry
        }

        // set the Photo's properties and save
        photo.image = imageData as NSData
        dataController.saveContext()
        
        // get back on the main queue
        DispatchQueue.main.async {
            
            // update the GUI
            self.configureView()
            
            // dismiss the picker
            self.dismiss(animated: true, completion: nil)
        }
    }
}
