//
//  AppDelegate.swift
//  BLEBackgroundDemo
//
//  Created by Ganesh Patro on 4/18/18.
//  Copyright © 2018 GlobalEdge. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

let DEVICE_TOKEN = "device_token"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var timer: Timer?
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    class func sharedApplication() -> AppDelegate {
        return UIApplication.shared.delegate! as UIApplicationDelegate as! AppDelegate
    }
    
    func startConnectTimer() {
        registerBackgroundTask()
        timer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true, block: { (timer) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "start_scaniing"), object: nil)
        })
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
       // assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
        timer?.invalidate()
        timer = nil
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        registerForRemoteNotification(application)
        return true
    }
    
    func registerForRemoteNotification(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        UserDefaults.standard.setValue(fcmToken, forKey: DEVICE_TOKEN)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func showLocalNotification(withMessage message: String) {
        let content = UNMutableNotificationContent()
        let requestIdentifier = "ganeshNotification"
        
        content.badge = 1
        content.title = "This is a Local notification"
        content.subtitle = "BLE"
        content.body = message
        content.categoryIdentifier = "actionCategory"
        content.sound = UNNotificationSound.default()
        
//        // If you want to attach any image to show in local notification
//        let url = Bundle.main.url(forResource: "notificationImage", withExtension: ".jpg")
//        do {
//            let attachment = try? UNNotificationAttachment(identifier: requestIdentifier, url: url!, options: nil)
//            content.attachments = [attachment!]
//        }
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            
            if error != nil {
                print(error?.localizedDescription)
            }
            print("Notification Register Success")
        }
    }
    
    
    
}

