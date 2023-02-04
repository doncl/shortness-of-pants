//
//  PresentAnimator.swift
//  BottomSheet
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

extension BottomSheetTransitionController {
  class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum Constants {
      static let transitionDuration: TimeInterval = 0.4
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      Constants.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      guard let toVC = transitionContext.viewController(
          forKey: UITransitionContextViewControllerKey.to) else {
          return
      }
      
      let container = transitionContext.containerView
      container.addSubview(toVC.view)
      let height = container.bounds.height
      toVC.view.transform = CGAffineTransform(translationX: 0, y: height)
      
      UIView.animate(withDuration: Constants.transitionDuration, delay: 0.0, options: [.curveEaseInOut], animations:{
          toVC.view.transform = CGAffineTransform.identity
      }, completion: { completed in
          transitionContext.completeTransition(completed)
      })
    }
  }
}
