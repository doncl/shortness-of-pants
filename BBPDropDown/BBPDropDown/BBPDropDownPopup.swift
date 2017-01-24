//
//  BBPDropDown.swift
//  BBPDropDown
//
//  Created by Don Clore on 3/5/16.
//  Copyright © 2016 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit
import QuartzCore

protocol BBPDropDownPopupDelegate {
    func dropDownView(_ dropDownView: BBPDropDownPopup, didSelectedIndex idx:Int);
    func dropDownView(_ dropDownView: BBPDropDownPopup, dataList: [String]);
}

class BBPDropDownPopup: UIView, UITableViewDataSource, UITableViewDelegate {
    // MARK: - public properties.
    var titleText: NSString?
    var dropDownOption : [String]?
    var shadowOffsetWidth : CGFloat = 2.5
    var shadowOffsetHeight : CGFloat = 2.5
    var shadowRadius : CGFloat = 2.5
    var shadowOpacity: Float = 0.5
    var separatorColor = UIColor(white: 1.0, alpha: 0.2)
    var popupBackgroundColor : UIColor = UIColor.clear
    var popupTextColor : UIColor = UIColor.black
    var isMultipleSelection : Bool = false
    var delegate : BBPDropDownPopupDelegate?
    var selectedItems = [IndexPath]()
    var cellSelectionImage : UIImage?
    var showsHeader : Bool = true
    var headerTextColor : UIColor = UIColor.white

    // MARK: - private properties
    fileprivate var tableView : UITableView?

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(title: String, options:[String], xy point: CGPoint, size: CGSize,
            isMultiple: Bool, showsHeader: Bool) {

        let headerHeight = showsHeader ? Constants.popupHeaderHeight : 0.0
        let height = min(size.height, headerHeight + (CGFloat(options.count) *
            Constants.popupRowHeight))

        let rect = CGRect(x:point.x, y: point.y, width: size.width, height: height)
        self.init(frame:rect)
        self.showsHeader = showsHeader

        isMultipleSelection = isMultiple

        backgroundColor = UIColor.clear
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        
        titleText = title as NSString?
        dropDownOption = options
        let tableFrame = CGRect(x: Constants.popupScreenInset,
            y: Constants.popupScreenInset + headerHeight,
            width: rect.size.width - (2 * Constants.popupScreenInset),
            height: rect.size.height - (2 * Constants.popupScreenInset) -
                headerHeight - Constants.popupRadius)
        
        tableView = UITableView(frame: tableFrame)
        tableView!.allowsSelection = true
        tableView!.isUserInteractionEnabled = true
        tableView!.separatorColor = separatorColor
        tableView!.separatorInset = UIEdgeInsets.zero
        tableView!.backgroundColor = UIColor.clear
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.register(UINib(nibName: "BBPDropDownCell", bundle: nil),
                    forCellReuseIdentifier: Constants.popupCellId)
               
        addSubview(tableView!)
        
        if isMultipleSelection {
            let btnDone = UIButton(type: .custom)
            

            let btnFrame = CGRect(x: size.width - Constants.popupButtonWidth - 8,
                    y:(Constants.popupHeaderHeight / 2) - (Constants.popupButtonHeight / 2),
                    width:Constants.popupButtonWidth, height:Constants.popupButtonHeight)

            btnDone.frame = btnFrame
            //btnDone.setImage(UIImage(named: "done@2x.png"), forState: .Normal)
            btnDone.layer.cornerRadius = 10.0
            btnDone .backgroundColor = UIColor(red: 116.0 / 255.0, green: 116.0 / 255.0, blue: 116.0 / 255.0, alpha: 0.7)
            btnDone.setTitle("Done", for:UIControlState())
            btnDone.titleLabel!.textColor = UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
            btnDone.addTarget(self, action: #selector(BBPDropDownPopup.clickDone), for: .touchUpInside)
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

    fileprivate func fadeIn() {
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        alpha = 0.0
        UIView.animate(withDuration: 0.35, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
        })
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.35, animations: {
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.alpha = 0.0
            }, completion: {(finished) in
                if finished {
                    self.removeFromSuperview()
                }
            })
    }
    
    // MARK: - Instance methods
    func showInView(_ view: UIView, animated: Bool) {
        view.addSubview(self)
        if animated {
            fadeIn()
        }
    }

    // MARK: - UITableView delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dropDownOption?.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
                    -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.popupCellId) as?
                       BBPDropDownCell
        let row = indexPath.row
        cell!.tag = row

        if selectedItems.contains(indexPath) {
            cell!.showSelectionMark(true)
        } else {
            cell!.showSelectionMark(false)
        }
        cell?.textLabel!.text = dropDownOption![row]
        cell?.textLabel!.textColor = popupTextColor
        if let image = cellSelectionImage {
            cell?.selectionImage = image
        }
                        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isMultipleSelection {
            if selectedItems.contains(indexPath) {
                if let idx = selectedItems.index(of: indexPath) {
                    selectedItems.remove(at: idx)
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
    override func draw(_ rect: CGRect) {
        
        let screenInset = Constants.popupScreenInset
        let headerHeight = showsHeader ? Constants.popupHeaderHeight : 0.0
        let radius = Constants.popupRadius
        
        let bgRect = rect.insetBy(dx: screenInset, dy: screenInset)
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
        
        let path = CGMutablePath()
      
        path.move(to: CGPoint(x: x, y: y + radius))
      
        path.addArc(tangent1End: CGPoint(x: x, y: y), tangent2End: CGPoint(x: x + radius, y: y),
          radius: radius)
      
        path.addArc(tangent1End: CGPoint(x: x + cx, y: y),
         tangent2End: CGPoint(x:x + cx, y: y + radius), radius: radius)
      
        path.addArc(tangent1End: CGPoint(x: x + cx ,y: y + cy),
          tangent2End: CGPoint(x: x + cx - radius, y: y + cy), radius: radius)
      
        path.addArc(tangent1End: CGPoint(x:x, y: y + cy), tangent2End: CGPoint(x: x, y: y + cy),
         radius: radius)
      
        path.closeSubpath()
        ctx!.addPath(path)
        ctx!.fillPath()

        if showsHeader {
            // Title and separator shadow
            ctx!.setShadow(offset: CGSize(width: 1.0, height: 1.0), blur: 0.5,
                    color: UIColor.black.cgColor)

            UIColor(white: 1.0, alpha: 1.0).setFill()

            let font = UIFont(name: "HelveticaNeue", size: 16.0)!

            let attrs : [String :AnyObject] = [NSFontAttributeName : font,
                                               NSForegroundColorAttributeName: headerTextColor]

            titleText?.draw(in: titleRect, withAttributes: attrs)

            ctx!.fill(separatorRect)
        }
    }
}





























