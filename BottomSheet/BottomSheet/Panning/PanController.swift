//
//  PanController.swift
//  BottomSheet
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

extension BottomSheetTransitionController {
  class PanController {
    // MARK: Transitioning
    
    weak var transitionController: BottomSheetTransitionController?
        
    var animatedInteractiveTransitionInProgress = false
    var oldTranslationOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    let rubicon: CGFloat = 0.5 // point of no return
    
    weak var dismissedViewController: UIViewController?
    
    func handle(pan: PanAxisGestureRecognizer, viewControllerToDismiss: UIViewController) {
      guard let transitionController = transitionController else {
        return
      }
      
      let height = viewControllerToDismiss.view.bounds.height
      dismissedViewController = viewControllerToDismiss
      let view = viewControllerToDismiss.view!
      
      guard height > 0 else {
        return
      }
      
      let translation = pan.translation(in: viewControllerToDismiss.view)
      let translationOffset: CGFloat = translation.y
      guard translationOffset > 0 else {
        return
      }
      
      let percent = abs(translationOffset / height)
      
      switch pan.state {
        case .began:
          oldTranslationOffset = 0
          transitionController.interactorHasStarted = true
          
        case .changed:
          calculateYOffsetFromInteractiveProgress(translationOffset, percent)
          
        case .ended, .cancelled:
          calculateYOffsetFromInteractiveProgress(translationOffset, percent)
          let velocity = pan.velocity(in: view).y
          oldTranslationOffset = 0
          startSnapAnimation(velocity: velocity, view: view)
          
        case .possible, .failed:
          break

        @unknown default:
          break
      }
    }
    
    private func startSnapAnimation(velocity: CGFloat, view: UIView) {
      let pageHeight: CGFloat = view.bounds.height
      let modulo = abs(yOffset.truncatingRemainder(dividingBy: pageHeight))
      yOffset = 0
      let finished = modulo > (pageHeight * rubicon)
      transitionController?.cleanupInteractor(finished: finished)
      animatedInteractiveTransitionInProgress = false
      
      if finished, let completion = transitionController?.completion {
        completion(.success(.dismissedByDraggingDown))
      }
    }
    
    private func calculateYOffsetFromInteractiveProgress(
        _ translationOffset: CGFloat,
        _ percent: CGFloat
    ) {
        let incrementalTransitionOffset: CGFloat = translationOffset - oldTranslationOffset
        oldTranslationOffset = translationOffset
        yOffset += incrementalTransitionOffset
        notifyOfPossibleTransition(percent: percent)
    }
    
    func notifyOfPossibleTransition(percent: CGFloat) {
      guard let controller = transitionController else {
        return
      }
      
      if controller.interactorHasStarted {
        controller.updateTransition(withPercent: percent)
      }

      guard !animatedInteractiveTransitionInProgress else {
        return
      }

      performTheOperation()
    }
    
    private func performTheOperation() {
      guard let dismissedViewController, let transitionController else {
          return
      }
      animatedInteractiveTransitionInProgress = true
        transitionController.heightForTranslation = dismissedViewController.view.bounds.height
        dismissedViewController.dismiss(animated: true)
    }
        
    func dismissedFromButton() {
      guard let transitionController else {
        return
      }

      transitionController.finishInteractor()
      transitionController.cleanupInteractor(finished: true)
    }
  }
}
