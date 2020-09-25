//
//  AppDelegate.swift
//  streetParker
//
//  Created by Jamil Jalal on 11/13/19.
//  Copyright © 2019 Jamil Jalal. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = "726611880229-lqtgmmc76251r7792eq1ssve477lkui3.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        if Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let authVC = storyboard.instantiateViewController(withIdentifier: "AuthVC")
            window?.makeKeyAndVisible()
            authVC.modalPresentationStyle = .fullScreen

            window?.rootViewController?.present(authVC, animated: true, completion: nil)
            NotificationCenter.default.post(name: Notification.Name("signedOut"), object: nil)
        }
        
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

       
        
        
        if let token = AccessToken.current, !token.isExpired {
            // User is logged in, do work such as go to next view controller.
           
        }
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(30)
        UIApplication.backgroundFetchIntervalMinimum
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        // Perform any operations on signed in user here.
        let userId = user.userID                  // For client-side use only!
        let idToken = user.authentication.idToken // Safe to send to the server
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email
    }
    // MARK: - Background Fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Dataservice.instance.checkForBluetoothConnection { (device) in
            if device {
                print("Device Found")
            }else{
                print("Device disconnected Found")
            }
            completionHandler(.newData)
        }
        
        
    }
    
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
//              withError error: Error!) {
//      // Perform any operations when the user disconnects from app here.
//      // ...
////        Dataservice.instance.deleteAllDataFromCoreData { (complete) in
////            if complete {
////                print("Core Data Objects deleted")
////            }else {
////                print("Couldn't delete Core Data Objects")
////            }
////        }
////        Authservice.instance.signOut()
//    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    // MARK: - App entered in Background
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("App has entered in background")
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

    // MARK: - Core Data stack
      lazy var persistentContainer: NSPersistentContainer = {
          /*
           The persistent container for the application. This implementation
           creates and returns a container, having loaded the store for the
           application to it. This property is optional since there are legitimate
           error conditions that could cause the creation of the store to fail.
          */
          let container = NSPersistentContainer(name: "streetParkerMod")
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
              if let error = error as NSError? {
                  // Replace this implementation with code to handle the error appropriately.
                  // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                   
                  /*
                   Typical reasons for an error here include:
                   * The parent directory does not exist, cannot be created, or disallows writing.
                   * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                   * The device is out of space.
                   * The store could not be migrated to the current model version.
                   Check the error message to determine what the actual problem was.
                   */
                  fatalError("Unresolved error \(error), \(error.userInfo)")
              }
          })
          return container
      }()

      // MARK: - Core Data Saving support
      func saveContext () {
          let context = persistentContainer.viewContext
          if context.hasChanges {
              do {
                  try context.save()
              } catch {
                  // Replace this implementation with code to handle the error appropriately.
                  // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                  let nserror = error as NSError
                  fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
              }
          }
      }


}

