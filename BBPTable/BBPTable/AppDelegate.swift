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
        vc.model?.buildFromText(self.generateTestHtml())
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
    
    private func generateTestHtml() -> String{
        var htmlTable = 
            "<table width=\"603\" height=\"339\" class=\"responsive-table\">" +
                "<thead>" +
                    "<tr><td>#</td>\n<td>Player</td>\n<td>Team</td>\n<td>Bye</td>\n<td>Age</td>\n<td>ADP</td>\n<td>AAV</td>\n<td>Project. Points</td>\n</tr>" +
                "</thead>" +
                "<tbody>" +
                    "<tr><td>1</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/51528-jamaal-charles\">Jamaal Charles</a></td>\n<td>KC</td>\n<td>9</td>\n<td>28</td>\n<td>8.27</td>\n<td>$35</td>\n<td>261.3</td>\n</tr>" +
                    "<tr><td>2</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/123323-le-veon-bell\">Le'Veon Bell</a></td>\n<td>PIT</td>\n<td>11</td>\n<td>22</td>\n<td>2.52</td>\n<td>$40</td>\n<td>245.0</td>\n</tr>" +
                    "<tr><td>3</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/100476-eddie-lacy\">Eddie Lacy</a></td>\n<td>GB</td>\n<td>7</td>\n<td>24</td>\n<td>6.5</td>\n<td>$36</td>\n<td>244.3</td>\n</tr>" +
                    "<tr><td>4</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/29643-adrian-peterson\">Adrian Peterson</a></td>\n<td>MIN</td>\n<td>5</td>\n<td>30</td>\n<td>8.13</td>\n<td>#31</td>\n<td>239.2</td>\n</tr>" +
                    "<tr><td>5</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/33517-marshawn-lynch\">Marshawn Lynch</a></td>\n<td>SEA</td>\n<td>9</td>\n<td>29</td>\n<td>18.09</td>\n<td>$29</td>\n<td>237.8</td>\n</tr>" +
                    "<tr><td>6</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/48607-arian-foster\">Arian Foster</a></td>\n<td>HOU</td>\n<td>9</td>\n<td>28</td>\n<td>22.79</td>\n<td>$27</td>\n<td>235.1</td>\n</tr>" +
                    "<tr><td>7</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/113301-c-j-anderson\">C.J. Anderson</a></td>\n<td>DEN</td>\n<td>7</td>\n<td>24</td>\n<td>19.2</td>\n<td>$27</td>\n<td>228.5</td>\n</tr>" +
                    "<tr><td>8</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/36218-matt-forte\">Matt Forte</a></td>\n<td>CHI</td>\n<td>7</td>\n<td>29</td>\n<td>19.34</td>\n<td>$28</td>\n<td>220.0</td>\n</tr>" +
                    "<tr><td>9</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/128394-jeremy-hill\">Jeremy Hill</a></td>\n<td>CIN</td>\n<td>7</td>\n<td>22</td>\n<td>22.58</td>\n<td>$28</td>\n<td>214.1</td>\n</tr>" +
                    "<tr><td>10</td>\n<td><a data-type=\"Player\" data-key=\"undefined\" class=\"scout-wire-card\" href=\"http://www.scout.com/player/123341-joseph-randle\">Joseph Randle</a></td>\n<td>DAL</td>\n<td>6</td>\n<td>23</td>\n<td>53.11</td>\n<td>$12</td>\n<td>209.8</td>\n</tr>" +
                "</tbody>" +
            "</table>"

        return htmlTable
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

