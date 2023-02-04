//
//  BottomSheetPresentationController.swift
//  BottomSheet
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

extension BottomSheetTransitionController {
  class PresentationController: UIPresentationController {
    enum Constants {
      static let dimmingAlpha: CGFloat = 0.8
      static let defaultDialogHeight: CGFloat = 400
    }

    var dimmingView = UIView()
    var dialogHeight: CGFloat = Constants.defaultDialogHeight
    
    override var frameOfPresentedViewInContainerView: CGRect {
      guard let containerView = containerView else {
        return CGRect.zero
      }
      var frame = CGRect.zero
      frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView.bounds.size)

      let x = dimmingView.bounds.midX - frame.size.width / 2
      let y = (containerView.bounds.height - frame.height)

      frame.origin.x = x
      frame.origin.y = y
      return frame
    }
    
    override init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        
        setupDimmingView()
    }

    override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
      let r: CGRect = presentingViewController.view.bounds
      let width = r.width
      return CGSize(width: width, height: dialogHeight)
    }
    
    override func presentationTransitionWillBegin() {
      guard let containerView else {
        return
      }

      containerView.insertSubview(dimmingView, at: 0)
      
      dimmingView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
        dimmingView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
        dimmingView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
        dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      ])

      guard let coordinator = presentedViewController.transitionCoordinator else {
        dimmingView.alpha = Constants.dimmingAlpha
        return
      }

      coordinator.animate(alongsideTransition: { _ in
        self.dimmingView.alpha = Constants.dimmingAlpha
      })
    }
    
    func adjustDimmingAlpha(_ percent: CGFloat) {
      let percentRemaining = 1.0 - percent
      let desiredAlpha = percentRemaining * Constants.dimmingAlpha
      dimmingView.alpha = desiredAlpha
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
      adjustDimmingAlpha(completed ? 1 : 0)
      if completed {
        dimmingView.removeFromSuperview()
      }
    }

    override func containerViewWillLayoutSubviews() {
      presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    private func setupDimmingView() {
      dimmingView.backgroundColor = .black
      dimmingView.alpha = 0.0
    }
  }
}
