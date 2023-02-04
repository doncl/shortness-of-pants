//
//  SceneDelegate.swift
//  BottomSheetExample
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    
    let win: UIWindow = UIWindow(windowScene: windowScene)
    window = win
    
    let vc: UIViewController = ViewController()
    win.rootViewController = vc
    
    win.makeKeyAndVisible()
  }
}

