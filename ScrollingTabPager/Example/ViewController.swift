//
//  ViewController.swift
//  Example
//
//  Created by Don Clore on 3/8/21.
//

import UIKit
import ScrollingTabPager

class ViewController: UIViewController {
  struct NamedColor {
    let name: String
    let color: UIColor
  }
  
  let namedColors: [NamedColor] = [
    NamedColor(name: "Blue", color: UIColor.blue),
    NamedColor(name: "Red", color: UIColor.red),
    NamedColor(name: "Purple", color: UIColor.purple),
    NamedColor(name: "Pink", color: UIColor.systemPink),
    NamedColor(name: "Cyan", color: UIColor.cyan),
  ]
  
  var titles: [String] {
    return namedColors.map({$0.name})
  }
  
  static let desObj = ScrollingTabPager.DesignObject(
    headerAlignment:
      ScrollingTabPager.HeaderAlignment.leading(leadingOffset: 20, trailingOffset: 20),
    
    backgroundColor: UIColor.white, extraTabWidth: 0,
    headerHeight: 60, headerUnderline: true,
    headerUnderlineColor: UIColor.orange,
    headerTextColor: UIColor.black,
    headerFont: UIFont.boldSystemFont(ofSize: 24.0),
    showsHeaderMoreContentArrow: false)
  
  private lazy var pager: ScrollingTabPager = {
    let pgr = ScrollingTabPager(titles, delegateId: "delegateID",
                                designObject: ViewController.desObj,
                                doesHapticFeedback: true)
    
    pgr.delegate = self
    return pgr
  }()
  
  private let vcCache: NSCache<NSNumber, UIViewController> = NSCache<NSNumber, UIViewController>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addChild(pager)
    view.addSubview(pager.view)
    pager.didMove(toParent: self)
    
    pager.view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      pager.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      pager.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      pager.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      pager.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
   
    pager.setup()
  }
}

extension ViewController: ScrollingTabPagerDelegate {
  func viewController(forIndex index: Int, and delegateId: String?) -> UIViewController {
    let key = NSNumber(integerLiteral: index)
    if let vc = vcCache.object(forKey: key) {
      return vc
    }
    let namedColor = namedColors[index]
    let vc = ColorVC(colorTitle: namedColor.name, color: namedColor.color)
    
    vcCache.setObject(vc, forKey: key)
    return vc
  }
  
  func pageSelected(forIndex index: Int, and delegateId: String?) {
  }
}
