//
//  ProgramSwitcherViewController.swift
//  ProgramSwitcher
//
//  Created by Don Clore on 7/4/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit
import AudioToolbox

class ProgramSwitcherViewController: UIViewController{
    
    @IBOutlet weak var channelNumber: UITextField!
    @IBOutlet weak var bankNumber: UITextField!
    @IBOutlet weak var programNumber: UITextField!
    
    @IBOutlet var channelButtons: [UIButton]!
    @IBOutlet var bankButtons: [UIButton]!
    @IBOutlet var programButtons: [UIButton]!
    
    var buttonImage: UIImage!
    var buttonSelectedImage: UIImage!
    
    var midiChannel: Int = 1
    var bank: Int = 1
    var program: Int = 1
    
    @IBAction func Button2Press(sender: UIButton) {
        midiChannel = 2
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button1Press(sender: UIButton) {
        midiChannel = 1
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }

    @IBAction func Button3Press(sender: UIButton) {
        midiChannel = 3
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    
    @IBAction func Button4Press(sender: UIButton) {
        midiChannel = 4
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button5Press(sender: UIButton) {
        midiChannel = 5
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    
    @IBAction func Button6Press(sender: UIButton) {
        midiChannel = 6
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button7Press(sender: UIButton) {
        midiChannel = 7
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button8Press(sender: UIButton) {
        midiChannel = 8
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button9Press(sender: UIButton) {
        midiChannel = 9
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button10Press(sender: UIButton) {
        midiChannel = 10
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button11Press(sender: UIButton) {
        midiChannel = 11
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button12Press(sender: UIButton) {
        midiChannel = 12
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button13Press(sender: UIButton) {
        midiChannel = 13
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button14Press(sender: UIButton) {
        midiChannel = 14
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button15Press(sender: UIButton) {
        midiChannel = 15
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func Button16Press(sender: UIButton) {
        midiChannel = 16
        buttonPressed(sender, label: channelNumber, value:midiChannel, buttonGroup:channelButtons)
    }
    
    @IBAction func bankButton1Press(sender: UIButton) {
        bank = 1
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton2Press(sender: UIButton) {
        bank = 2
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton3Press(sender: UIButton) {
        bank = 3
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton4Press(sender: UIButton) {
        bank = 4
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton5Press(sender: UIButton) {
        bank = 5
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton6Press(sender: UIButton) {
        bank = 6
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton7Press(sender: UIButton) {
        bank = 7
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton8Press(sender: UIButton) {
        bank = 8
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton9Press(sender: UIButton) {
        bank = 9
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton10Press(sender: UIButton) {
        bank = 10
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton11Press(sender: UIButton) {
        bank = 11
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton12Press(sender: UIButton) {
        bank = 12
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton13Press(sender: UIButton) {
        bank = 13
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton14Press(sender: UIButton) {
        bank = 14
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton15Press(sender: UIButton) {
        bank = 15
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }
    
    @IBAction func bankButton16Press(sender: UIButton) {
        bank = 16
        buttonPressed(sender, label: bankNumber, value:bank, buttonGroup: bankButtons)
    }    
    
    @IBAction func programButton1Press(sender: UIButton) {
        program = 1
        buttonPressed(sender, label: programNumber, value: program, buttonGroup: programButtons)
    }
    
    @IBAction func programButton2Press(sender: UIButton) {
        program = 2
        buttonPressed(sender, label: programNumber, value: program, buttonGroup: programButtons)
    }
    
    @IBAction func programButton3Press(sender: UIButton) {
        program = 3
        buttonPressed(sender, label: programNumber, value: program, buttonGroup: programButtons)
    }
    
    @IBAction func programButton4Press(sender: UIButton) {
        program = 4
        buttonPressed(sender, label: programNumber, value: program, buttonGroup: programButtons)
    }
    
    @IBAction func programButton5Press(sender: UIButton) {
        program = 5
        buttonPressed(sender, label: programNumber, value: program, buttonGroup: programButtons)
    }
    
    @IBAction func programButton6Press(sender: UIButton) {
        program = 6
        buttonPressed(sender, label: programNumber, value: program, buttonGroup: programButtons)
    }
    
    @IBAction func programButton7Press(sender: UIButton) {
        program = 7
        buttonPressed(sender, label: programNumber, value: program, buttonGroup: programButtons)
    }
    
    @IBAction func programButton8Press(sender: UIButton) {
        program = 8
        buttonPressed(sender, label: programNumber, value: program, buttonGroup: programButtons)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonImage = UIImage(named: "Button.jpg")
        buttonSelectedImage = UIImage(named: "Button_on.jpg")
            
            
        Button1Press(channelButtons[0])
        bankButton1Press(bankButtons[0])
        programButton1Press(programButtons[0])
    }
    
    
    func buttonPressed(pressedButton: UIButton, label: UITextField, value: Int, buttonGroup: [UIButton]) {
        
        if (label !== programNumber) {
            label.text = String(value)
        }
        programNumber.text = String(((bank - 1) * 8) + program)
        pressedButton.setImage(buttonSelectedImage, forState: .Normal)
        
        for button in buttonGroup {
            if (button !== pressedButton) {
                button.setImage(buttonImage, forState: .Normal)
            }
        }

        self.view.setNeedsDisplay()
    }
}

