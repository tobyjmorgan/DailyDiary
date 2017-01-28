//
//  DetailViewController.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/26/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {


    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var photoImageContainer: UIView!
    @IBOutlet var moodImageView: UIImageView!
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var thoughtsTextField: UITextView!
    @IBOutlet var wordCountLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!

    var detailItem: DiaryEntry? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        // unwrap the detail item
        // then unwrap an outlet to see if they are ready for use, if not skip
        if let detail = self.detailItem,
            let _ = locationLabel {
            
            headingLabel.text = (detail.createDate as Date).prettyDateStringEEEE_NTH_MMMM
            thoughtsTextField.text = detail.diaryEntryText
            moodImageView.image = detail.imageForMood
            
            refreshCharacterCount()
        }
    }
    
    func applyViewValuesToManagedObject() {
        if let detail = self.detailItem {
            
            if let newText = thoughtsTextField.text {
                
                detail.diaryEntryText =  newText
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // for handling the character count
        thoughtsTextField.delegate = self
        
        // add save button to navigation bar
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanges))
        self.navigationItem.rightBarButtonItem = saveButton
        
        // change view controller title to current date
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

    func saveChanges() {
        applyViewValuesToManagedObject()
        CoreDataController.sharedInstance.saveContext()
    }
    
    func refreshCharacterCount() {
        wordCountLabel.text = "\(thoughtsTextField.text.characters.count)/200"
    }
    
    @IBAction func onAddLocation() {
        print("Add location....")
    }

    @IBAction func onTappedPhoto() {
        print("Tapped photo....")
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

extension DetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == thoughtsTextField {
            refreshCharacterCount()
        }
    }
}
