//
//  DailyDiaryError.swift
//  DailyDiary
//
//  Created by redBred LLC on 2/1/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

struct DailyDiaryError {
    static let ErrorNotification = Notification.Name("DailyDiaryErrorNotification")
    static let ErrorKey = "ErrorKey"
    
    let title: String
    let message: String
    let fatal: Bool
    
    func makeUserInfoDict() -> [String : Any] {
        return [DailyDiaryError.ErrorKey : DailyDiaryError(title: title, message: message, fatal: fatal)]
    }
    
    static func getErrorFromNotification(notification: Notification) -> DailyDiaryError? {
    
        guard let userInfo = notification.userInfo as? [String: Any],
              let error = userInfo[DailyDiaryError.ErrorKey] as? DailyDiaryError else { return nil }
        
        return error
    }
}
