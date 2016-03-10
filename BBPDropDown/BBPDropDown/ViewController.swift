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

class ViewController: UIViewController, BBPDropDownDelegate {

    let data = ["Beatles", "Rolling Stones", "Jimi Hendrix", "King Crimson",
                "Emerson, Lake and Palmer", "Gentle Giant", "Yes", "Jethro Tull", "Genesis",
                "The Grateful Dead", "Jefferson Airplane"]

    var dropDownPopup: BBPDropDownPopup?

    @IBOutlet var selectedBandNames : UILabel!

    @IBOutlet var bbpDropDownSingle: BBPDropdown!
    @IBOutlet var bbpDropDownSingleHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bbpDropDownMulti: BBPDropdown!
    @IBOutlet var bbpDropDownMultiHeightConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        bbpDropDownMulti.delegate = self
        bbpDropDownMulti.data = data
        bbpDropDownMulti.isMultiple = true
        bbpDropDownSingle.delegate = self
        bbpDropDownSingle.data = data
        bbpDropDownSingle.isMultiple = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        bbpDropDownMulti.readjustHeight()
        bbpDropDownSingle.readjustHeight()
    }

    // MARK: - BBPDropDownDelegate implementation
    func requestNewHeight(dropDown: BBPDropdown, newHeight: CGFloat) {
        UIView.animateWithDuration(0.6, delay:0.2, options:[.CurveEaseInOut], animations: {
            if dropDown === self.bbpDropDownMulti {
                self.bbpDropDownMultiHeightConstraint.constant = newHeight
            } else {
                self.bbpDropDownSingleHeightConstraint.constant = newHeight
            }

        }, completion: nil)
    }

    func dropDownView(dropDown: BBPDropdown, didSelectedItem item: String) {
        // DO nothing for this example.
        print("single select item selected \(item)")
    }

    func dropDownView(dropDown: BBPDropdown, dataList: [String]) {
        // DO nothing for this example.
        print("multi-select items selected \(dataList)")
    }
}

