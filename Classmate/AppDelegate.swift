//
//  AppDelegate.swift
//  Classmate
//
//  Created by Administrator on 7/3/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var databaseReference: DatabaseReference?
    
    func sharedInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        FirebaseApp.configure()
        databaseReference = Database.database().reference()
        
        if Auth.auth().currentUser != nil {
            if let currentUser = Auth.auth().currentUser {
                GlobalFunction.sharedManager.showProgressView("Loading...")
                databaseReference?.child("users").child(currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
                    
                    GlobalFunction.sharedManager.hideProgressView()
                    if let user = User.init(snapshot: snapshot) {
                        GlobalVariable.sharedManager.loggedInUser = user
                        self.loginAction()
                    } else {

                    }
                }
            }
        }
        
        let locale = NSLocale.current
        let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
        if formatter.contains("a") {
            GlobalVariable.sharedManager.is24Format = false
        } else {
            GlobalVariable.sharedManager.is24Format = false
        }
        
        return true
    }
    
    func loadReads() {
        databaseReference?.child("reads").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            GlobalVariable.sharedManager.reads.removeAll()
            for child in snapshot.children {
                if let child_snapshot = child as? DataSnapshot {
                    if let last_seen = child_snapshot.value as? String {
                        GlobalVariable.sharedManager.reads[child_snapshot.key] = last_seen
                    }
                }
            }
        }
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

    func loginAction() {
        loadReads()
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let mainTabbarController = storyboard.instantiateViewController(withIdentifier: "MainTabbarViewController") as! MainTabbarViewController
        
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.window?.rootViewController = mainTabbarController
            self.window?.makeKeyAndVisible()
        }, completion: nil)
    }
    
    func logoutAction() {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "StartViewController") as! StartViewController
        
        let navigationController = UINavigationController.init(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        UIView.transition(with: self.window!, duration: 0.5, options: .transitionFlipFromRight, animations: {
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }, completion: nil)
    }
    
}

