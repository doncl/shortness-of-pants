//
//  DiscreteSlider.swift
//  Disco
//
//  Created by Don Clore on 7/18/17.
//  Copyright © 2017 Don Clore. All rights reserved.
//

import UIKit

enum DiscreteSliderType : String {
  case continuous = "continuous"
  case stepped = "stepped"
}

@IBDesignable class DiscreteSlider: UIControl {
  //MARK: Constants
  struct Constants {
    static let sliderHeight : CGFloat = 20.0
    static let vertPad : CGFloat = 7.0
    static let horzPad : CGFloat = 3.0
    static let sliderHorzInsets : CGFloat = 10.0
    static let horzFudge : CGFloat = 7.0
  }
  
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
  
  private let nameLabel : UILabel = {
    let l = UILabel()
    l.font = getAdaptiveFont(bold: true)
    l.textAlignment = .left
    
    return l
  }()
  
  //MARK: Inspectable and public non-inspectable properties
  @IBInspectable var name : String = "SliderName" {
    didSet {
      nameLabel.text = name
    }
  }
  
  @IBInspectable var doHaptic : Bool = true
  
  @IBInspectable var slider : MySlider = MySlider()
  
  var type : DiscreteSliderType = .continuous
  
  @available(*, unavailable, message: "This property is reserved for Interface Builder")
  @IBInspectable var sliderType : String? {
    willSet {
      if let newType = DiscreteSliderType(rawValue: newValue?.lowercased() ?? "") {
        type = newType
      }
    }
  }
  
  // Arrays can't be IBInspectable, dang.
  var values : [String] = [] {
    didSet {
      let count = values.count
      slider.minimumValue = 0.0
      slider.maximumValue = Float(count - 1)
      invalidateIntrinsicContentSize()
      slider.values = values
    }
  }
  
  var value : Int = 0 {
    didSet {
      guard value < values.count && value >= 0 && values.count > 0 else {
        return
      }
      slider.value = Float(value)
      slider.discreteValue = value
      slider.setNeedsDisplay()
      setNeedsDisplay()
    }
  }
  
  var valueString : String? {
    guard values.count > 0 else {
      return nil
    }
    assert(value < values.count && values.count >= 0, "ummm, nope")
    return values[value]
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initPhase2()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initPhase2()
  }
  
  private func initPhase2() {
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    slider.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(nameLabel)
    addSubview(slider)
    
    guard let font = getAdaptiveFont(bold: true) else {
      return
    }
    
    let nsString = NSString(string: "text string")
    let textSize = nsString.size(attributes: [NSFontAttributeName : font])
    textHeight = textSize.height
    
    NSLayoutConstraint.activate([
      nameLabel.topAnchor.constraint(equalTo: topAnchor),
      nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      
      slider.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.vertPad),
      slider.leadingAnchor.constraint(equalTo: leadingAnchor),
      slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.sliderHorzInsets),
      slider.heightAnchor.constraint(equalToConstant: Constants.sliderHeight),
      ])
    
    slider.addTarget(self, action: #selector(DiscreteSlider.sliderTouchedUpInside(_:)),
                     for: .touchUpInside)
    
    slider.addTarget(self, action: #selector(DiscreteSlider.sliderValueChanged(_:)),
                     for: .valueChanged)
  }
  
  override var intrinsicContentSize: CGSize {
    var height =  nameLabel.intrinsicContentSize.height + Constants.vertPad
    height += slider.intrinsicContentSize.height
    height += textHeight
    
    guard let font = getAdaptiveFont(bold: true) else {
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
  
  @objc fileprivate func sliderTouchedUpInside(_ sender: UISlider) {
    guard type == .continuous else {
      return
    }
    makeSliderValueDiscrete()
  }
  
  @objc fileprivate func sliderValueChanged(_ sender: UISlider) {
    guard type == .stepped else {
      return
    }
    makeSliderValueDiscrete()
  }
  
  
  fileprivate func makeSliderValueDiscrete() {
    let floatValue = slider.value
    let discreteValue = showDiscretion(value: floatValue)
    let newValue = Int(discreteValue)
    let valueChanged = newValue != value
    value = newValue
    
    if valueChanged {
      sendActions(for: .valueChanged)
      
      if doHaptic {
        if #available(iOS 10.0, *) {
          let hap = haptic
          hap.notificationOccurred(.success)
        }
      }
    }
  }
  
  fileprivate func showDiscretion(value : Float) -> Int {
    guard values.count > 0 else {
      return 0
    }
    
    var intValue = Int(value)
    if value - Float(intValue) > 0.5 {
      intValue += 1
    }
    return intValue
  }
}

extension DiscreteSlider {
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let tuple = getTextRectFontsAndCollisionInfo()
    let textRectFonts = tuple.0
    let collision = tuple.1
    let endCollision = tuple.2
    
