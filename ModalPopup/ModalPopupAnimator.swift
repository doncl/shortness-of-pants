//
//  ModalPopupAnimator.swift
//
//  Created by Don Clore on 5/28/18.
//  Copyright © 2018 Beer Barrel Poker Studios. All rights reserved.
//

import Foundation

class ModalPopupAnimator : NSObject, UIViewControllerAnimatedTransitioning {
  var presenting : Bool = true
  let duration : TimeInterval = 0.400
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
    -> TimeInterval {
      return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    
    let transitionView : UIView
    if presenting {
      transitionView = transitionContext.view(forKey: .to)!
    } else {
      transitionView = transitionContext.view(forKey: .from)!
    }
    
    let xScaleFactor : CGFloat = 0.01
    let yScaleFactor : CGFloat = 0.01
    
    let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
    
    if presenting {
      transitionView.transform = scaleTransform
      transitionView.clipsToBounds = true
    } else {
      transitionView.transform = .identity
    }
    
    containerView.addSubview(transitionView)
    containerView.bringSubview(toFront: transitionView)
    
    UIView.animate(withDuration: duration, delay:0.0, options: [.curveEaseInOut], animations: {
      transitionView.transform = self.presenting ?
        CGAffineTransform.identity : scaleTransform
    }, completion:{_ in
      transitionContext.completeTransition(true)
    })
  }
}

