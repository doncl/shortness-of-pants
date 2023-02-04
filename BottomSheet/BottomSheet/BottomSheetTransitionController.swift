//
//  BottomSheetTransitionController.swift
//  BottomSheet
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

public class BottomSheetTransitionController {
  enum DlgResponse {
      case dismissedByDraggingDown
      case touchedCancelButton
      case touchedOkButton
  }
  
  var interactiveDismissal: Bool = true
  
  var completion: ((Result<DlgResponse, Error>) -> Void)?
  
  var interactorHasStarted: Bool {
    get {
      return interactor.hasStarted
    }
    
    set {
      interactor.hasStarted = newValue
    }
  }
  
  var heightForTranslation: CGFloat {
    get {
      interactor.heightForTranslation
    }
    
    set {
      interactor.heightForTranslation = newValue
    }
  }
  
  public lazy var transitionDelegate: TransitionDelegate = {
    let delegate = TransitionDelegate()
    delegate.transitionController = self
    return delegate
  }()
  
  lazy var presentAnimator: PresentAnimator = {
    let animator: PresentAnimator = PresentAnimator()
    return animator
  }()
  
  lazy var dismissAnimator: DismissAnimator = {
    let animator: DismissAnimator = DismissAnimator()
    return animator
  }()
  
  lazy var interactor: DismissInteractor = {
    let interactor: DismissInteractor = DismissInteractor()
    return interactor
  }()
  
  lazy var panHandler: PanController = {
    let pan: PanController = PanController()
    pan.transitionController = self
    return pan 
  }()
  
  var bottomSheetHeight: CGFloat {
    set {
      presentationController?.dialogHeight = newValue
    }
    
    get {
      return presentationController?.dialogHeight ?? 0
    }
  }
  
  weak var presentationController: PresentationController?
  
  public init() {}
  
  func updateTransition(withPercent percent: CGFloat) {
    interactor.updateTransition(withPercent: percent)
  }
    
  func cleanupInteractor(finished: Bool) {
    interactor.cleanup(finished: finished)
  }
  
  func finishInteractor() {
    interactor.finish()
  }
    
  func getPresentationController(presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController {
    let presentationController = PresentationController(
        presentedViewController: presented,
        presenting: presenting
    )
    
    interactor.storedPresentationController = presentationController
    dismissAnimator.storedPresentationController = presentationController
    
    self.presentationController = presentationController

    return presentationController
  }
  
  public func handlePan(_ sender: PanAxisGestureRecognizer, viewController: UIViewController) {
    panHandler.handle(pan: sender, viewControllerToDismiss: viewController)
  }
  
  public func dismissedFromButton(vc: UIViewController) {
    interactiveDismissal = false
    vc.dismiss(animated: true)
    panHandler.dismissedFromButton()
    guard let completion else {
      return
    }
    completion(.success(DlgResponse.touchedOkButton))
  }
}
