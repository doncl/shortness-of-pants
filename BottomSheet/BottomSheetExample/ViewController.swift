//
//  ViewController.swift
//  BottomSheetExample
//
//  Created by Don Clore on 2/4/23.
//

import UIKit
import BottomSheet

class ViewController: UIViewController {
  lazy var presentBtn: UIButton = {
    let b: UIButton = UIButton(type: UIButton.ButtonType.custom)
    b.backgroundColor = UIColor.blue
    b.setTitleColor(UIColor.white, for: UIControl.State.normal)
    b.setTitle("Present!", for: UIControl.State.normal)
    b.layer.cornerRadius = BottomSheetVC.Constants.btnCornerRadius
    return b
  }()
  
  lazy var transitionController: BottomSheetTransitionController = {
    let controller = BottomSheetTransitionController()
    return controller
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    [presentBtn,].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }
    
    NSLayoutConstraint.activate([
      presentBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      presentBtn.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      presentBtn.widthAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnWidth),
      presentBtn.heightAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnHeight),
    ])
    
    presentBtn.addTarget(self, action: #selector(ViewController.presentBtnPressed(_:)), for: UIControl.Event.touchUpInside)
  }
  
  @objc func presentBtnPressed(_ sender: UIButton) {
    let vc: BottomSheetVC = BottomSheetVC()
    vc.delegate = self
    vc.modalPresentationStyle = .custom 
    vc.transitioningDelegate = transitionController.transitionDelegate
    present(vc, animated: true)
  }
}

extension ViewController: BottomSheetVCDelegate {
  func pannedVertically(_ sender: BottomSheet.PanAxisGestureRecognizer, viewController: UIViewController) {
    transitionController.handlePan(sender, viewController: viewController)
  }
  
  func dismissBtnPressed(vc: BottomSheetVC) {
    transitionController.dismissedFromButton(vc: vc)
  }
}

