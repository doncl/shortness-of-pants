//
//  BaseModalPopup.swift
//  BaseModalPopup
//
//  Created by Don Clore on 5/21/18.
//  Copyright © 2018 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

enum PointerDirection {
  case up
  case down
}

enum AvatarMode {
  case leftTopLargeProtruding
  case leftTopMediumInterior
}

fileprivate struct AvatarLayoutInfo {
  var width : CGFloat
  var offset : CGFloat
  var constraintsMaker : (UIImageView, UIView, CGFloat, CGFloat) -> ()
  
  func layout(avatar : UIImageView, popup : UIView) {
    constraintsMaker(avatar, popup, width, offset)
  }
}

class BaseModalPopup: UIViewController {
  var loaded : Bool = false
  var presenting : Bool = true
  static let pointerHeight : CGFloat = 16.0
  static let pointerBaseWidth : CGFloat = 24.0
  static let horzFudge : CGFloat = 15.0
  var origin : CGPoint
  weak var referenceView : UIView?
  private var width : CGFloat
  private var height : CGFloat
  
  let popupView : UIView = UIView()
  let avatar : UIImageView = UIImageView()
  let pointer : CAShapeLayer = CAShapeLayer()
  
  var avatarMode : AvatarMode?
  var avatarUserId : String?
  var avatarImage : UIImage?
  
  var avatarOffset : CGFloat {
    var offset : CGFloat = 0
    if let avatarMode = avatarMode, let layoutInfo = avatarModeSizeMap[avatarMode] {
      offset = layoutInfo.offset
    }
    return offset
  }
  
  private let avatarModeSizeMap : [AvatarMode : AvatarLayoutInfo] = [
    .leftTopLargeProtruding : AvatarLayoutInfo(width: 48.0, offset: 16.0,
                                               constraintsMaker: { (avatar, popup, width, offset) in

      avatar.snp.remakeConstraints { make in
        make.width.equalTo(width)
        make.height.equalTo(width)
        make.left.equalTo(popup.snp.left).offset(offset)
        make.top.equalTo(popup.snp.top).offset(-offset)
      }
    }),
    .leftTopMediumInterior : AvatarLayoutInfo(width: 32.0, offset: 16.0,
                                              constraintsMaker: { (avatar, popup, width, offset) in
                                                
      avatar.snp.remakeConstraints { make in
        make.width.equalTo(width)
        make.height.equalTo(width)
        make.left.equalTo(popup.snp.left).offset(offset)
        make.top.equalTo(popup.snp.top).offset(offset)
      }
    })
  ]
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(origin : CGPoint, referenceView : UIView, size: CGSize, avatarUserId: String? = nil,
       avatarImage : UIImage?, avatarMode : AvatarMode?) {
    
    self.origin = origin
    self.width = size.width
    self.height = size.height
    self.referenceView = referenceView
    super.init(nibName: nil, bundle: nil)
    self.avatarMode = avatarMode
    self.avatarUserId = avatarUserId
    if let image = avatarImage {
      self.avatarImage = image.deepCopy()
    }
  }
  
