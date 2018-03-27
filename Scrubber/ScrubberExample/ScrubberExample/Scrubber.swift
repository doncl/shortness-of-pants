//
//  Scrubber.swift
//  ScrubberExample
//
//  Created by Don Clore on 3/25/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

import UIKit

class Scrubber: UIControl {
  private let width : CGFloat = 77.0
  private let height : CGFloat = 275.0
  private let bracketHeight : CGFloat = 22.0
  private let bracketBorderWidth : CGFloat = 1.0
  
  private let topBracket : CALayer = CALayer()
  private let topBracketBorder : CALayer = CALayer()
  
  private let bottomBracket : CALayer = CALayer()
  private let bottomBracketBorder : CALayer = CALayer()
  
  private let newest : UILabel = UILabel()
  private let oldest : UILabel = UILabel()
  private let textXOffset : CGFloat = 18.0
  private let textYOffset : CGFloat = 4.0
  private let textSize : CGFloat = 12.0
  private let trackX : CGFloat = 59.0
  private let trackY : CGFloat = 28.0
  private let trackWidth : CGFloat = 6.0
  private let trackDistanceFromBottom : CGFloat = 30.0
  private let trackRadii : CGSize = CGSize(width: 20.0, height: 20.0)
  private let thumbRadii : CGSize = CGSize(width: 30.0, height: 30.0)
  
  private let thumbBorderColor : CGColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1).cgColor
  private let thumbBorderWidth : CGFloat = 1.0
  
  private let bracketColor : CGColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1).cgColor
  private let bracketBorderColor : CGColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1).cgColor
  
  private let scrubberTrack : CAShapeLayer = CAShapeLayer()
  private let scrubberTrackColor : CGColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1).cgColor
 
  private let thumb : CAShapeLayer = CAShapeLayer()
  private let thumbX : CGFloat = -3.0
  private let thumbWidth : CGFloat = 12.0
  private let thumbHeight : CGFloat = 24.0

 
  var startIndex : Int = 1
  var endIndex : Int = 100
  
  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    bounds = CGRect(x: 0, y: 0, width: width, height: height)
    layer.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1).cgColor
    
    layer.shadowColor = UIColor.darkGray.cgColor
    layer.shadowOpacity = 0.4
    layer.shadowOffset = CGSize(width: -3.0, height: -3.0)
    layer.shadowRadius = 6.0

    layer.addSublayer(topBracket)
    topBracket.frame = CGRect(x: 0, y: 0, width: width, height: bracketHeight)
    topBracket.backgroundColor = bracketColor
    
    layer.addSublayer(topBracketBorder)
    topBracketBorder.frame = CGRect(x: 0, y: bracketHeight, width: width,
                                    height: bracketBorderWidth)
  
    topBracketBorder.backgroundColor = bracketBorderColor

    layer.addSublayer(bottomBracket)
    bottomBracket.frame = CGRect(x: 0, y: height - bracketHeight, width: width,
                                 height: bracketHeight)
    bottomBracket.backgroundColor = bracketColor
    
    layer.addSublayer(bottomBracketBorder)
    bottomBracketBorder.frame = CGRect(x: 0, y: height - bracketHeight, width: width,
                                       height: bracketBorderWidth)
    bottomBracketBorder.backgroundColor = bracketBorderColor
    
    setupTextLabel(newest, text: "Newest", parentRect: topBracket.frame)
    setupTextLabel(oldest, text: "Oldest", parentRect: bottomBracket.frame)
    
    layer.addSublayer(scrubberTrack)
    let trackRect : CGRect = CGRect(x: trackX, y: trackY, width: trackWidth,
                                    height: height - trackDistanceFromBottom - trackY)
    
    
    let trackPath = UIBezierPath(roundedRect: trackRect, byRoundingCorners: UIRectCorner.allCorners,
                            cornerRadii: trackRadii)
    
    
    scrubberTrack.path = trackPath.cgPath
    scrubberTrack.fillColor = scrubberTrackColor
    
    scrubberTrack.addSublayer(thumb)
    thumb.masksToBounds = false
    
    let thumbRect : CGRect = CGRect(x: trackRect.origin.x + thumbX , y: trackRect.origin.y,
                                    width: thumbWidth, height: thumbHeight)
    
    let thumbPath = UIBezierPath(roundedRect: thumbRect,
                                 byRoundingCorners: UIRectCorner.allCorners,
                                 cornerRadii: thumbRadii)
    
    thumb.borderColor = thumbBorderColor
    thumb.fillColor = UIColor.white.cgColor
    thumb.borderWidth = thumbBorderWidth
    thumb.path = thumbPath.cgPath
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var intrinsicContentSize: CGSize {
    get {
      return CGSize(width: width, height: height)
    }
  }
  
  private func setupTextLabel(_ label: UILabel, text: String, parentRect : CGRect) {
    
    addSubview(label)
    
    label.text = text
    label.font = UIFont.systemFont(ofSize: textSize)
    label.textColor = #colorLiteral(red: 0.2941176471, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
    label.textAlignment = .center
    label.backgroundColor = .clear
    
    label.frame = parentRect
  }
}
