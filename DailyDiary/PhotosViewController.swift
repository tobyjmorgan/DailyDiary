//
//  PhotosViewController.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/31/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {

    var detailItem: DiaryEntry? {
        didSet {
            // Update the view.
            self.refreshView()
        }
    }
    
    let dataController = CoreDataController.sharedInstance
    
    lazy var mediaPickerManager: MediaPickerManager = {
        let manager = MediaPickerManager(presentingViewController: self)
        manager.delegate = self
        return manager
    }()

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var photoDisplayContainerView: UIView!
    @IBOutlet var photoDisplay: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        photoDisplayContainerView.isHidden = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}



// MARK: IBOutlets
extension PhotosViewController {
    
    @IBAction func onTapPhoto() {
        
        hidePhoto()
    }
}



// MARK: Helper methods
extension PhotosViewController {
    
    func addPhoto() {
        mediaPickerManager.presentImagePickerController(animated: true)
    }
    
    func refreshView() {
        // unwrap to see if the GUI has been put together yet
        if let collectionView = collectionView {
            collectionView.reloadData()
        }
    }
    
    func showPhoto() {
        
        photoDisplayContainerView.isHidden = false
        photoDisplayContainerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        photoDisplayContainerView.alpha = 0
        
        photoDisplayContainerView.setNeedsDisplay()
        
        UIView.animate(withDuration: 0.3,
                       animations: { () -> Void in
                        
                        self.photoDisplayContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.photoDisplayContainerView.alpha = 1.0
        })
    }
    
    func hidePhoto() {
        
        UIView.animate(withDuration: 0.3,
                       animations: { () -> Void in
                        
                        self.photoDisplayContainerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        self.photoDisplayContainerView.alpha = 0
        },
                       completion: { (finished) -> Void in
                        
                        self.photoDisplayContainerView.isHidden = true
        })
    }
}




// MARK: UICollectionViewDataSource
extension PhotosViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailItem?.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        // clear out previous image if any
        cell.photo.image = UIImage()
        
        if let photoObject = detailItem?.photos?[indexPath.item] as? Photo,
            let image = UIImage(data: photoObject.image as Data) {
            
            cell.photo.image = image
        }
        
        return cell
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let photo = detailItem?.photos?[indexPath.item] as? Photo, let image = UIImage(data: photo.image as Data) {
            
            photoDisplay.image = image
            showPhoto()
        }
    }
}




// MARK: MediaPickerManagerDelegate
extension PhotosViewController: MediaPickerManagerDelegate {
    
    func mediaPickerManager(manager: MediaPickerManager, didFinishPickingImage image: UIImage) {
        
        // make sure we successfully resized the image, that we have a detail item to work with
        // and the resized image could be converted to data
        guard let resizedImage = MediaPickerManager.resizeImage(image: image, toWidth: 750),
            let diaryEntry = detailItem,
            let imageData = UIImagePNGRepresentation(resizedImage) else { return }
        
        // save new image to store
        let photo = Photo(entity: Photo.entity(), insertInto: dataController.managedObjectContext)

        // set the Photo's properties and save
        photo.diaryEntry = diaryEntry
        photo.image = imageData as NSData
        diaryEntry.addToPhotos(photo)
        dataController.saveContext()
        
        // get back on the main queue
        DispatchQueue.main.async {
            
            // update the GUI
            self.refreshView()
            
            // dismiss the picker
            self.mediaPickerManager.dismissImagePickerController(animated: true, completion: {})
        }
    }
    
}
