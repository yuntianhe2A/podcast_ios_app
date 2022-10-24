//
//  AppDelegate.swift
//  FinalAssignment
//
//  Created by Yansong Li on 19/5/20.
//  Copyright © 2020 Yansong Li. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var databaseController: DatabaseProtocol?
    
    var window: UIWindow?
    
    var persistantContainer: NSPersistentContainer?
    static let CATEGORY_IDENTIFIER = "edu.monash.fit3178.category1"
    var notificationsEnabled = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        databaseController = FirebaseController()
        
        // Override point for customization after application launch.
         
        persistantContainer = NSPersistentContainer(name: "DataModel")
        persistantContainer?.loadPersistentStores() { (description, error) in
            if let error = error{
            fatalError("Failed to load Core Data stack: \(error)")
        }
        
    }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
              self.notificationsEnabled = granted
              print("User allows notifcations: \(granted)")

              if self.notificationsEnabled {
                  let acceptAction = UNNotificationAction(identifier: "accept", title: "Play", options: .foreground)
                  let declineAction = UNNotificationAction(identifier: "decline", title: "Later", options: .destructive)

                  // Set up the category
                  let appCategory = UNNotificationCategory(identifier: AppDelegate.CATEGORY_IDENTIFIER, actions: [acceptAction, declineAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))

                  // Register the category just created with the notification centre
                  UNUserNotificationCenter.current().setNotificationCategories([appCategory])
              }
          }
        return true

    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

