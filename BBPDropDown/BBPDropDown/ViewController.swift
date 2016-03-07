//
//  ViewController.swift
//  BBPDropDown
//
//  Created by Don Clore on 3/5/16.
//  Copyright © 2016 Beer Barrel Poker Studios. All rights reserved.
//

import Foundation
import UIKit
import Darwin

class ViewController: UIViewController, BBPDropDownPopupDelegate, BBPDropDownDelegate {

    let data = ["Beatles", "Rolling Stones", "Jimi Hendrix", "King Crimson",
                "Emerson, Lake and Palmer", "Gentle Giant", "Yes", "Jethro Tull", "Genesis",
                "The Grateful Dead", "Jefferson Airplane"]

    var dropDownPopup: BBPDropDownPopup?

    @IBOutlet var selectedBandNames : UILabel!

    @IBOutlet var bbpDropDown: BBPDropdown!
    @IBOutlet var bbpDropDownHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bbpDropDown.lozengeData = data
        bbpDropDown.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        bbpDropDown.readjustHeight()
    }

    func showPopup(title: String, options: [String], xy: CGPoint, size: CGSize,
                   isMultiple: Bool) {

        dropDownPopup = BBPDropDownPopup(title: title, options: options, xy: xy, size: size,
            isMultiple: isMultiple)
                    
        dropDownPopup!.delegate = self
        dropDownPopup!.showInView(view, animated: true)
                    
        dropDownPopup!.popupBackgroundColor = UIColor(red: 0.0 / 255.0, green: 108.0 / 255.0,
                blue: 194.0 / 255.0, alpha: 0.70)
    }

    func dropDownView(dropDownView: BBPDropDownPopup, didSelectedIndex idx: Int) {
        selectedBandNames.text = data[idx]
    }

    func dropDownView(dropDownView: BBPDropDownPopup, dataList: [AnyObject]) {
        if data.count > 0 {
            selectedBandNames.text = data.joinWithSeparator("\r\n")
            let size = getHeightDynamic(selectedBandNames)
            selectedBandNames.frame = CGRectMake(16, 240, 287, size.height)
        } else {
            selectedBandNames.text = ""
        }
    }

    private func getHeightDynamic(label: UILabel) -> CGSize {
        //let range = NSMakeRange(0, label.text!.characters.count)
        //let rangePtr = UnsafeMutablePointer<NSRange>.alloc(1)

        let constraint = CGSize(width: 288.0, height: DBL_MAX)
        var size : CGSize
        
        let nsString : NSString = NSString(string: label.text!)
        
        let boundingRect = nsString.boundingRectWithSize(constraint,
            options: .UsesLineFragmentOrigin, attributes: [:],
            context: nil)
        
        let boundingBox = boundingRect.size
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height))
        return size
    }

    @IBAction func dropDownPressed(sender: AnyObject) {
        if let dropdown = dropDownPopup {
            dropdown.fadeOut()
        }

        showPopup("Select Bands", options: data, xy: CGPointMake(16, 58),
            size: CGSizeMake(287, 330), isMultiple: true)
    }
    
    @IBAction func dropDownSingle(sender: AnyObject) {
        if let dropdown = dropDownPopup {
            dropdown.fadeOut()
        }

        showPopup("SelectBand", options: data, xy: CGPointMake(16, 150),
            size: CGSizeMake(287, 280), isMultiple: false)
    }

    // MARK: - BBPDropDownDelegate implementation
    func requestNewHeight(newHeight: CGFloat) {
        UIView.animateWithDuration(0.6, delay:0.2, options:[.CurveEaseInOut], animations: {
            self.bbpDropDownHeightConstraint.constant = newHeight;
        }, completion: nil)
    }
}

