//
//  BBPDropDown.swift
//  BBPDropDown
//
//  Created by Don Clore on 3/5/16.
//  Copyright © 2016 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

protocol BBPDropDownPopupDelegate {
    func dropDownView(dropDownView: BBPDropDownPopup, didSelectedIndex idx:Int);
    func dropDownView(dropDownView: BBPDropDownPopup, dataList: [String]);
}

struct Constants {
    static let screenInset : CGFloat = 0
    static let headerHeight : CGFloat = 50.0
    static let radius : CGFloat = 5.0
    static let rowHeight: CGFloat = 44.0
    static let cellId : String = "DropDownViewCell"
    static let buttonHeight: CGFloat = 31.0
    static let buttonWidth: CGFloat = 82.0
}

@IBDesignable class BBPDropDownPopup: UIView, UITableViewDataSource, UITableViewDelegate {
    // MARK: - IBInspectable properties.
    @IBInspectable var titleText: NSString?
    @IBInspectable var dropDownOption : [String]?
    @IBInspectable var shadowOffsetWidth : CGFloat = 2.5
    @IBInspectable var shadowOffsetHeight : CGFloat = 2.5
    @IBInspectable var shadowRadius : CGFloat = 2.5
    @IBInspectable var shadowOpacity: Float = 0.5
    @IBInspectable var separatorColor = UIColor(white: 1.0, alpha: 0.2)
    @IBInspectable var popupBackgroundColor : UIColor = UIColor.clearColor()
    @IBInspectable var isMultipleSelection : Bool = false

    var tableView : UITableView?
    private var selectedItems = [NSIndexPath]()

    var delegate : BBPDropDownPopupDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(title: String, options:[String], xy point: CGPoint, size: CGSize,
            isMultiple: Bool) {
                
        let height = min(size.height, Constants.headerHeight + (CGFloat(options.count) *
            Constants.rowHeight))
                
        let rect = CGRect(x:point.x, y: point.y, width: size.width, height: height)
        self.init(frame:rect)
        isMultipleSelection = isMultiple

        backgroundColor = UIColor.clearColor()
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        
        titleText = title
        dropDownOption = options
        let tableFrame = CGRect(x: Constants.screenInset,
            y: Constants.screenInset + Constants.headerHeight,
            width: rect.size.width - (2 * Constants.screenInset),
            height: rect.size.height - (2 * Constants.screenInset) -
                Constants.headerHeight - Constants.radius)
        
        tableView = UITableView(frame: tableFrame)
        tableView!.allowsSelection = true
        tableView!.userInteractionEnabled = true
        tableView!.separatorColor = separatorColor
        tableView!.separatorInset = UIEdgeInsetsZero
        tableView!.backgroundColor = UIColor.clearColor()
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.registerNib(UINib(nibName: "BBPDropDownCell", bundle: nil),
                    forCellReuseIdentifier: Constants.cellId)
               
        addSubview(tableView!)
        
        if isMultipleSelection {
            let btnDone = UIButton(type: .Custom)

            let btnFrame = CGRect(x: size.width - Constants.buttonWidth - 8,
                    y:(Constants.headerHeight / 2) - (Constants.buttonHeight / 2),
                    width:Constants.buttonWidth, height:Constants.buttonHeight)

            btnDone.frame = btnFrame
            btnDone.setImage(UIImage(named: "done@2x.png"), forState: .Normal)
            btnDone.addTarget(self, action: "clickDone", forControlEvents: .TouchUpInside)
            addSubview(btnDone)
        }
    }
    
    // MARK: - Action targets
    
    func clickDone() {
        print("clickDone called")
        if let delegate = delegate {
            var responseData = [String]()
            for indexPath in selectedItems {
                responseData.append((dropDownOption?[indexPath.row])!)
            }
            delegate.dropDownView(self, dataList: responseData)
        }
        fadeOut()
    }

    private func fadeIn() {
        transform = CGAffineTransformMakeScale(1.3, 1.3)
        alpha = 0.0
        UIView.animateWithDuration(0.35, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransformIdentity
        })
    }
    
    func fadeOut() {
        UIView.animateWithDuration(0.35, animations: {
            self.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.alpha = 0.0
            }, completion: {(BOOL finished) in
                if finished {
                    self.removeFromSuperview()
                }
            })
    }
    
    // MARK: - Instance methods
    func showInView(view: UIView, animated: Bool) {
        view.addSubview(self)
        if animated {
            fadeIn()
        }
    }

    // MARK: - UITableView delegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dropDownOption?.count)!
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
                    -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellId) as?
                       BBPDropDownCell
        let row = indexPath.row
        cell!.tag = row

        if selectedItems.contains(indexPath) {
            cell!.showSelectionMark(true)
        } else {
            cell!.showSelectionMark(false)
        }
        cell?.textLabel!.text = dropDownOption![row]
                        
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated:true)

        if isMultipleSelection {
            if selectedItems.contains(indexPath) {
                if let idx = selectedItems.indexOf(indexPath) {
                    selectedItems.removeAtIndex(idx)
                }
            } else {
                selectedItems.append(indexPath)
            }
            tableView.reloadData()
        } else {
            if let delegate = delegate {
                delegate.dropDownView(self, didSelectedIndex: indexPath.row)
            }
            fadeOut()
        }
    }
    
    // MARK: - Drawing
    override func drawRect(rect: CGRect) {
        
        let screenInset = Constants.screenInset
        let headerHeight = Constants.headerHeight
        let radius = Constants.radius
        
        let bgRect = CGRectInset(rect, screenInset, screenInset)
        let titleRect = CGRect(x: screenInset + 10.0, y:screenInset + 10.0 + 5.0,
            width: rect.size.width - (2 * (screenInset + 10)), height: 30.0)
        let separatorRect = CGRect(x: screenInset, y: screenInset + headerHeight - 2,
            width: rect.size.width - 2.0, height: 2.0)
        
        let ctx = UIGraphicsGetCurrentContext()
        popupBackgroundColor.setFill()
        
        let x = screenInset
        let y = screenInset
        let cx = bgRect.size.width
        let cy = bgRect.size.height
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, x, y + radius)
        CGPathAddArcToPoint(path, nil, x, y, x + radius, y, radius)
        CGPathAddArcToPoint(path, nil, x + cx, y, x + cx, y + radius, radius)
        CGPathAddArcToPoint(path, nil, x + cx, y + cy, x + cx - radius, y + cy, radius)
        CGPathAddArcToPoint(path, nil, x, y + cy, x, y + cy - radius, radius)
        CGPathCloseSubpath(path)
        CGContextAddPath(ctx, path)
        CGContextFillPath(ctx)

        // Title and separator shadow
        CGContextSetShadowWithColor(ctx, CGSize(width: 1.0, height: 1.0), 0.5,
            UIColor.blackColor().CGColor)
        
        UIColor(white: 1.0, alpha: 1.0).setFill()
        
        let font = UIFont(name: "HelveticaNeue", size: 16.0)!
        let cl = UIColor.whiteColor()
        
        let attrs : [String :AnyObject] = [NSFontAttributeName : font,
            NSForegroundColorAttributeName: cl]
        
        titleText?.drawInRect(titleRect, withAttributes: attrs)
        
        CGContextFillRect(ctx, separatorRect)
    }
}





























