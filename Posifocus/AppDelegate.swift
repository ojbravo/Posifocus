//
//  AppDelegate.swift
//  Posifocus
//
//  Created by Omar Jesus Bravo on 4/6/18.
//  Copyright © 2018 Bravo-Delapaz. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Realm Migrations
        let config = Realm.Configuration(
            schemaVersion: 7,
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 2) {
                    migration.enumerateObjects(ofType: Profile.className()) { oldObject, newObject in
                        newObject!["profilePic"] = "blank-user.png"
                    }
                }
                if (oldSchemaVersion < 3) {
                    // Deleted GratitudeListed property from Profile
                    print("Migration to Schema v3!")
                }
                if (oldSchemaVersion < 4) {
                    print("Migration to Schema v4!")
                }
                if (oldSchemaVersion < 5) {
                    print("Migration to Schema v5!")
                }
                if (oldSchemaVersion < 6) {
                    // Changed Contact-contactDay to day
                    migration.enumerateObjects(ofType: Contact.className()) { oldObject, newObject in
                        newObject!["day"] = oldObject!["contactDay"]
                    }
                    print("Migration to Schema v6!")
                    
                }
                if (oldSchemaVersion < 7) {
                    // Changed Contact-contactDay to day
                    migration.enumerateObjects(ofType: Contact.className()) { oldObject, newObject in
                        newObject!["name"] = oldObject!["type"]
                    }
                    print("Migration to Schema v7!")
                }
                
            }
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        do {
            _ = try Realm()
            
        } catch  {
            print("Error initializing Realm \(error)")
        }
        
        return true
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


}

