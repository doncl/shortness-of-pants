//
//  ScrollingTabHeader.swift
//  ScrollingTabPager
//
//  Created by Don Clore on 3/8/21.
//
import UIKit

public protocol ScrollingTabHeaderDelegate: UICollectionViewDelegate {
  var titles: [String] { get }
  var designObject: ScrollingTabPager.DesignObject { get }
  func didLayoutSubviews(contentWidth: CGFloat)
}

open class ScrollingTabHeader: UICollectionView {
  let minimumCompactSpacing: CGFloat = 14.0
  let minimumRegularSpacing: CGFloat = 14.0
  let underline: CALayer = CALayer()
  let underlineDefaultHeight: CGFloat = 3.0
  var underlineHeight: CGFloat
  static public let defaultHeaderHeight: CGFloat = 50.0
  public var indexPathForUnderline: IndexPath?
  
  private let defaultUnderlineColor: CGColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
  var underlineColor: UIColor? {
    didSet {
      if let color = underlineColor {
        underline.backgroundColor = color.cgColor
      } else {
        underline.backgroundColor = defaultUnderlineColor
      }
    }
  }
  
  let horzPad: CGFloat = 8.0
  public var scrollingTabHeaderInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8) {
    didSet {
        contentInset = scrollingTabHeaderInset
    }
  }
    
  var extraTabWidth: CGFloat
  var hasUnderline: Bool
  var showsMoreContentArrow: Bool
    
  private var minInteritemSpacing: CGFloat = 0
  var minimumInteritemSpacing: CGFloat {
    get {
      if minInteritemSpacing == 0 {
        if traitCollection.horizontalSizeClass == .regular {
          return minimumRegularSpacing
        } else {
          return minimumCompactSpacing
        }
      }
      return minInteritemSpacing
    }
    set {
      minInteritemSpacing = newValue
    }
  }
    
  public init(layout: ScrollingTabHeaderLayout, extraTabWidth: CGFloat,  hasUnderline: Bool,
       underlineColor: UIColor? = nil, showsMoreContentArrow: Bool) {
    
    self.extraTabWidth = extraTabWidth
    self.hasUnderline = hasUnderline
    self.underlineColor = underlineColor
    self.underlineHeight = hasUnderline ? underlineDefaultHeight : 0
    self.showsMoreContentArrow = showsMoreContentArrow
    super.init(frame: .zero, collectionViewLayout: layout)
    secondPhaseInit()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("not implemented")
  }
    
  private func secondPhaseInit() {
    if let underlineColor = underlineColor {
      underline.backgroundColor = underlineColor.cgColor
    } else {
      underline.backgroundColor = defaultUnderlineColor
    }
    underline.masksToBounds = true
    contentInset = scrollingTabHeaderInset
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    register(HeaderCell.self, forCellWithReuseIdentifier: HeaderCell.cellId)
    allowsSelection = true
    allowsMultipleSelection = false
    clipsToBounds = true
  }

  func setUnderLine(x: CGFloat, width: CGFloat, noLayout: Bool = false) {
    guard hasUnderline else {
      return
    }
    
    underline.frame = CGRect(x: x, y: bounds.height - underlineHeight - 1, width: width, height: underlineHeight)

    if !noLayout {
      // avoid recursion
      indexPathForUnderline = nil
      setNeedsLayout()
      layoutIfNeeded()
    }

    if underline.superlayer == nil {
      // don't attach it to the parent layer until we really need it.   This avoids some unsightly visual artifacts.
      layer.addSublayer(underline)
    }
  }

  func setInterpolatedColorsFor(currentlySelectedPage: Int, andDestinationPage destinationPage: Int, percentProgress: CGFloat) {
    guard let scrollingHeaderDelegate = delegate as? ScrollingTabHeaderDelegate else { return }
    let colorDelta: CGFloat = (1.0 - HeaderCell.alphaComponentBase) * percentProgress
    let destAlpha: CGFloat = HeaderCell.alphaComponentBase + colorDelta
    let srcAlpha: CGFloat = 1.0 - colorDelta

    let srcInterpolatedIndexPath = IndexPath(item: currentlySelectedPage, section: 0)
    let destInterpolatedIndexPath = IndexPath(item: destinationPage, section: 0)

    guard let srcCell = cellForItem(at: srcInterpolatedIndexPath) as? HeaderCell,
      let destCell = cellForItem(at: destInterpolatedIndexPath) as? HeaderCell else {
        return
    }
    
    let headerColor: UIColor = scrollingHeaderDelegate.designObject.headerTextColor
  
    srcCell.interpolatedColor = headerColor.withAlphaComponent(srcAlpha)
    destCell.interpolatedColor = headerColor.withAlphaComponent(destAlpha)
  }

  func setUnderLine(for indexPath: IndexPath, noLayout: Bool = false) {
    guard hasUnderline, let attrs = layoutAttributesForItem(at: indexPath) else {
      return
    }
    let cellFrame = attrs.frame
    var cellWidth = cellFrame.width
    var x = cellFrame.origin.x
  
    if let scrollingHeaderDelegate = delegate as? ScrollingTabHeaderDelegate {
      let title = scrollingHeaderDelegate.titles[indexPath.item]
      let font = scrollingHeaderDelegate.designObject.headerFont
      let textColor = scrollingHeaderDelegate.designObject.headerTextColor
      let textSize = HeaderCell.sizeForCell(with: title, extraTabWidth: 0, color: textColor, font: font)
      cellWidth = textSize.width
      if let cell = self.cellForItem(at: indexPath) as? HeaderCell {
        if cell.label.textAlignment == .center {
          x = cellFrame.midX - (textSize.width / 2)
        }
      }
    }
    setUnderLine(x: x, width: cellWidth, noLayout: noLayout)
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    if let indexPath = indexPathForUnderline {
      setUnderLine(for: indexPath, noLayout: true)
    }
    guard let scrollingDelegate = delegate as? ScrollingTabHeaderDelegate else {
      return
    }
    scrollingDelegate.didLayoutSubviews(contentWidth: contentSize.width)
  }

  open override func selectItem(at indexPath: IndexPath?, animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
    super.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    guard let indexPath = indexPath else {
      return
    }
    indexPathForUnderline = indexPath
    setNeedsLayout()
    layoutIfNeeded()
  }
}
