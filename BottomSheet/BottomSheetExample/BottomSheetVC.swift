//
//  BottomSheetVC.swift
//  BottomSheetExample
//
//  Created by Don Clore on 2/4/23.
//

import UIKit
import BottomSheet

protocol BottomSheetVCDelegate: AnyObject {
  func dismissBtnPressed(vc: BottomSheetVC)
  func pannedVertically(_ sender: PanAxisGestureRecognizer, viewController: UIViewController)
}

class BottomSheetVC: UIViewController {
  enum Constants {
    static let btnWidth: CGFloat = 140
    static let btnHeight: CGFloat = 60
    static let btnCornerRadius: CGFloat = 5
  }
  
  lazy var dismissBtn: UIButton = {
    let b: UIButton = UIButton(type: UIButton.ButtonType.custom)
    b.backgroundColor = UIColor.blue
    b.setTitleColor(UIColor.white, for: UIControl.State.normal)
    b.setTitle("Dismiss!", for: UIControl.State.normal)
    b.layer.cornerRadius = Constants.btnCornerRadius
    return b
  }()
  
  lazy var verticalPan: PanAxisGestureRecognizer = {
    let pan = PanAxisGestureRecognizer(
      axis: PanAxis.vertical,
      target: self,
      action: #selector(BottomSheetVC.pannedVertically(_:))
    )
      
      return pan
  }()
  
  weak var delegate: BottomSheetVCDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemPink
    
    [dismissBtn,].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }
    
    dismissBtn.addTarget(self, action: #selector(BottomSheetVC.dismissBtnPressed(_:)), for: UIControl.Event.touchUpInside)
    
    NSLayoutConstraint.activate([
      dismissBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      dismissBtn.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      dismissBtn.widthAnchor.constraint(equalToConstant: Constants.btnWidth),
      dismissBtn.heightAnchor.constraint(equalToConstant: Constants.btnHeight),
    ])
    
    view.addGestureRecognizer(verticalPan)
  }
  
  @objc func pannedVertically(_ sender: PanAxisGestureRecognizer) {
    guard let delegate = self.delegate else {
      return
    }
    delegate.pannedVertically(sender, viewController: self)
  }

  
  @objc func dismissBtnPressed(_ sender: UIButton) {
    guard let delegate else {
      return
    }
    delegate.dismissBtnPressed(vc: self)
  }
}
