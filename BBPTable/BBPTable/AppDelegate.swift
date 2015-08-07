//
//  AppDelegate.swift
//  BBPTable
//
//  Created by Don Clore on 8/3/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        var vc = BBPTableViewController(loadMode:.DefaultView)
        setupTableProperties(vc)
            
        window?.rootViewController = vc
        vc.model = BBPTableModel()
        window?.makeKeyAndVisible()
        return true
    }
    
    private func setupTableProperties(viewController: BBPTableViewController) {
        var props = TableProperties()
        props.headerColor = UIColor(red:0.271, green:0.271, blue: 0.271, alpha:1)
        props.fixedColumns = 2
        props.headerFontName = "HelveticaNeue-Bold"
        props.headerFontSize = 12.0
        props.dataCellFontName = "HelveticaNeue"
        props.dataCellFontSize = 10.0
        props.oddRowColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        props.evenRowColor = UIColor(red:0.976, green:0.976, blue:0.976, alpha:1.0)
        props.dataCellTextColor = UIColor(red:0.271, green:0.271, blue:0.271, alpha:1.0)
        props.headerTextColor = UIColor(red:0.976, green:0.976, blue:0.976, alpha:1.0)
        props.borderColor = UIColor(red:223.0 / 255.0, green:223.0 / 255.0, blue: 223.0 / 255.0,
            alpha:1.0)
        props.borderWidth = 0.5
        viewController.tableProperties = props
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }
}

