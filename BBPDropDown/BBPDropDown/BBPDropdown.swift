//
//  BBPDropdown.swift
//  BBPDropDown
//
//  Created by Don Clore on 3/6/16.
//  Copyright © 2016 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

protocol BBPDropDownDelegate {
    func requestNewHeight(dropDown:BBPDropdown, newHeight: CGFloat);
}

@IBDesignable class BBPDropdown: UIView, UICollectionViewDelegate, UICollectionViewDataSource,
        LozengeCellDelegate, BBPDropDownPopupDelegate {
    private let cellId = "LozengeCell"
    private let vertMargin : CGFloat = 8.0

    @IBOutlet var lozengeCollection: UICollectionView!

    @IBInspectable var popupTitle : String?
    @IBInspectable var lozengeBackgroundColor : UIColor?
    @IBInspectable var lozengeTextColor : UIColor?
    @IBInspectable var borderColor : UIColor = UIColor.lightGrayColor()
    @IBInspectable var borderWidth : CGFloat = 1.0
    var lozengeData: [String] = []
    var data : [String] = []
    var popTable: BBPDropDownPopup?
    
    var view: UIView!  // Our custom view from the Xib file.
    @IBInspectable var delegate: BBPDropDownDelegate?
    @IBInspectable var isMultiple : Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
        commonInitStuff()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        commonInitStuff()
    }
    
    func xibSetup() {
        view = loadViewFromXib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Adding custom subview on top of our view
        addSubview(view)
    }
    
    func loadViewFromXib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName:"BBPDropDown", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options:nil)[0] as! UIView
        return view
    }

    func commonInitStuff() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: cellId, bundle:bundle)
        lozengeCollection.registerNib(nib, forCellWithReuseIdentifier: cellId)
        lozengeCollection.dataSource = self
        lozengeCollection.delegate = self
        lozengeCollection.reloadData()
        layer.borderColor = borderColor.CGColor
        layer.borderWidth = borderWidth
    }

    func initializePopup(options: [String]) {
        resignFirstResponder()
        var xy = CGPoint(x: 0, y: frame.size.height)
        xy = convertPoint(xy, toView: superview)
        popTable = BBPDropDownPopup(title: popupTitle!, options:options,
                xy: xy,
            size:CGSizeMake(frame.size.width, 280), isMultiple: isMultiple)

        popTable!.delegate = self
        popTable!.showInView(superview!, animated:true)
        popTable!.popupBackgroundColor = UIColor(red: 0.0 / 255.0, green: 108.0 / 255.0,
                blue: 194.0 / 255.0, alpha: 0.70)
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return lozengeData.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath
        indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId,
            forIndexPath: indexPath) as? LozengeCell

        cell!.lozengeText.text = lozengeData[indexPath.row]
        if let lozengeBackgroundColor = lozengeBackgroundColor,
            lozengeTextColor = lozengeTextColor {
            cell!.backgroundColor = lozengeBackgroundColor
            cell!.lozengeText.textColor = lozengeTextColor
        }
        cell!.delegate = self
        cell!.setupDeleteTap()
        return cell!
    }

    func collectionView(collectionView: UICollectionView, didEndDisplayingCell
        cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        readjustHeight()
    }


    // MARK: - IBActions
    @IBAction func dropDownButtonTouched(sender: AnyObject) {
        //lozengeData.append("More Data")

        initializePopup(data)
        //lozengeCollection.reloadData()
        //readjustHeight()
    }
    
    func readjustHeight() {
        let size = lozengeCollection.collectionViewLayout.collectionViewContentSize()
        let height = size.height + (vertMargin * 2)
        if let flowLayout = lozengeCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            let minHeight = flowLayout.itemSize.height + (vertMargin * 2)
            if let delegate = delegate {
                delegate.requestNewHeight(self, newHeight: max(minHeight, height))
            }
        }
    }
    
    // MARK: - LozengeCellDelegate
    func deleteTapped(cell: LozengeCell) {
        if let path = lozengeCollection.indexPathForCell(cell) {
            lozengeData.removeAtIndex(path.row)
            lozengeCollection.deleteItemsAtIndexPaths([path])
        }
    }

    // MARK: - BBPDropDownPopupDelegate
    func dropDownView(dropDownView: BBPDropDownPopup, didSelectedIndex idx: Int) {
        let itemData = data[idx]
        lozengeData.append(itemData)
        lozengeCollection.reloadData()
    }

    func dropDownView(dropDownView: BBPDropDownPopup, dataList: [String]) {
        print("dropDownView:dataList: called")
        lozengeData = dataList
        lozengeCollection.reloadData()
        readjustHeight()
    }
}
