//
//  AppDelegate.swift
//  OctoPrintMobile
//
//  Created by William Young on 3/9/16.
//  Copyright © 2016 William Young. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func needShowSettings() -> Bool {
        if settings.currentSettings?.apikey == nil || settings.currentSettings?.url == nil {
            return true
        }
        if (settings.currentSettings?.apikey?.isEmpty)! || (settings.currentSettings?.url?.isEmpty)! {
            return true
        }
        return false
    }
    
    func showSettings(notice:String = "You must setup API connection before use."){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainvc = storyboard.instantiateInitialViewController()
        let tbc = mainvc as! UITabBarController
        
        let settingsindex = tbc.viewControllers?.indexOf({
            vc in
            if vc.restorationIdentifier == "settings" {
               return true
            }
            return false
        })
        
        let settingsvc = tbc.viewControllers![settingsindex!]
        
        tbc.selectedViewController = settingsvc
        
        dispatch_async(dispatch_get_main_queue(), {
            let notice = UIAlertController(title: "Invalid Setup", message: notice, preferredStyle: UIAlertControllerStyle.ActionSheet)
            notice.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: {_ in}))
            self.window?.rootViewController?.presentViewController(notice, animated: true, completion: {})
        })
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = mainvc
        self.window?.makeKeyAndVisible()
        
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if needShowSettings() {
            showSettings()
            return true
        }
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        TemperatureManager.timer?.invalidate()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if needShowSettings(){
            let manager = NSFileManager()
            do {
                try manager.removeItemAtURL(url)
            } catch let error as NSError {
                print(error)
            }
            showSettings("You must setup API connection before uploading files.")
            return true
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainvc = storyboard.instantiateInitialViewController()
        let vc = storyboard.instantiateViewControllerWithIdentifier("Uploads")
        let uv = vc as! UploadView
        uv.url = url
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = mainvc
        self.window?.makeKeyAndVisible()
        
        mainvc!.presentViewController(uv, animated: true, completion: {})
        
        return true
    }
    
}

