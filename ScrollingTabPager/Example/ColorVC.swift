//
//  ColorVC.swift
//  Example
//
//  Created by Don Clore on 3/8/21.
//

import UIKit

class ColorVC: UIViewController {
  let colorTitle: String
  let color: UIColor
  
  let label: UILabel = UILabel()
  
  init(colorTitle: String, color: UIColor) {
    self.colorTitle = colorTitle
    self.color = color
    super.init(nibName:  nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = color
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    
    label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    label.text = colorTitle
    label.textColor = UIColor.black
    label.textAlignment = NSTextAlignment.center
    
    NSLayoutConstraint.activate([
      label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
    ])
  }
}
