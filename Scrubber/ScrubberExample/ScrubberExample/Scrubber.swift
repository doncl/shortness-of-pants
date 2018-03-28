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
  private let thumbBorder : CAShapeLayer = CAShapeLayer()
  private let thumbX : CGFloat = -3.0
  private let thumbWidth : CGFloat = 12.0
  private let thumbHeight : CGFloat = 24.0
  private var thumbYOrg : CGFloat = 0.0
 
  var startIndex : Int = 1
  var endIndex : Int = 100
  var maxY : CGFloat = 0

  
  var trackRect : CGRect = .zero
  
  var thumbY : CGFloat = 0.0 {
    didSet (oldValue) {
      if thumbY > maxY {
        thumbY = maxY
      } else if thumbY < 0 {
        thumbY = 0
      }
      //print("newValue = \(thumbY)")
      let yOffset = thumbY - oldValue
      let newPosition = CGPoint(x: thumb.position.x, y: thumbY)
      thumb.position = newPosition
    }
  }
  
  private var initialThumbTouchY : CGFloat = 0.0
  private var inSlide : Bool = false
  
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
    trackRect = CGRect(x: trackX, y: trackY, width: trackWidth,
                                    height: height - trackDistanceFromBottom - trackY)
    
    
    let trackPath = UIBezierPath(roundedRect: trackRect, byRoundingCorners: UIRectCorner.allCorners,
                            cornerRadii: trackRadii)
    
    maxY = trackRect.maxY - (thumbHeight / 2.0)
    scrubberTrack.path = trackPath.cgPath
    scrubberTrack.fillColor = scrubberTrackColor
    
    scrubberTrack.addSublayer(thumb)
    thumb.masksToBounds = false
    
    let thumbRect = CGRect(x: trackRect.origin.x + thumbX , y: trackRect.origin.y,
                           width: thumbWidth, height: thumbHeight)
    
    thumbYOrg = thumbRect.origin.y
    
    let thumbPath = UIBezierPath(roundedRect: thumbRect,
                                 byRoundingCorners: UIRectCorner.allCorners,
                                 cornerRadii: thumbRadii)
    
    thumb.zPosition = 0.0
    thumb.strokeColor = thumbBorderColor
    thumb.lineWidth = thumbBorderWidth
    thumb.fillColor = UIColor.white.cgColor
    thumb.path = thumbPath.cgPath
    isUserInteractionEnabled = true
    isMultipleTouchEnabled = false
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var intrinsicContentSize: CGSize {
    get {
      return CGSize(width: width, height: height)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let location = locationOfFirstTouch(inTouches: touches) else {
      return
    }
    if hitTest(location) {
      initialThumbTouchY = location.y
      inSlide = true
      print("inSlide = true")
    }
  }
  
  private func hitTest(_ point : CGPoint) -> Bool {
    guard let path = thumb.path else {
      return false
    }
    let adjustedRect = path.boundingBoxOfPath.offsetBy(dx: 0.0, dy: thumb.position.y)
    let ret = adjustedRect.contains(point)
    print("hitTest returns \(ret)")
    return ret
  }
  
  fileprivate func calculateNewThumbY(_ location: CGPoint) {
    let deltaY = location.y - initialThumbTouchY
//    print("deltaY = \(deltaY)")
    thumbY = thumbYOrg + deltaY
  }
  
  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard inSlide else {
      return
    }
    guard let location = locationOfFirstTouch(inTouches: touches) else {
      return
    }
    calculateNewThumbY(location)
  }
  
  
  
  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    defer {
      initialThumbTouchY = 0.0
      inSlide = false
    }
    
    guard inSlide else {
      return
    }

    guard let location = locationOfFirstTouch(inTouches: touches) else {
      print("touchesEnded - couldn't get location")
      return
    }
    
    print("location = \(location.y)")
    calculateNewThumbY(location)
  }
  
  private func locationOfFirstTouch(inTouches touches : Set<UITouch>) -> CGPoint? {
      
      guard let touch = touches.first else {
        return nil
      }
      return touch.location(in: touch.view)
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