    if collision {
      assert(values.count > 1, "Logic Error - can't have collection with less than two values")
      
      guard let boldFont = getAdaptiveFont(bold: true) else {
        return
      }
      paintText(text: values[0], textRectFont: textRectFonts[0])
      let last = values.count - 1
      
      if value == last {
        paintText(text: values[last], textRectFont: textRectFonts[last], font: boldFont)
      } else {
        if false == endCollision {
          paintText(text: values[value], textRectFont: textRectFonts[value], font: boldFont)
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
    
    let ballRects = slider.ballRects
    let count = ballRects.count
    
    let sliderBottom = slider.frame.origin.y + slider.frame.height
    
    for i in 0..<count {
      let ballRect = ballRects[i]
      let text = values[i]
      let nsText = NSString(string: text)
      
      let bold = i == value
      guard let font = getAdaptiveFont(bold: bold) else {
        continue
      }
      
      let textSize = nsText.size(attributes: [NSFontAttributeName : font])
      
      var x : CGFloat = ballRect.center.x - textSize.width / 2
      if i == 0 {
        x = 0
      } else if i == ballRects.count - 1 {
        x = bounds.width - textSize.width
      }
      
      let textRect = CGRect(x: x,
                            y: sliderBottom + Constants.vertPad, width: textSize.width,
                            height: textSize.height)
      
      if i > 0 {
        // pad things out a bit, and chec for collision.
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setNeedsDisplay()
    slider.setNeedsDisplay()
  }
}

class MySlider : UISlider {
  let ballRadius : CGFloat = 6.0
  let horzFudge : CGFloat = 4.0
  
  var maxBallColor : UIColor = UIColor.lightGray
  let minBallColor : UIColor = UIColor.darkGray
  
  var values : [String] = [] {
    didSet {
      self.invalidateIntrinsicContentSize()
    }
  }
  var discreteValue : Int = 0
  var ballRects : [CGRect] = []
  var maxTextWidthAllowed : CGFloat = 0.0
  
  override func layoutSubviews() {
    super.layoutSubviews()
    ballRects.removeAll()
    let width : CGFloat = bounds.width
    let extra = ceil(bounds.height / 2.0)
    let y = bounds.origin.y + extra
    let cx = width / CGFloat(values.count - 1)
    maxTextWidthAllowed = cx
    
    let halfway = values.count / 2
    let even = values.count % 2 == 0
    
    // Do the fudgy thing.   In a perfect world, I'd figure out what exact
    // curve Apple is using to fudge the visual values of the 'ball' on the
    // slider, and match that here.   This linear fudging seems close enough to
    // get the labels and little balls and the big balls to pretty much look
    // like they match up on the line. I judge that, if more precision is
    // is needed, it'd be easier to just ditch the UISlider altogether, and
    // just draw it all myself.   It's just a BezierPath with some shading,
    // and a straight line.
    for i in 0..<self.values.count {
      var px : CGFloat = CGFloat(i) * cx + self.ballRadius
      if i < halfway && i > 0 {
        px += horzFudge
      } else if i >= halfway && i < values.count - 1{
        if i != halfway || even {
          px -= horzFudge
        }
      }
      
      let center : CGPoint = CGPoint(x: px, y: y)
      var rect = CGRect(x: center.x - self.ballRadius,
                        y: center.y - self.ballRadius, width: self.ballRadius * 2.0,
                        height: self.ballRadius * 2.0)
      
      if i == self.discreteValue {
        ballRects.append(rect)
        continue
      }
      
      if i == self.values.count - 1 {
        let rectOriginX = rect.origin.x
        let newRectOriginX = self.bounds.width - (self.ballRadius * 2)
        let offsetX = newRectOriginX - rectOriginX
        rect = rect.offsetBy(dx: offsetX, dy: 0.0)
      }
      
      ballRects.append(rect)
    }
  }
  
  override func draw(_ rect: CGRect) {
    maximumTrackTintColor = maxBallColor
    minimumTrackTintColor = minBallColor
    
    super.draw(rect)
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    
    for i in 0..<ballRects.count {
      if i == discreteValue {
        continue
      }
      let ballRect = ballRects[i]
      context.saveGState()
      let ball = UIBezierPath(ovalIn: ballRect)
      if i < discreteValue {
        minBallColor.setFill()
        ball.fill()
      } else {
        maxBallColor.setFill()
        ball.fill()
      }
      context.restoreGState()
    }
    
  }
}

// This is just a placeholder for whatever you need to do, Aarti.
fileprivate func getAdaptiveFont(bold: Bool) -> UIFont? {
  if false == bold {
    return UIFont.systemFont(ofSize: 12.0)
  }
  return UIFont.boldSystemFont(ofSize: 12.0)
}

