//
//  BBPDropdown.swift
//  BBPDropDown
//
//  Created by Don Clore on 3/6/16.
//  Copyright © 2016 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

protocol BBPDropDownDelegate {
    func requestNewHeight(_ dropDown:BBPDropdown, newHeight: CGFloat)
    func dropDownView(_ dropDown: BBPDropdown, didSelectedItem item:String)
    func dropDownView(_ dropDown: BBPDropdown, dataList: [String])
    func dropDownWillAppear(_ dropDown: BBPDropdown)
}

@IBDesignable class BBPDropdown: UIView, UICollectionViewDelegate, UICollectionViewDataSource,
        LozengeCellDelegate, BBPDropDownPopupDelegate {

    // MARK: - private constants
    fileprivate let cellId = "LozengeCell"
    fileprivate let vertMargin : CGFloat = 8.0

    // MARK: - private properties
    fileprivate var lozengeData: [String] = [String]()

    fileprivate var popTable: BBPDropDownPopup?
    fileprivate var view: UIView!  // Our custom view from the Xib file.
    fileprivate var rightGutterTapRecognizer : UITapGestureRecognizer?
    fileprivate var collectionViewTapRecognizer: UITapGestureRecognizer?
    fileprivate var backgroundViewTapRecognizer: UITapGestureRecognizer?
    fileprivate var labelTapRecognizer: UITapGestureRecognizer?
    fileprivate var dropDownVisible : Bool = false
    fileprivate var ready : Bool = false

    fileprivate func showPlaceholder(_ show: Bool) {
        placeHolderLabel.alpha =  show ? 1.0 : 0.0
        placeHolderLabel.isHidden = !show

        showSingleItemLabel(!isMultiple && !show)
        showLozengeCollection(isMultiple && !show)
    }

    fileprivate func showSingleItemLabel(_ show: Bool) {
        singleItemLabel.alpha = show ? 1.0 : 0.0
        singleItemLabel.isHidden = !show
    }

    fileprivate func showLozengeCollection(_ show: Bool) {
        lozengeCollection.alpha = show ? 1.0 : 0.0
        lozengeCollection.isHidden = !show
    }

    // MARK: - IBOutlets
    @IBOutlet var lozengeCollection: UICollectionView!
    @IBOutlet var rightGutter: UIView!
    @IBOutlet var singleItemLabel: UILabel!
    @IBOutlet var placeHolderLabel: UILabel!

    // MARK: - public non-inspectable properties
    var data : [String] = [] {
        willSet (newValue) {
            ready = true
        }
    }

    var selections : [String] {
        get {
            return lozengeData
        }
        set (newValue){
            lozengeData = newValue
            lozengeCollection.reloadData()

            // Hide the placeholder if there's data, show it if not.
            showPlaceholder(newValue.count == 0)
            readjustHeight()
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
    @IBInspectable var borderColor : UIColor = UIColor.lightGray
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
    @IBInspectable var popTextColor : UIColor = UIColor.black
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
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Adding custom subview on top of our view
        addSubview(view)
    }
    
    func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName:"BBPDropDown", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options:nil)[0] as! UIView
        return view
    }

    func commonInitStuff() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: cellId, bundle:bundle)
        lozengeCollection.register(nib, forCellWithReuseIdentifier: cellId)
        lozengeCollection.dataSource = self
        lozengeCollection.delegate = self
        lozengeCollection.reloadData()
        layer.borderColor = borderColor.cgColor
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

    func setUIStateForSelectionMode(_ multiSelect: Bool) {
        lozengeCollection.alpha = multiSelect ? 1.0 : 0.0
        singleItemLabel.alpha = multiSelect ? 0.0 : 1.0
    }

    fileprivate func setupTapRecog() -> UITapGestureRecognizer {
        let recog = UITapGestureRecognizer()
        recog.numberOfTouchesRequired = 1
        recog.numberOfTapsRequired  = 1
        recog.isEnabled = true
        recog.addTarget(self, action: #selector(BBPDropdown.tappedForPopup(_:)))
        return recog;
    }

    func fadeOut() {
        if let popTable = popTable {
            popTable.fadeOut()
        }
    }

    func initializePopup(_ options: [String]) {
        resignFirstResponder()
        fadeOut()
        if let delegate = delegate {
            delegate.dropDownWillAppear(self)
        }

        var xy = CGPoint(x: 0, y: frame.size.height)
        xy = convert(xy, to: superview)

        let indexes = getIndexesForSelectedItems()
        
        // TODO:  This initializer is kind of...not ideal.  Just set the properties.
        popTable = BBPDropDownPopup(title: popTitle, options:options,
                xy: xy,
            size:CGSize(width: frame.size.width, height: 280), isMultiple: isMultiple,
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

    func getIndexesForSelectedItems() -> [IndexPath] {
        var indexes = [IndexPath]()
        if isMultiple {
            // If it's the mult-select case, grovel through the lozengeData
            for selection in lozengeData {
                if let idx = data.index(of: selection) {
                    let indexPath = IndexPath(item: idx, section: 0)
                    indexes.append(indexPath)
                }
            }
        } else {
            // if it's the single-selectet, the singleItemLabel has the data.
            if let text = singleItemText, let idx = data.index(of: text) {
                let indexPath = IndexPath(item: idx, section: 0)
                indexes.append(indexPath)
            }
        }
        return indexes
    }
    
    // MARK: - tap handlers
    
    // Ugh! - why can't these be private?  Evidently targets for tap handlers cannot be.
    func tappedForPopup(_ sender: AnyObject) {
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
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return lozengeData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt
        indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId,
            for: indexPath) as? LozengeCell

        cell!.lozengeText.text = lozengeData[indexPath.row]
        if let lozengeBackgroundColor = lozengeBackgroundColor,
            let lozengeTextColor = lozengeTextColor {
            cell!.backgroundColor = lozengeBackgroundColor
            cell!.lozengeText.textColor = lozengeTextColor
        }
        cell!.delegate = self
        cell!.setupDeleteTap()
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying
        cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        readjustHeight()
    }


    // MARK: - IBActions
    @IBAction func dropDownButtonTouched(_ sender: AnyObject) {
        tappedForPopup(sender)
    }
    
    func readjustHeight() {
        if isMultiple == false {
            // Don't grow the height for the single-selection case.
            return
        }
        let size = lozengeCollection.collectionViewLayout.collectionViewContentSize
        let height = size.height + (vertMargin * 2)
        if let flowLayout = lozengeCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            let minHeight = flowLayout.itemSize.height + (vertMargin * 2)
            if let delegate = delegate {
                delegate.requestNewHeight(self, newHeight: max(minHeight, height))
            }
        }
    }
    
    // MARK: - LozengeCellDelegate
    func deleteTapped(_ cell: LozengeCell) {
        if let path = lozengeCollection.indexPath(for: cell) {
            lozengeData.remove(at: path.row)
            lozengeCollection.deleteItems(at: [path])
            if lozengeData.count == 0 {
                showPlaceholder(true)
            }
        }
    }

    // MARK: - BBPDropDownPopupDelegate
    func dropDownView(_ dropDownView: BBPDropDownPopup, didSelectedIndex idx: Int) {
        let itemData = data[idx]
        lozengeData.append(itemData)
        lozengeCollection.reloadData()
        singleItemText = itemData
        showPlaceholder(itemData == "")
        if let delegate = delegate {
            delegate.dropDownView(self, didSelectedItem: itemData)
        }
    }

    func dropDownView(_ dropDownView: BBPDropDownPopup, dataList: [String]) {
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
