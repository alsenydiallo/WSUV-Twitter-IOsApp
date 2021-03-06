//
//  AppDelegate.swift
//  WSUV-Twitter
//
//  Created by Alseny Diallo on 3/22/17.
//  Copyright © 2017 edu.wsu.vancouver. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator

let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
let kAddTweetNotification = Notification.Name("kAddTweetNotification")
let kWazzuTwitterPassword = "WazzuTwitterPassword" // KeyChain service

func sandboxArchivePath() -> String {
    let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
    return dir.appendingPathComponent("wsuv-twitter")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tweets: [Tweet] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let archiveName = sandboxArchivePath()
        if FileManager.default.fileExists(atPath: archiveName){
            tweets = NSKeyedUnarchiver.unarchiveObject(withFile: archiveName) as! [Tweet]
            
        }
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 1.0
        NetworkActivityIndicatorManager.shared.completionDelay = 0.2
        
        return true
    }

    func lastTweetDate() -> Date {
        if tweets.isEmpty {
            let oneYear = TimeInterval(60 * 60 * 24 * 365)
            return Date(timeIntervalSinceNow: -oneYear)
        }
        else{
            return (tweets.first?.date)!
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let archiveName = sandboxArchivePath()
        NSKeyedArchiver.archiveRootObject(tweets, toFile: archiveName)
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

