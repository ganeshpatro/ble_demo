//
//  PushNotificationHandler.swift
//  BLEBackgroundDemo
//
//  Created by Ganesh Patro on 4/18/18.
//  Copyright © 2018 GlobalEdge. All rights reserved.
//

import UIKit

class PushNotificationHandler: NSObject {

    static let sharedInstance = PushNotificationHandler()
    
    override init() {
        super.init()
    }
    
    func sendPushNotification(withMessage message: String) {
        
    }
}

