//
//  ProgramSwitcherViewController.swift
//  ProgramSwitcher
//
//  Created by Don Clore on 7/4/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

class ProgramSwitcherViewController: UIViewController {
    @IBOutlet weak var channelNumber: UITextField!
    @IBAction func changeChannel(sender: UIButton) {
        if let text = sender.titleLabel!.text {
            println("button = \(text)")
        }
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

