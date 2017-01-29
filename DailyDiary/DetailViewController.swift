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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // for handling the character count
        thoughtsTextField.delegate = self
        
        // add save button to navigation bar
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanges))
        self.navigationItem.rightBarButtonItem = saveButton
        
        // change view controller title to current date
        self.title = Date().prettyDateStringMMMM_NTH_YYYY
        
        // round corners for image
        photoImageContainer.layer.cornerRadius = photoImageContainer.layer.frame.size.width / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    // MARK: Helper Methods
    
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
        wordCountLabel.text = "\(thoughtsTextField.text.characters.count)/200"
    }
}




// MARK: IBActions
extension DetailViewController {
    
    @IBAction func onAddLocation() {
        print("Add location....")
    }
    
    @IBAction func onTappedPhoto() {
        print("Tapped photo....")
        mediaPickerManager.presentImagePickerController(animated: true)
    }
    
    @IBAction func onMoodButton(_ sender: UIButton) {
        print("Mood button \(sender.tag) tapped...")
        
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
        
        if textView == thoughtsTextField {
            // thanks to Mykola - http://stackoverflow.com/questions/2492247/limit-number-of-characters-in-uitextview
            return textView.text.characters.count + (text.characters.count - range.length) <= 200
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == thoughtsTextField {
            refreshCharacterCount()
        }
    }
}



// MARK: MediaPickerManagerDelegate
extension DetailViewController {
    
    func mediaPickerManager(manager: MediaPickerManager, didFinishPickingImage image: UIImage) {
        
        guard let resizedImage = resizeImage(image: image, toWidth: 750),
              let diaryEntry = detailItem,
              let imageData = UIImagePNGRepresentation(resizedImage) else { return }
        
        // save new image to store
        let photo: Photo
        
        if let existingPhoto = diaryEntry.photos?.firstObject as? Photo {
            photo = existingPhoto
        } else {
            photo = Photo(entity: Photo.entity(), insertInto: dataController.managedObjectContext)
            photo.diaryEntry = diaryEntry
        }

        photo.image = imageData as NSData
        dataController.saveContext()
        
        configureView()
    }
    
    func resizeImage(image: UIImage, toWidth: CGFloat) -> UIImage? {

        let aspectRatio = image.size.height / image.size.width
        
        let newSize = CGSize(width: toWidth, height: toWidth*aspectRatio)
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: newRect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
