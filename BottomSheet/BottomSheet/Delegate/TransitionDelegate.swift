//
//  BottomSheetTransitionDelegate.swift
//  BottomSheet
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

extension BottomSheetTransitionController {
  public class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    weak var transitionController: BottomSheetTransitionController?
    
    public func animationController(
      forPresented presented: UIViewController,
      presenting: UIViewController,
      source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
    
      transitionController?.presentAnimator
    }
    
    public func animationController(
      forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
      transitionController?.dismissAnimator
    }
    
    public func interactionControllerForDismissal(
      using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
      guard let controller = transitionController else {
        return nil
      }
      
      return controller.interactiveDismissal ? controller.interactor : nil
    }
    
    public func presentationController(
      forPresented presented: UIViewController,
      presenting: UIViewController?,
      source: UIViewController
    ) -> UIPresentationController? {
      return transitionController?.getPresentationController(presented: presented, presenting: presenting, source: source)
    }
  }  
}
