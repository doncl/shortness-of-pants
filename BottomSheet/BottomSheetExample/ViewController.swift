//
//  ViewController.swift
//  BottomSheetExample
//
//  Created by Don Clore on 2/4/23.
//

import UIKit
import BottomSheet

class ViewController: UIViewController {
  lazy var stack: UIStackView = {
    let s = UIStackView()
    s.axis = .vertical
    s.alignment = .center
    s.spacing = 16
    s.distribution = .equalSpacing
    s.translatesAutoresizingMaskIntoConstraints = false
    return s
  }()
  
  lazy var bottomSheetBtn: UIButton = {
    let b: UIButton = UIButton(type: UIButton.ButtonType.custom)
    b.backgroundColor = UIColor.blue
    b.setTitleColor(UIColor.white, for: UIControl.State.normal)
    b.setTitle("Bottom Sheet!", for: UIControl.State.normal)
    b.layer.cornerRadius = BottomSheetVC.Constants.btnCornerRadius
    return b
  }()
  
  lazy var crossDissolveBtn: UIButton = {
    let b: UIButton = UIButton(type: UIButton.ButtonType.custom)
    b.backgroundColor = UIColor.blue
    b.setTitleColor(UIColor.white, for: UIControl.State.normal)
    b.setTitle("X-Dissolve", for: UIControl.State.normal)
    b.layer.cornerRadius = BottomSheetVC.Constants.btnCornerRadius
    return b
  }()
  
  
  lazy var flipButton: UIButton = {
    let b: UIButton = UIButton(type: UIButton.ButtonType.custom)
    b.backgroundColor = UIColor.blue
    b.setTitleColor(UIColor.white, for: UIControl.State.normal)
    b.setTitle("Flip", for: UIControl.State.normal)
    b.layer.cornerRadius = BottomSheetVC.Constants.btnCornerRadius
    return b
  }()
  
  lazy var coverButton: UIButton = {
    let b: UIButton = UIButton(type: UIButton.ButtonType.custom)
    b.backgroundColor = UIColor.blue
    b.setTitleColor(UIColor.white, for: UIControl.State.normal)
    b.setTitle("CoverVert", for: UIControl.State.normal)
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
    
    view.addSubview(stack)
        
    [coverButton, flipButton, crossDissolveBtn, bottomSheetBtn,].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      stack.addArrangedSubview($0)
    }
    
    NSLayoutConstraint.activate([
      
      bottomSheetBtn.widthAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnWidth),
      bottomSheetBtn.heightAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnHeight),
      
      crossDissolveBtn.widthAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnWidth),
      crossDissolveBtn.heightAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnHeight),

      flipButton.widthAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnWidth),
      flipButton.heightAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnHeight),

      coverButton.widthAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnWidth),
      coverButton.heightAnchor.constraint(equalToConstant: BottomSheetVC.Constants.btnHeight),

      stack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
  
    coverButton.addTarget(self, action: #selector(ViewController.coverBtnPressed(_:)), for: .touchUpInside)
    flipButton.addTarget(self, action: #selector(ViewController.flipBtnPressed(_:)), for: .touchUpInside)
    bottomSheetBtn.addTarget(self, action: #selector(ViewController.presentBtnPressed(_:)), for: UIControl.Event.touchUpInside)
    crossDissolveBtn.addTarget(self, action: #selector(ViewController.xDissolveBtnPressed(_:)), for: .touchUpInside)
  }
  
  @objc func coverBtnPressed(_ sender: UIButton) {
    let vc: BottomSheetVC = BottomSheetVC()
    vc.modalTransitionStyle = .coverVertical
    vc.delegate = self
    present(vc, animated: true)
  }

  @objc func flipBtnPressed(_ sender: UIButton) {
    let vc: BottomSheetVC = BottomSheetVC()
    vc.modalTransitionStyle = .flipHorizontal
    vc.delegate = self
    present(vc, animated: true)
  }
      
  @objc func xDissolveBtnPressed(_ sender: UIButton) {
    let vc: BottomSheetVC = BottomSheetVC()
    vc.modalTransitionStyle = .crossDissolve
    vc.delegate = self
    present(vc, animated: true)
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
    if vc.modalTransitionStyle == .partialCurl {
      vc.modalTransitionStyle = .coverVertical
      vc.modalPresentationStyle = .automatic
      dismiss(animated: true)
    } else {
      transitionController.dismissedFromButton(vc: vc)
    }
  }
}

