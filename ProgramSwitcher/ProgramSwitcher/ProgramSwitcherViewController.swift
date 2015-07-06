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
    
    @IBOutlet var bankButtons: [UIButton]!
    
    @IBOutlet var programButtons: [UIButton]!
    
    var buttonImage: UIImage!
    var buttonSelectedImage: UIImage!
    
    
    @IBAction func Button2Press(sender: UIButton) {
        channelNumber.text = "2"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    @IBAction func Button1Press(sender: UIButton) {
        channelNumber.text = "1"
        buttonPressed(sender, buttonGroup:channelButtons)
    }

    @IBAction func Button3Press(sender: UIButton) {
        channelNumber.text = "3"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    
    @IBAction func Button4Press(sender: UIButton) {
        channelNumber.text = "4"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    @IBAction func Button5Press(sender: UIButton) {
        channelNumber.text = "5"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    
    @IBAction func Button6Press(sender: UIButton) {
        channelNumber.text = "6"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    @IBAction func Button7Press(sender: UIButton) {
        channelNumber.text = "7"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    
    @IBAction func Button8Press(sender: UIButton) {
        channelNumber.text = "8"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    @IBAction func Button9Press(sender: UIButton) {
        channelNumber.text = "9"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    @IBAction func Button10Press(sender: UIButton) {
        channelNumber.text = "10"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    @IBAction func Button11Press(sender: UIButton) {
        channelNumber.text = "11"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    
    @IBAction func Button12Press(sender: UIButton) {
        channelNumber.text = "12"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    
    @IBAction func Button13Press(sender: UIButton) {
        channelNumber.text = "13"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    
    @IBAction func Button14Press(sender: UIButton) {
        channelNumber.text = "14"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    @IBAction func Button15Press(sender: UIButton) {
        channelNumber.text = "15"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    @IBAction func Button16Press(sender: UIButton) {
        channelNumber.text = "16"
        buttonPressed(sender, buttonGroup:channelButtons)
    }
    
    
    @IBAction func bankButton1Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton2Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    
    @IBAction func bankButton3Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton4Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton5Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton6Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton7Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton8Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton9Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton10Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton11Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton12Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton13Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton14Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton15Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    @IBAction func bankButton16Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:bankButtons)
    }
    
    
    @IBAction func programButton1Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:programButtons)
    }
    
    @IBAction func programButton2Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:programButtons)
    }
    
    @IBAction func programButton3Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:programButtons)
    }
    
    @IBAction func programButton4Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:programButtons)
    }
    
    @IBAction func programButton5Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:programButtons)
    }
    
    @IBAction func programButton6Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:programButtons)
    }
    
    @IBAction func programButton7Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:programButtons)
    }
    
    @IBAction func programButton8Press(sender: UIButton) {
        buttonPressed(sender, buttonGroup:programButtons)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonImage = UIImage(named: "Button.jpg")
        buttonSelectedImage = UIImage(named: "ButtonSelected.png")
        
        Button1Press(channelButtons[0])
        bankButton1Press(bankButtons[0])
        programButton1Press(programButtons[0])
    }
    
    func buttonPressed(pressedButton: UIButton, buttonGroup: [UIButton]) {
        
        pressedButton.setImage(buttonSelectedImage, forState: .Normal)
        
        for button in buttonGroup {
            if (button !== pressedButton) {
                button.setImage(buttonImage, forState: .Normal)
            }
        }

        self.view.setNeedsDisplay()

    }
}

