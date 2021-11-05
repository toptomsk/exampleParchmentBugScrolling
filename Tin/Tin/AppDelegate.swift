//
//  AppDelegate.swift
//  Tin
//
//  Created by Admin on 1/3/19.
//  Copyright © 2019 vietnb. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var didCallWhenDidFinishOption:Bool = false
    
    
    var window: UIWindow?
    static let sharedInstance = AppDelegate()
   
    var applicationApp: UIApplication?
    var launchOptionsApp: [UIApplication.LaunchOptionsKey: Any]?
    
    //MARK: - App khởi động ở đây
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabbarViewController = (storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController)
                
        let slideMenuController = RootNavigationController.init(rootViewController: tabbarViewController)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)//
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    ///dynamic Link Firebase
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        print("Continue User Activity called: ")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            print(url.absoluteString)
            //handle url and open whatever page you want to open.
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applstartNotifiericationWillTerminate: when the user quits.
        
    }

   
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //UserDefault.sharedInstance.setKillApp(kill: true)
    }
}

