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
    func dropDownView(dropDown: BBPDropdown, didSelectedItem item:String);
    func dropDownView(dropDown: BBPDropdown, dataList: [String]);
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
    private var labelTapRecognizer: UITapGestureRecognizer?
    private var dropDownVisible : Bool = false
    private var ready : Bool = false

    private func showPlaceholder(show: Bool) {
        placeHolderLabel.alpha =  show ? 1.0 : 0.0
        placeHolderLabel.hidden = !show

        showSingleItemLabel(!isMultiple && !show)
        showLozengeCollection(isMultiple && !show)
    }

    private func showSingleItemLabel(show: Bool) {
        singleItemLabel.alpha = show ? 1.0 : 0.0
        singleItemLabel.hidden = !show
    }

    private func showLozengeCollection(show: Bool) {
        lozengeCollection.alpha = show ? 1.0 : 0.0
        lozengeCollection.hidden = !show
    }

    // MARK: - IBOutlets
    @IBOutlet var lozengeCollection: UICollectionView!
    @IBOutlet var rightGutter: UIView!
    @IBOutlet var singleItemLabel: UILabel!
    @IBOutlet var placeHolderLabel: UILabel!

    // MARK: - public non-inspectable properties
    var data : [String] = [] {
        didSet (newValue) {
            ready = true
        }
    }

    var singleItemText : String? {
        get {
            return singleItemLabel.text
        }
        set (newValue) {
            var placeHolder : Bool = false
            singleItemLabel.text = newValue
            if let text = newValue {
                placeHolder = text != "" ? false : true
            } else {
                placeHolder = true
            }
            showPlaceholder(placeHolder)
        }
    }

    // MARK: - Inspectable properties
    @IBInspectable var placeHolderText : String? {
        get {
            return placeHolderLabel.text
        }
        set (newValue) {
            placeHolderLabel.text = newValue
        }       
    }
    @IBInspectable var lozengeBackgroundColor : UIColor?
    @IBInspectable var lozengeTextColor : UIColor?
    @IBInspectable var borderColor : UIColor = UIColor.lightGrayColor()
    @IBInspectable var borderWidth : CGFloat = 1.0
    @IBInspectable var delegate: BBPDropDownDelegate?
    @IBInspectable var isMultiple : Bool = false {
        didSet(newValue){
            setUIStateForSelectionMode(newValue)
        }
    }

    // MARK: - Inspectable properties forwarded to contained popup

    // Ugh:  -- Apple encourages long, descriptive identifier names, but if I do that, these
    // get clipped in InterfaceBuilder.    These are not great names, and they get clipped, but
    // it's the best compromise I could find.
    @IBInspectable var popTitle: String = ""
    @IBInspectable var popBGColor: UIColor = UIColor(red: 204.0 / 255.0,
        green: 208.0 / 255.0, blue: 218.0 / 225.0, alpha: 0.70)
    @IBInspectable var popTextColor : UIColor = UIColor.blackColor()
    @IBInspectable var shadOffCX: CGFloat = 2.5
    @IBInspectable var shadOffCY: CGFloat = 2.5
    @IBInspectable var shadRadius: CGFloat = 2.5
    @IBInspectable var shadAlpha: Float = 0.5
    @IBInspectable var sepColor : UIColor = UIColor(white: 1.0, alpha: 0.2)
    @IBInspectable var selectImage : UIImage?
    @IBInspectable var showsHeader : Bool = false
    @IBInspectable var headerTextColor : UIColor?

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
        labelTapRecognizer = setupTapRecog()
        singleItemLabel.addGestureRecognizer(labelTapRecognizer!)
        singleItemLabel.translatesAutoresizingMaskIntoConstraints = false
        setUIStateForSelectionMode(isMultiple)
    }

    func setUIStateForSelectionMode(multiSelect: Bool) {
        lozengeCollection.alpha = multiSelect ? 1.0 : 0.0
        singleItemLabel.alpha = multiSelect ? 0.0 : 1.0
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
        if let popTable = popTable {
            popTable.fadeOut()
        }
        var xy = CGPoint(x: 0, y: frame.size.height)
        xy = convertPoint(xy, toView: superview)
        
        let indexes = getIndexesForSelectedItems()
        
        // TODO:  This initializer is kind of...not ideal.  Just set the properties.
        popTable = BBPDropDownPopup(title: popTitle, options:options,
                xy: xy,
            size:CGSizeMake(frame.size.width, 280), isMultiple: isMultiple,
                showsHeader: showsHeader)

        // If they specified an image in the storyboard/xib, honor it.
        if let selectImage = selectImage {
            popTable!.cellSelectionImage = selectImage
        }
        if let headerTextColor = headerTextColor {
            popTable!.headerTextColor = headerTextColor
        }

        popTable!.popupTextColor = popTextColor
        popTable!.selectedItems = indexes
        popTable!.shadowOffsetWidth = shadOffCX
        popTable!.shadowOffsetHeight = shadOffCY
        popTable!.shadowRadius = shadRadius
        popTable!.shadowOpacity = shadAlpha
        popTable!.separatorColor = sepColor
        popTable!.popupBackgroundColor = popBGColor
        popTable!.delegate = self
        popTable!.showInView(superview!, animated:true)
        dropDownVisible = true
    }

    func getIndexesForSelectedItems() -> [NSIndexPath] {
        var indexes = [NSIndexPath]()
        if isMultiple {
            // If it's the mult-select case, grovel through the lozengeData
            for lozengeDatum in lozengeData {
                if let idx = data.indexOf(lozengeDatum) {
                    let indexPath = NSIndexPath(forItem: idx, inSection: 0)
                    indexes.append(indexPath)
                }
            }
        } else {
            // if it's the single-selectet, the singleItemLabel has the data.
            if let text = singleItemText, idx = data.indexOf(text) {
                let indexPath = NSIndexPath(forItem: idx, inSection: 0)
                indexes.append(indexPath)
            }
        }
        return indexes
    }
    
    // MARK: - tap handlers
    
    // Ugh! - why can't these be private?  Evidently targets for tap handlers cannot be.
    func tappedForPopup(sender: AnyObject) {
        if !ready {
            return
        }
        if dropDownVisible {
            if let popTable = popTable {
                popTable.fadeOut()
            }
            dropDownVisible = false
        } else {
            initializePopup(data)
            dropDownVisible = true
        }
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
        tappedForPopup(sender)
    }
    
    func readjustHeight() {
        if isMultiple == false {
            // Don't grow the height for the single-selection case.
            return
        }
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
            if lozengeData.count == 0 {
                showPlaceholder(true)
            }
        }
    }

    // MARK: - BBPDropDownPopupDelegate
    func dropDownView(dropDownView: BBPDropDownPopup, didSelectedIndex idx: Int) {
        let itemData = data[idx]
        lozengeData.append(itemData)
        lozengeCollection.reloadData()
        singleItemText = itemData
        showPlaceholder(itemData == "")
        singleItemLabel.text = itemData
        if let delegate = delegate {
            delegate.dropDownView(self, didSelectedItem: itemData)
        }
    }

    func dropDownView(dropDownView: BBPDropDownPopup, dataList: [String]) {
        print("dropDownView:dataList: called")
        lozengeData = dataList
        lozengeCollection.reloadData()
        readjustHeight()
        let placeHolder = dataList.count == 0
        showPlaceholder(placeHolder)
        if let delegate = delegate {
            delegate.dropDownView(self, dataList:dataList)
        }
    }
}
