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

    // MARK: - private constants
    private let cellId = "LozengeCell"
    private let vertMargin : CGFloat = 8.0

    // MARK: - private properties
    private var lozengeData: [String] = []
    private var popTable: BBPDropDownPopup?
    private var view: UIView!  // Our custom view from the Xib file.
    private var rightGutterTapRecognizer : UITapGestureRecognizer?
    private var collectionViewTapRecognizer: UITapGestureRecognizer?
    private var backgroundViewTapRecognizer: UITapGestureRecognizer?

    // MARK: - IBOutlets
    @IBOutlet var lozengeCollection: UICollectionView!
    @IBOutlet var rightGutter: UIView!

    // MARK: - public non-inspectable properties
    var data : [String] = []

    // MARK: - Inspectable properties
    @IBInspectable var lozengeBackgroundColor : UIColor?
    @IBInspectable var lozengeTextColor : UIColor?
    @IBInspectable var borderColor : UIColor = UIColor.lightGrayColor()
    @IBInspectable var borderWidth : CGFloat = 1.0
    @IBInspectable var delegate: BBPDropDownDelegate?
    @IBInspectable var isMultiple : Bool = true

    // MARK: - Inspectable properties forwarded to contained popup

    // Ugh:  -- Apple encourages long, descriptive identifier names, but if I do that, these
    // get clipped in InterfaceBuilder.    These are not great names, and they get clipped, but
    // it's the best compromise I could find.
    @IBInspectable var popTitle: String?
    @IBInspectable var popBGColor: UIColor = UIColor(red: 204.0 / 255.0,
        green: 208.0 / 255.0, blue: 218.0 / 225.0, alpha: 0.70)
    @IBInspectable var shadOffCX: CGFloat = 2.5
    @IBInspectable var shadOffCY: CGFloat = 2.5
    @IBInspectable var shadRadius: CGFloat = 2.5
    @IBInspectable var shadAlpha: Float = 0.5
    @IBInspectable var sepColor : UIColor = UIColor(white: 1.0, alpha: 0.2)

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
        rightGutterTapRecognizer = setupTapRecog()
        rightGutter.addGestureRecognizer(rightGutterTapRecognizer!)
        collectionViewTapRecognizer = setupTapRecog()
        lozengeCollection.addGestureRecognizer(collectionViewTapRecognizer!)
        backgroundViewTapRecognizer = setupTapRecog()
        addGestureRecognizer(backgroundViewTapRecognizer!)
    }
    
    private func setupTapRecog() -> UITapGestureRecognizer {
        let recog = UITapGestureRecognizer()
        recog.numberOfTouchesRequired = 1
        recog.numberOfTapsRequired  = 1
        recog.enabled = true
        recog.addTarget(self, action: "tappedForPopup:")
        return recog;
    }

    func initializePopup(options: [String]) {
        resignFirstResponder()
        var xy = CGPoint(x: 0, y: frame.size.height)
        xy = convertPoint(xy, toView: superview)
        
        // TODO:  This initializer is kind of...not ideal.  Just set the properties.
        popTable = BBPDropDownPopup(title: popTitle!, options:options,
                xy: xy,
            size:CGSizeMake(frame.size.width, 280), isMultiple: isMultiple)

        popTable!.shadowOffsetWidth = shadOffCX
        popTable!.shadowOffsetHeight = shadOffCY
        popTable!.shadowRadius = shadRadius
        popTable!.shadowOpacity = shadAlpha
        popTable!.separatorColor = sepColor
        popTable!.popupBackgroundColor = popBGColor
        popTable!.delegate = self
        popTable!.showInView(superview!, animated:true)
    }
    
    // MARK: - tap handlers
    
    // Ugh! - why can't these be private?  Evidently targets for tap handlers cannot be.
    func tappedForPopup(sender: AnyObject) {
        print("tap, tap, tap...")
        initializePopup(data)
    }

    // MARK: - UICollectionViewDelegate
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
        initializePopup(data)
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
