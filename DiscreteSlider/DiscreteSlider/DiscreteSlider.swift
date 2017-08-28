//
//  DiscreteSlider.swift
//  DiscreteSlider
//
//  Created by Don Clore on 7/30/17.
//  Copyright © 2017 Don Clore. All rights reserved.
//

import UIKit

public class DiscreteSlider : UIControl {
  //MARK: Constants
  struct Constants {
    static let sliderHeight : CGFloat = 40.0
    static let vertPad : CGFloat = 7.0
    static let horzPad : CGFloat = 3.0
  }

  let trackHeight : CGFloat = 2.0
  let ballRadius : CGFloat = 6.0
  
  let selectorRadius : CGFloat = 14.0
  let shadowRadius : CGFloat = 4.0
  let shadowOffset : CGSize = CGSize(width: 0.0, height: 3.0)
  
  fileprivate var touchOffsetX : CGFloat = 0.0
  
  fileprivate let selector : CALayer = CALayer()
  fileprivate let trackLine : CALayer = CALayer()
  fileprivate let maxLine : CALayer = CALayer()
  fileprivate let minLine : CALayer = CALayer()
  
  fileprivate var trackRect : CGRect = CGRect.zero
  
  fileprivate var thumbX : CGFloat = 0.0 {
    didSet {
      let maxX = trackRect.maxX - (selectorRadius * 2)
      if thumbX > maxX {
        thumbX = maxX
      }
    }
  }
  
  var maximumTrackTintColor : UIColor = UIColor.darkGray
  var minimumTrackTintColor : UIColor = UIColor.lightGray
  
  var minimumValue : CGFloat = 0.0
  var maximumValue : CGFloat = CGFloat.greatestFiniteMagnitude

  
  //MARK: Private properties
  @available(iOS 10.0, *)
  private var haptic : UINotificationFeedbackGenerator {
    get {
      let gen = UINotificationFeedbackGenerator()
      gen.prepare()
      return gen
    }
  }

  private var textHeight : CGFloat = 0.0
  
  @IBInspectable public var doHaptic : Bool = true
  
  public var values : [String] = [] {
    didSet {
      self.invalidateIntrinsicContentSize()
    }
  }
  
