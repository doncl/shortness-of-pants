//
//  ViewController.swift
//  ScrubberExample
//
//  Created by Don Clore on 3/25/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  let scrubber : Scrubber = Scrubber()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(scrubber)
    
    if #available(iOS 11.0, *) {
      NSLayoutConstraint.activate([
        scrubber.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        scrubber.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    } else {
      NSLayoutConstraint.activate([
        scrubber.rightAnchor.constraint(equalTo: view.rightAnchor),
        scrubber.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
    }
    
    
  }

}

