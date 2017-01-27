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

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem,
            let _ = locationLabel {
            
            if let date = detail.createDate as? Date {
                
                headingLabel.text = date.description
            }

            thoughtsTextField.text = detail.diaryEntryText
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    //    self.configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: DiaryEntry? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    @IBAction func onAddLocation() {
        print("Add location....")
    }

    @IBAction func onTappedPhoto() {
        print("Tapped photo....")
    }
    
    @IBAction func onMoodButton(_ sender: UIButton) {
        print("Mood button \(sender.tag) tapped...")
    }
}