  public var discreteValue : Int = 0 {
    didSet {
      if discreteValue != oldValue {
        sendActions(for: .valueChanged)
        
        if doHaptic {
          if #available(iOS 10.0, *) {
            let hap = haptic
            hap.notificationOccurred(.success)
          }
        }
      }
    }
  }
  
  var ballRects : [CGRect] = []
  var maxTextWidthAllowed : CGFloat = 0.0
  
  convenience init() {
    self.init(frame: CGRect.zero)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initPhase2()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initPhase2()
  }
  
  fileprivate func initPhase2() {
    backgroundColor = .white
    layer.addSublayer(trackLine)
    trackLine.masksToBounds = true
    trackLine.backgroundColor = UIColor.clear.cgColor
    
    trackLine.addSublayer(maxLine)
    trackLine.addSublayer(minLine)
    maxLine.backgroundColor  = maximumTrackTintColor.cgColor
    minLine.backgroundColor = minimumTrackTintColor.cgColor
    layer.addSublayer(selector)
    
    isMultipleTouchEnabled = false
    layoutTrackLine()
    
    guard let font = getFont(bold: true) else {
      return
    }
    
    let nsString = NSString(string: "text String")
    let textSize = nsString.size(attributes: [NSFontAttributeName : font])
    textHeight = textSize.height
  }
  
  override public var intrinsicContentSize: CGSize {
    var height = selectorSize.height + (Constants.vertPad * 2)
    height += textHeight + Constants.vertPad
    
    guard let font = getFont(bold: true) else {
      return CGSize(width: 100.0, height: height)
    }
    
    var width : CGFloat = 0
    for text in values {
      let nsText = NSString(string: text)
      let textRect = nsText.size(attributes: [NSFontAttributeName : font])
      width += textRect.width + Constants.horzPad
    }
    return CGSize(width: width, height: height)
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    layoutTrackLine()
    calculateLittleBallRects()
    recalculateThumbX()
    setNeedsDisplay()
  }
  
  fileprivate func recalculateThumbX() {
    guard trackRect.width > 0, values.count > 1 else {
      return
    }
  
    thumbX = trackRect.width / CGFloat(values.count - 1) * CGFloat(discreteValue)
  }
  
  fileprivate func layoutTrackLine() {
    let trackSize : CGSize = CGSize(width: frame.width, height: trackHeight)
    
    trackRect = CGRect(x: 0, y: (frame.height - trackSize.height) / 2,
      width: trackSize.width, height: trackSize.height)
    
    setNeedsDisplay()
  }
  
  fileprivate func calculateLittleBallRects() {
    ballRects.removeAll()
    let width : CGFloat = bounds.width
    let extra = ceil(bounds.height / 2.0)
    let y = bounds.origin.y + extra
    let cx = width / CGFloat(values.count - 1)
    maxTextWidthAllowed = cx
    
    for i in 0..<self.values.count {
      let px : CGFloat = CGFloat(i) * cx + self.ballRadius
      let center : CGPoint = CGPoint(x: px, y: y)
      var rect = CGRect(x: center.x - self.ballRadius,
        y: center.y - self.ballRadius, width: self.ballRadius * 2.0,
        height: self.ballRadius * 2.0)
      
      if i == self.values.count - 1 {
        let rectOriginX = rect.origin.x
        let newRectOriginX = self.bounds.width - (self.ballRadius * 2)
        let offsetX = newRectOriginX - rectOriginX
        rect = rect.offsetBy(dx: offsetX, dy: 0.0)
      }
      
      ballRects.append(rect)
    }
  }
  
  override public func touchesBegan(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    
    guard let location = locationOfFirstTouch(inTouches: touches) else {
      return
    }
    let thumbcenter = thumbX + ballRadius
    touchOffsetX = location.x - thumbcenter
  }
  
  override public func touchesMoved(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    
    guard let location = locationOfFirstTouch(inTouches: touches) else {
      return
    }
    
    let desiredX = desiredThumbX(touchX: location.x)
    moveThumbTo(x: desiredX, animationDuration: 0.0)
  }
  
  override public func touchesEnded(_ touches: Set<UITouch>,
    with event: UIEvent?) {
    
    guard let location = locationOfFirstTouch(inTouches: touches) else {
      return
    }
    
    let desiredX = desiredThumbX(touchX: location.x)
    moveThumbTo(x: desiredX, animationDuration: 0.0, discrete: true)
    touchOffsetX = 0.0
  }
  
  fileprivate func desiredThumbX(touchX : CGFloat) -> CGFloat {
    return touchX - touchOffsetX
  }
  
  fileprivate func locationOfFirstTouch(inTouches touches : Set<UITouch>)
    -> CGPoint? {
      
    guard let touch = touches.first else {
      return nil
    }
    return touch.location(in: touch.view)
  }
  
  fileprivate func showDiscretion(value : CGFloat) -> Int {
    guard values.count > 1, value >= 0.0, trackRect.width > 0 else {
      return 0
    }
    
    let scaledToValueSetValue = value / trackRect.width *
      CGFloat(values.count - 1)
    
    var intValue = Int(scaledToValueSetValue)
    if scaledToValueSetValue - CGFloat(intValue) > 0.5 {
      intValue += 1
    }
    return intValue
  }

  
  override public func draw(_ rect: CGRect) {
    super.draw(rect)
    
    drawTrackLine()
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    
    let currentThumbCenter = thumbX + selectorRadius
    
    for i in 0..<ballRects.count {
      let ballRect = ballRects[i]
      context.saveGState()
      let ball = UIBezierPath(ovalIn: ballRect)
      // The zeroth ball is always painted the max color
      if ballRect.origin.x < currentThumbCenter  || i == 0 {
        maximumTrackTintColor.setFill()
        ball.fill()
      } else {
        minimumTrackTintColor.setFill()
        ball.fill()
      }
      context.restoreGState()
    }
    
    drawThumb()
    drawLabels()
  }
  
  fileprivate func drawLabels() {
    let tuple = getTextRectFontsAndCollisionInfo()
    let textRectFonts = tuple.0
    let collision = tuple.1
    let endCollision = tuple.2
    
    if collision {
      assert(values.count > 1, "Logic Error - can't have collection with less than two values")
      
      guard let boldFont = getFont(bold: true) else {
        return
      }
      paintText(text: values[0], textRectFont: textRectFonts[0])
      let last = values.count - 1
      
      if discreteValue == last {
        paintText(text: values[last], textRectFont: textRectFonts[last],
          font: boldFont)
      } else {
        if false == endCollision {
          paintText(text: values[discreteValue],
            textRectFont: textRectFonts[discreteValue], font: boldFont)
        }
        paintText(text: values[last], textRectFont: textRectFonts[last])
      }
    } else {
      for i in 0..<values.count {
        let text = values[i]
        let nsText = NSString(string: text)
        let trf = textRectFonts[i]
        nsText.draw(in: trf.rect, withAttributes: [NSFontAttributeName : trf.font])
      }
    }
  }
  
  fileprivate func drawTrackLine() {
    trackLine.frame = trackRect
    trackLine.cornerRadius = trackRect.height / 2.0
    
    maxLine.frame = {
      var frame = trackLine.bounds
      frame.size.width = thumbX - trackRect.minX
      return frame
    }()
    
    maxLine.backgroundColor = maximumTrackTintColor.cgColor
    
    minLine.frame = {
      var frame = trackLine.bounds
      frame.size.width = trackRect.width - maxLine.frame.width
      frame.origin.x = maxLine.frame.maxX
      return frame
    }()
    
    minLine.backgroundColor = minimumTrackTintColor.cgColor
  }
  
  var selectorSize : CGSize {
    let dim = selectorRadius * 2.0 + shadowRadius * 2.0 + shadowOffset.width * 2
    return CGSize(width: dim, height: dim)
  }
  
  fileprivate func drawThumb() {
      let dim = selectorSize.width
      let rectangle = CGRect(x:thumbX, y: (frame.height - dim)/2, width: dim,
        height: dim)
      
      var selectorFrame = rectangle.insetBy(dx: shadowRadius + shadowOffset.width,
        dy: shadowRadius + shadowOffset.width)
      
      selectorFrame.origin.x = thumbX
      
      selector.frame = selectorFrame
      
      selector.backgroundColor = UIColor.white.cgColor
      
      let strokeColor = UIColor(red: 197.0 / 255.0, green: 197.0 / 255.0,
        blue: 197.0 / 255.0, alpha: 1.0)
      
      selector.borderColor = strokeColor.cgColor
      selector.borderWidth = 0.05
      selector.cornerRadius = selector.frame.width / 2.0
      selector.allowsEdgeAntialiasing = true
      
      // Shadow
      selector.shadowOffset = shadowOffset
      
      selector.shadowRadius = shadowRadius
      let shadowColor = UIColor(red: 197.0 / 255.0, green: 197.0 / 255.0,
        blue: 197.0 / 255.0, alpha: 1.0)
      selector.shadowColor = shadowColor.cgColor
      selector.shadowOpacity = 1.0
   }
  
  func moveThumbTo(x:CGFloat, animationDuration duration:TimeInterval,
    discrete : Bool = false) {
    
    let leftMost = CGFloat(0.0)
    let rightMost = frame.maxX
    
    let newDiscreteValue = showDiscretion(value: x)

    thumbX = max(leftMost, min(x, rightMost))
    
    if newDiscreteValue != discreteValue {
      discreteValue = newDiscreteValue
    }
    
    if discrete {
      assert(ballRects.count > newDiscreteValue)
      let newThumbCenterX = ballRects[discreteValue].midX
      thumbX = newThumbCenterX - selectorRadius
    }
   
    
    CATransaction.setAnimationDuration(duration)
    
    setNeedsDisplay()
  }
  
  fileprivate func paintText(text : String, textRectFont trf : TextRectFont, font: UIFont? = nil) {
    let nsText = NSString(string: text)
    var fontToDraw : UIFont
    if let font = font {
      fontToDraw = font
    } else {
      fontToDraw = trf.font
    }
    
    let rect = trf.rect
    nsText.draw(in: rect, withAttributes: [NSFontAttributeName : fontToDraw])
  }
  
  fileprivate struct TextRectFont {
    var rect : CGRect
    var font : UIFont
  }
  
  fileprivate func getTextRectFontsAndCollisionInfo() -> ([TextRectFont], Bool, Bool) {
    var collision : Bool = false
    var endCollision : Bool = false
    var rectFonts : [TextRectFont] = []
    
    let count = ballRects.count
    
    let sliderBottom = selectorSize.height + (Constants.vertPad * 2)
    
    for i in 0..<count {
      let ballRect = ballRects[i]
      let text = values[i]
      let nsText = NSString(string: text)
      
      let bold = i == discreteValue
      guard let font = getFont(bold: bold) else {
        continue
      }
      
      let textSize = nsText.size(attributes: [NSFontAttributeName : font])
      
      var x : CGFloat = ballRect.midX - textSize.width / 2
      if i == 0 {
        x = 0
      } else if i == ballRects.count - 1 {
        x = bounds.width - textSize.width
      }
      
      let textRect = CGRect(x: x,
        y: sliderBottom + Constants.vertPad, width: textSize.width,
        height: textSize.height)
      
      if i > 0 {
        // pad things out a bit, and check for collision.
        let prevRect = rectFonts[i - 1].rect.insetBy(dx: -Constants.horzPad, dy: 0.0)
        let curRect = textRect.insetBy(dx: -Constants.horzPad, dy: 0.0)
        
        if prevRect.intersects(curRect) {
          collision = true
          if i == count - 1 || i == 1{
            endCollision = true
          }
        }
      }
      
      let trf = TextRectFont(rect: textRect, font: font)
      rectFonts.append(trf)
    }
    return (rectFonts, collision, endCollision)
  }
}

fileprivate func getFont(bold: Bool) -> UIFont? {
  if false == bold {
    return UIFont.systemFont(ofSize: 12.0)
  }
  return UIFont.boldSystemFont(ofSize: 12.0)
}

