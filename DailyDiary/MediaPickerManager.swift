//
//  MediaPickerManager.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//
// Thanks To Pasan for most of this code which wass adapted from his FaceSnap project
// for TeamTreehouse

import UIKit
import MobileCoreServices

protocol MediaPickerManagerDelegate: class {
    func mediaPickerManager(manager: MediaPickerManager, didFinishPickingImage image: UIImage)
}

class MediaPickerManager: NSObject {
    
    private let imagePickerController = UIImagePickerController()
    private let presentingViewController: UIViewController
    
    weak var delegate: MediaPickerManagerDelegate?
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
        
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String]
    }
    
    func presentImagePickerController(animated: Bool) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (action) in
                self.takePhoto(animated: animated)
            }
            
            let libraryAction = UIAlertAction(title: "Choose from Library", style: .default) { (action) in
                self.pickPhoto(animated: animated)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cameraAction)
            alert.addAction(libraryAction)
            alert.addAction(cancelAction)
            
            alert.popoverPresentationController?.sourceView = presentingViewController.view
            alert.popoverPresentationController?.sourceRect = presentingViewController.view.bounds
            
            presentingViewController.present(alert, animated: true, completion: nil)
            
        } else {
            
            pickPhoto(animated: animated)
        }
    }
    
    func dismissImagePickerController(animated: Bool, completion: @escaping (() -> Void)) {
        imagePickerController.dismiss(animated: animated, completion: completion)
    }
    
    internal func takePhoto(animated: Bool) {
        
        imagePickerController.sourceType = .camera
        imagePickerController.cameraDevice = .front

        presentingViewController.present(imagePickerController, animated: animated, completion: nil)
    }
    
    internal func pickPhoto(animated: Bool) {
        
        imagePickerController.sourceType = .photoLibrary
        
        presentingViewController.present(imagePickerController, animated: animated, completion: nil)
    }
    
    // method to resize image - reduce footprint
    static func resizeImage(image: UIImage, toWidth: CGFloat) -> UIImage? {
        
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

extension MediaPickerManager: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        delegate?.mediaPickerManager(manager: self, didFinishPickingImage: image)
    }
}
