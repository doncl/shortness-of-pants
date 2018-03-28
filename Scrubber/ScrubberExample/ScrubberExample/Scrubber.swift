//
//  Scrubber.swift
//  ScrubberExample
//
//  Created by Don Clore on 3/25/18.
//  Copyright © 2018 Don Clore. All rights reserved.
//

import UIKit

class Scrubber: UIControl {
  private let width : CGFloat = 108.0
  private let height : CGFloat = 385.0
  private let bracketHeight : CGFloat = 31.0
  private let bracketBorderWidth : CGFloat = 1.0
  private let touchSlop : CGFloat = 10.0
  
  private let topBracket : CALayer = CALayer()
  private let topBracketBorder : CALayer = CALayer()
  
  private let bottomBracket : CALayer = CALayer()
  private let bottomBracketBorder : CALayer = CALayer()
  
  private let newest : CATextLayer = CATextLayer()
  private let oldest : CATextLayer = CATextLayer()
  private let textXOffset : CGFloat = 18.0
  private let textYOffset : CGFloat = 9.0
  private let textSize : CGFloat = 12.0
  private let trackX : CGFloat = 78.0
  private let trackY : CGFloat = 38.0
  private let trackWidth : CGFloat = 8.0
  private let trackDistanceFromBottom : CGFloat = 40.0
  private let trackRadii : CGSize = CGSize(width: 20.0, height: 20.0)
  private let thumbRadii : CGSize = CGSize(width: 30.0, height: 30.0)
  
  private let thumbBorderColor : CGColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1).cgColor
  private let thumbBorderWidth : CGFloat = 1.4
  
  private let bracketColor : CGColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1).cgColor
  private let bracketBorderColor : CGColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1).cgColor
  
  private let scrubberTrack : CAShapeLayer = CAShapeLayer()
  private let scrubberTrackColor : CGColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1).cgColor
 
  private let thumb : CAShapeLayer = CAShapeLayer()
  private let thumbBorder : CAShapeLayer = CAShapeLayer()
  private let thumbX : CGFloat = -5.0
  private let thumbWidth : CGFloat = 18.0
  private let thumbHeight : CGFloat = 34.0
  private var thumbYOrg : CGFloat = 0.0
  
  private let compactXForm : CGAffineTransform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
 
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
     }
  }
  
  private var thumbRect : CGRect {
    let r : CGRect = CGRect(x: trackRect.origin.x + thumbX , y: trackRect.origin.y + thumbY,
                            width: thumbWidth, height: thumbHeight)
    return r
  }
  
  private var initialThumbTouchY : CGFloat = 0.0
  private var inSlide : Bool = false
  
  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    bounds = CGRect(x: 0, y: 0, width: width, height: height)
    backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
    layer.backgroundColor = backgroundColor?.cgColor

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
    
    setupTextLayer(newest, text: "Newest", parentLayer: topBracket)
    setupTextLayer(oldest, text: "Oldest", parentLayer: bottomBracket)
    
    layer.addSublayer(scrubberTrack)
    let trackHeight = height - trackDistanceFromBottom - trackY
    trackRect = CGRect(x: trackX, y: trackY, width: trackWidth,
                                    height: trackHeight)
    
    
    let trackPath = UIBezierPath(roundedRect: trackRect,
                                 byRoundingCorners: UIRectCorner.allCorners,
                                 cornerRadii: trackRadii)
    
    maxY = trackHeight - thumbHeight
    scrubberTrack.path = trackPath.cgPath
    scrubberTrack.fillColor = scrubberTrackColor
    
    thumbYOrg = trackRect.origin.y
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
  
  override func layoutSubviews() {
    if traitCollection.verticalSizeClass == .compact {
      transform = compactXForm
    } else {
      transform = .identity
    }
    super.layoutSubviews()
  }
  
  fileprivate func drawThumbLayer() {
    scrubberTrack.addSublayer(thumb)
    thumb.masksToBounds = false

    let r = thumbRect
    
    let thumbPath = UIBezierPath(roundedRect: r, byRoundingCorners: UIRectCorner.allCorners,
                                 cornerRadii: thumbRadii)

    thumb.zPosition = 0.0
    thumb.strokeColor = thumbBorderColor
    thumb.lineWidth = thumbBorderWidth
    thumb.fillColor = UIColor.white.cgColor
    thumb.allowsEdgeAntialiasing = true
    thumb.path = thumbPath.cgPath
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let location = locationOfFirstTouch(inTouches: touches) else {
      return
    }
    if hitTest(location) {
      thumbYOrg = thumbY
      initialThumbTouchY = location.y
      inSlide = true
    }
  }
  
  private func hitTest(_ point : CGPoint) -> Bool {
    let r = thumbRect
    let twoXSlop = touchSlop * 2.0
    let slopRect : CGRect = CGRect(x: r.origin.x - touchSlop, y: r.origin.y - touchSlop,
                                   width: r.width + twoXSlop, height: r.height + twoXSlop)
    return slopRect.contains(point)
  }
  
  fileprivate func calculateNewThumbY(_ location: CGPoint) {
    let deltaY = location.y - initialThumbTouchY
    thumbY = thumbYOrg + deltaY
    setNeedsDisplay()
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    drawThumbLayer()
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
      thumbYOrg = 0.0
    }
    
    guard inSlide else {
      return
    }

    guard let location = locationOfFirstTouch(inTouches: touches) else {
     return
    }
    
    calculateNewThumbY(location)
  }
  
  private func locationOfFirstTouch(inTouches touches : Set<UITouch>) -> CGPoint? {
      
      guard let touch = touches.first else {
        return nil
      }
      return touch.location(in: touch.view)
  }
  
  private func setupTextLayer(_ textLayer: CATextLayer, text: String, parentLayer : CALayer) {
    parentLayer.addSublayer(textLayer)
    let attrsString = NSAttributedString(string: text, attributes: [
      NSAttributedStringKey.font : UIFont.systemFont(ofSize: textSize),
      NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.2941176471, green: 0.2941176471, blue: 0.2941176471, alpha: 1),
      NSAttributedStringKey.backgroundColor : UIColor.clear,
    ])

    textLayer.alignmentMode = kCAAlignmentCenter
    textLayer.string = attrsString
    textLayer.frame = parentLayer.bounds.offsetBy(dx: 0.0, dy: textYOffset)
    textLayer.contentsScale = UIScreen.main.scale
  }
}


































