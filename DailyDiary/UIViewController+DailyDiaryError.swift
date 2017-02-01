//
//  UIViewController+DailyDiaryError.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/29/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func onDailyDiaryError(notification: Notification) {
        
        guard self.isViewLoaded && (self.view.window != nil),
            let userInfo = notification.userInfo as? [String: Any],
            let error = userInfo[DailyDiaryError.ErrorKey] as? DailyDiaryError else { return }
        
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        let action:UIAlertAction
        
        if error.fatal {
            action = UIAlertAction(title: "OK", style: .default) {(action) in
                fatalError()
            }
        } else {
            action = UIAlertAction(title: "OK", style: .default, handler: nil)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}