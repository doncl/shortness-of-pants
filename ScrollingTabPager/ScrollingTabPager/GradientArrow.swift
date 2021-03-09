//
//  GradientArrow.swift
//  ScrollingTabPager
//
//  Created by Don Clore on 3/8/21.
//
import UIKit

class GradientArrow: UIControl {
  let width: CGFloat = 50.0
  let height: CGFloat = 30.0
  let imageDim: CGFloat = 12.0
  let gradient: CAGradientLayer = CAGradientLayer()
  
  lazy var imageView: UIImageView = {
    let image: UIImage? = UIImage(named: "arrow")
    let img = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
    img.contentMode = UIView.ContentMode.scaleAspectFit
    img.backgroundColor = .clear
    img.translatesAutoresizingMaskIntoConstraints = false
    img.tintColor = arrowColor
    img.isUserInteractionEnabled = false
    return img
  }()
  
  var gradientColor: UIColor = UIColor.black {
    didSet {
      var r: CGFloat = 0
      var g: CGFloat = 0
      var b: CGFloat = 0
      var a: CGFloat = 0
      gradientColor.getRed(&r, green: &g, blue: &b, alpha: &a)
      let start: UIColor = UIColor(red: r, green: g, blue: b, alpha: 0)
      gradient.colors = [start.cgColor, gradientColor.cgColor]
      gradient.setNeedsDisplay()
    }
  }
  
  var arrowColor: UIColor = UIColor.white {
    didSet {
      imageView.tintColor = arrowColor
      imageView.backgroundColor = UIColor.clear
      imageView.setNeedsDisplay()
    }
  }
  
  init() {
    super.init(frame: .zero)
    
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: width),
      heightAnchor.constraint(equalToConstant: height)
      ])
    
    addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 8.0),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      imageView.heightAnchor.constraint(equalToConstant: imageDim),
      imageView.widthAnchor.constraint(equalToConstant: imageDim),
      ])
    
    backgroundColor = .clear
    gradient.colors = [UIColor.clear.cgColor, gradientColor.cgColor]
    gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    gradient.locations = [0.0, 0.5]
    
    layer.insertSublayer(gradient, at: 0)
    
    isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self, action: #selector(GradientArrow.touchUpInside(_:)))
    addGestureRecognizer(tap)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradient.frame = bounds
  }
}

extension GradientArrow {
  @objc func touchUpInside(_ sender: UITapGestureRecognizer) {
    sendActions(for: UIControl.Event.touchUpInside)
  }
}
