//
//  BottomSheetDismissAnimator.swift
//  BottomSheet
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

extension BottomSheetTransitionController {
  class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum Constants {
      static let transitionDuration: TimeInterval = 0.6
    }
    
    weak var storedPresentationController: PresentationController?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      Constants.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      guard let fromVC = transitionContext.viewController(
          forKey: UITransitionContextViewControllerKey.from),
            
              let toVC = transitionContext.viewController(
                  forKey: UITransitionContextViewControllerKey.to)
      else {
          return
      }
      
      let container = transitionContext.containerView
      let transitionHeight = container.bounds.height
              
      UIView.animate(
          withDuration: transitionDuration(using: transitionContext),
          animations: { [weak self] in
              guard let self = self else { return } // very unlikely, but...
              
              fromVC.view.alpha = 0.3
              toVC.view.alpha = 1.0
              fromVC.view.transform = CGAffineTransform(translationX: 0, y: transitionHeight)
              self.storedPresentationController?.dimmingView.alpha = 0
      }, completion: { _ in
          let finished = !transitionContext.transitionWasCancelled
          if finished {
              transitionContext.finishInteractiveTransition()
          } else {
              transitionContext.cancelInteractiveTransition()
          }
          transitionContext.completeTransition(finished)
      })
    }
  }
}
