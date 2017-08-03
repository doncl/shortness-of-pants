//
//  ViewController.swift
//  Example
//
//  Created by Don Clore on 8/3/17.
//  Copyright © 2017 Don Clore. All rights reserved.
//

import UIKit
import DiscreteSlider

class ViewController: UIViewController {
 
  @IBOutlet var slider: DiscreteSlider!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    slider.values = ["Value1", "Value2", "Value3", "Value4", "Value5"]
    
    slider.discreteValue = 0
  }



}

