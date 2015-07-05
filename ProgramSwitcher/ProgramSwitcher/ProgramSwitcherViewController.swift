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
    var buttonSelectedImage: UIImage!
    
    
    @IBAction func Button2Press(sender: UIButton) {
        channelNumber.text = "2"
        buttonPressed(sender)
    }
    
    @IBAction func Button1Press(sender: UIButton) {
        channelNumber.text = "1"
        buttonPressed(sender)
    }

    @IBAction func Button3Press(sender: UIButton) {
        channelNumber.text = "3"
        buttonPressed(sender)
    }
    
    
    @IBAction func Button4Press(sender: UIButton) {
        channelNumber.text = "4"
        buttonPressed(sender)
    }
    
    @IBAction func Button5Press(sender: UIButton) {
        channelNumber.text = "5"
        buttonPressed(sender)
    }
    
    
    @IBAction func Button6Press(sender: UIButton) {
        channelNumber.text = "6"
        buttonPressed(sender)
    }
    
    @IBAction func Button7Press(sender: UIButton) {
        channelNumber.text = "7"
        buttonPressed(sender)
    }
    
    
    @IBAction func Button8Press(sender: UIButton) {
        channelNumber.text = "8"
        buttonPressed(sender)
    }
    
    @IBAction func Button9Press(sender: UIButton) {
        channelNumber.text = "9"
        buttonPressed(sender)
    }
    
    @IBAction func Button10Press(sender: UIButton) {
        channelNumber.text = "10"
        buttonPressed(sender)
    }
    
    @IBAction func Button11Press(sender: UIButton) {
        channelNumber.text = "11"
        buttonPressed(sender)
    }
    
    
    @IBAction func Button12Press(sender: UIButton) {
        channelNumber.text = "12"
        buttonPressed(sender)
    }
    
    
    @IBAction func Button13Press(sender: UIButton) {
        channelNumber.text = "13"
        buttonPressed(sender)
    }
    
    
    @IBAction func Button14Press(sender: UIButton) {
        channelNumber.text = "14"
        buttonPressed(sender)
    }
    
    @IBAction func Button15Press(sender: UIButton) {
        channelNumber.text = "15"
        buttonPressed(sender)
    }
    
    @IBAction func Button16Press(sender: UIButton) {
        channelNumber.text = "16"
        buttonPressed(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonImage = UIImage(named: "Button.jpg")
        buttonSelectedImage = UIImage(named: "ButtonSelected.png")
        
/*
     
        for channelButton in channelButtons {
            channelButton.setImage(buttonImage, forState: .Normal)
        }
*/
    }
    
    func buttonPressed(pressedButton: UIButton) {
        
        pressedButton.setImage(buttonSelectedImage, forState: .Normal)
        
        for button in channelButtons {
            if (button !== pressedButton) {
                button.setImage(buttonImage, forState: .Normal)
            }
        }

        self.view.setNeedsDisplay()

    }
}

