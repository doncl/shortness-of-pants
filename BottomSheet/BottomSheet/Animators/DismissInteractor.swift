//
//  DismissInteractor.swift
//  BottomSheet
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

extension BottomSheetTransitionController {
  class DismissInteractor: UIPercentDrivenInteractiveTransition {
    weak var storedContext: UIViewControllerContextTransitioning?
    weak var storedPresentationController: PresentationController?
    
    var hasStarted: Bool = false
    var heightForTranslation: CGFloat = 0
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
      storedContext = transitionContext
      hasStarted = true

      guard let from = transitionContext.view(forKey: .from) else {
        return
      }

      let containerView = transitionContext.containerView
      containerView.addSubview(from)
      let r = CGRect(
        x: 0,
        y: containerView.bounds.height - heightForTranslation,
        width: containerView.bounds.width,
        height: heightForTranslation
      )
      
      from.frame = r
      containerView.bringSubviewToFront(from)
      from.transform = .identity
    }
    
    func updateTransition(withPercent percent: CGFloat) {
      update(percent)
      
      guard let ctxt = storedContext, hasStarted, heightForTranslation > 0 else {
        return
      }
      
      if let storedPresentationController {
        storedPresentationController.adjustDimmingAlpha(percent)
      }
        
      ctxt.updateInteractiveTransition(percent)
        
      guard let from = ctxt.view(forKey: .from) else {
        return
      }
        
      let yOffset: CGFloat = percent * heightForTranslation
      let xform = CGAffineTransform(translationX: 0, y: yOffset)
      from.transform = xform
    }
    
    func cleanup(finished: Bool) {
      if let ctxt = storedContext {
        if let to = ctxt.view(forKey: .to) {
          to.transform = .identity
        }
        if let from = ctxt.view(forKey: .from) {
          from.transform = .identity
        }
        if finished {
          ctxt.finishInteractiveTransition()
          ctxt.completeTransition(true)
          finish()
        } else {
          ctxt.cancelInteractiveTransition()
          ctxt.completeTransition(false)
          cancel()
        }
      }
      storedContext = nil
    }
  }
}