  override func viewDidLoad() {
    if loaded {
      return
    }
    loaded = true
    super.viewDidLoad()
    
    if let ref = referenceView {
      origin = view.convert(origin, from: ref)
    }
    
    view.addSubview(popupView)
    view.backgroundColor = .clear
    popupView.backgroundColor = .white
    popupView.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
    popupView.layer.shadowRadius = 5.0
    popupView.layer.shadowOpacity = 0.5
    
    popupView.addSubview(avatar)
    popupView.clipsToBounds = false
    popupView.layer.masksToBounds = false
    
    if let userId = avatarUserId,
      let avatarMode = avatarMode,
      let layoutInfo = avatarModeSizeMap[avatarMode] {
      
      if let image = avatarImage {
        avatar.image = image.deepCopy()
        avatar.createRoundedImageView(diameter: layoutInfo.width, borderColor: UIColor.clear)
      } else {
        avatar.setAvatarImage(fromId: userId, avatarVersion: nil, diameter: layoutInfo.width,
                              bustCache: false, placeHolderImageURL: nil, useImageProxy: true,
                              completion: nil)
      }
      popupView.bringSubview(toFront: avatar)
    }
    view.isUserInteractionEnabled = true
    let tap = UITapGestureRecognizer(target: self,
                                     action: #selector(BaseModalPopup.tap))
    
    view.addGestureRecognizer(tap)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let tuple = getPopupFrameAndPointerDirection(size: view.frame.size)
    let popupFrame = tuple.0
    let direction = tuple.1
    
    let pointerPath = makePointerPath(direction: direction, popupFrame: popupFrame)
    pointer.path = pointerPath.cgPath
    pointer.fillColor = UIColor.white.cgColor
    pointer.lineWidth = 0.5
    pointer.masksToBounds = false
    popupView.layer.addSublayer(pointer)
    
    remakeConstraints(popupFrame)
    
    let bounds = UIScreen.main.bounds
    let width = view.frame.width + avatarOffset
    
    if bounds.width < width && width > 0 {
      let ratio = (bounds.width / width) * 0.9
      let xform = CGAffineTransform(scaleX: ratio, y: ratio)
      popupView.transform = xform
    } else {
      popupView.transform = .identity
    }
  }
  
  private func getPopupFrameAndPointerDirection(size: CGSize) -> (CGRect, PointerDirection) {
    let y : CGFloat
    let direction : PointerDirection
    if origin.y > size.height / 2 {
      y = origin.y - (height + BaseModalPopup.pointerHeight)
      direction = .down
    } else {
      y = origin.y + BaseModalPopup.pointerHeight
      direction = .up
    }
    var rc : CGRect = CGRect(x: 30.0, y: y, width: width, height: height)
    let rightmost = rc.origin.x + rc.width
    let center = rc.center
    if origin.x > rightmost {
      let offset = origin.x - center.x
      rc = rc.offsetBy(dx: offset, dy: 0)
    } else if origin.x < rc.origin.x {
      let offset = center.x - origin.x
      rc = rc.offsetBy(dx: -offset, dy: 0)
    }
    let bounds = UIScreen.main.bounds
    let popupWidth = rc.width + avatarOffset
    if bounds.width <= popupWidth {
      rc = CGRect(x: 0, y: rc.origin.y, width: rc.width,
                  height: rc.height)
    }
    return (rc, direction)
  }
  
  fileprivate func remakeConstraints(_ popupFrame: CGRect) {
    popupView.snp.remakeConstraints { make in
      make.leading.equalTo(view).offset(popupFrame.origin.x)
      make.top.equalTo(view).offset(popupFrame.origin.y)
      make.width.equalTo(popupFrame.width)
      make.height.equalTo(popupFrame.height)
    }
    
    if let _ = avatar.image,
      let avatarMode = avatarMode,
      let layoutInfo = avatarModeSizeMap[avatarMode] {
      
      layoutInfo.layout(avatar: avatar, popup: popupView)
    }
  }
  
  private func makePointerPath(direction: PointerDirection, popupFrame : CGRect) -> UIBezierPath {
    let path = UIBezierPath()
    path.lineJoinStyle = CGLineJoin.bevel
    
    // previous code is supposed to assure that the popupFrame is not outside the origin.
    assert(popupFrame.origin.x < origin.x && popupFrame.origin.x + popupFrame.width > origin.x)
    
    let adjustedX = origin.x - popupFrame.origin.x
    
    if direction == .down {
      let adjustedApex = CGPoint(x: adjustedX, y: popupFrame.height + BaseModalPopup.pointerHeight - 1)
      path.move(to: adjustedApex)
      // down is up.
      let leftBase = CGPoint(x: adjustedApex.x - (BaseModalPopup.pointerBaseWidth / 2),
                             y: adjustedApex.y - BaseModalPopup.pointerHeight)
      path.addLine(to: leftBase)
      let rightBase = CGPoint(x: adjustedApex.x + (BaseModalPopup.pointerBaseWidth / 2),
                              y: adjustedApex.y - BaseModalPopup.pointerHeight)
      
      path.addLine(to: rightBase)
      path.close()
    } else {
      let adjustedApex = CGPoint(x: adjustedX,
                                 y: -BaseModalPopup.pointerHeight + 1)
      path.move(to: adjustedApex)
      
      let leftBase = CGPoint(x: adjustedApex.x - (BaseModalPopup.pointerBaseWidth / 2),
                             y: adjustedApex.y + BaseModalPopup.pointerHeight)
      path.addLine(to: leftBase)
      
      let rightBase = CGPoint(x: adjustedApex.x + (BaseModalPopup.pointerBaseWidth / 2),
                              y: adjustedApex.y + BaseModalPopup.pointerHeight)
      path.addLine(to: rightBase)
      path.close()
    }
    
    return path
  }
  
  
  @objc func tap() {
    dismiss(animated: true, completion: nil)
  }
}

//MARK: - rotation
extension BaseModalPopup {
  override func willTransition(to newCollection: UITraitCollection,
                               with coordinator: UIViewControllerTransitionCoordinator) {
    
    dismiss(animated: true, completion: nil)
  }
  
  
  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    
    dismiss(animated: true, completion: nil)
  }
}

