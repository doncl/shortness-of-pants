//
//  ProgramSwitcherViewController.swift
//  ProgramSwitcher
//
//  Created by Don Clore on 7/4/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit
import AudioToolbox

class ProgramSwitcherViewController: UIViewController {
    
    @IBOutlet weak var channelNumber: UITextField!
    
    @IBOutlet var channelButtons: [UIButton]!
    var buttonImage: UIImage!
    
    
    @IBAction func Button2Press(sender: UIButton) {
        channelNumber.text = "2"
    }
    
    @IBAction func Button1Press(sender: UIButton) {
        channelNumber.text = "1"
    }

    @IBAction func Button3Press(sender: UIButton) {
        channelNumber.text = "3"
    }
    
    
    @IBAction func Button4Press(sender: UIButton) {
        channelNumber.text = "4"
    }
    
    @IBAction func Button5Press(sender: UIButton) {
        channelNumber.text = "5"
    }
    
    
    @IBAction func Button6Press(sender: UIButton) {
        channelNumber.text = "6"
    }
    
    @IBAction func Button7Press(sender: UIButton) {
        channelNumber.text = "7"
    }
    
    
    @IBAction func Button8Press(sender: UIButton) {
        channelNumber.text = "8"
    }
    
    @IBAction func Button9Press(sender: UIButton) {
            channelNumber.text = "9"
    }
    
    @IBAction func Button10Press(sender: UIButton) {
            channelNumber.text = "10"
    }
    
    @IBAction func Button11Press(sender: UIButton) {
            channelNumber.text = "11"
    }
    
    
    @IBAction func Button12Press(sender: UIButton) {
            channelNumber.text = "12"
    }
    
    
    @IBAction func Button13Press(sender: UIButton) {
            channelNumber.text = "13"
    }
    
    
    @IBAction func Button14Press(sender: UIButton) {
            channelNumber.text = "14"
    }
    
    @IBAction func Button15Press(sender: UIButton) {
            channelNumber.text = "15"
    }
    
    @IBAction func Button16Press(sender: UIButton) {
            channelNumber.text = "16"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
/*
        buttonImage = UIImage(named: "Button.jpg")
        for channelButton in channelButtons {
            channelButton.setImage(buttonImage, forState: .Normal)
        }
*/
    }
}

