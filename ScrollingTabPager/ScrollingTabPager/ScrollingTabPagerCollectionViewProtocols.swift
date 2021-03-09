//
//  ScrollingTabPagerCollectionViewProtocols.swift
//  ScrollingTabPager
//
//  Created by Don Clore on 3/8/21.
//
import UIKit

extension ScrollingTabPager: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return titles.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderCell.cellId, for: indexPath) as? HeaderCell else {
      fatalError("Should never happen")
    }
    cell.selectedColor = designObject.headerTextColor
    if let deSelectedColor = designObject.headerDeSelectedTextColor {
      cell.deSelectedColor = deSelectedColor
    }
    cell.backgroundColor = collectionView.backgroundColor
    cell.contentView.backgroundColor = collectionView.backgroundColor
    cell.label.text = titles[indexPath.item]
    cell.label.textColor = designObject.headerTextColor
    switch designObject.headerAlignment {
    case .leading, .leadingStayVisible:
      cell.label.textAlignment = NSTextAlignment.left
    case .center:
      cell.label.textAlignment = NSTextAlignment.center
    }
    
    cell.label.textColor = cell.isSelected ? cell.selectedColor : cell.normalColor
    cell.label.font = designObject.headerFont

    cell.extraTabWidth = designObject.extraTabWidth
    cell.sizeToFit()
  
    return cell
  }
}

extension ScrollingTabPager: UICollectionViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    switch designObject.headerAlignment {
    case .leading, .leadingStayVisible:
      break
    case .center:
      scrollView.setContentOffset(CGPoint.zero, animated: false)
    }
  }
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? HeaderCell,
      let header = collectionView as? ScrollingTabHeader else {
      return
    }
    cell.isSelected = true
    cell.setNeedsLayout()
    currentIndex = indexPath.item
    header.indexPathForUnderline = indexPath
    pager.select(viewControllerIndex: currentIndex)

    switch designObject.headerAlignment {
    
    case .center, .leading:
      let scrollPosition = getScrollPositionForAlignmentStyle()
      collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: true)
    case .leadingStayVisible:
      break
    }

    collectionView.setNeedsLayout()
    collectionView.layoutIfNeeded()
    
    showOrHideArrowAsAppropriate(contentWidth: collectionView.contentSize.width, currIndex: indexPath.item)
  
    pageSelectedWrapper(index: indexPath.item)
  }

  public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? HeaderCell else {
      return
    }
    cell.isSelected = false
  }
}

public class HeaderCell: UICollectionViewCell {
  public static let cellId: String = "HeaderCell"
  public var selectedColor: UIColor = UIColor.black
  public var deSelectedColor: UIColor?
  
  static let alphaComponentBase: CGFloat = 0.4
  var font: UIFont = UIFont.boldSystemFont(ofSize: 16.0) {
    didSet {
      label.font = font
    }
  }
  
  public var normalColor: UIColor {
    if let deselect = deSelectedColor {
      return deselect
    }
    return self.selectedColor.withAlphaComponent(HeaderCell.alphaComponentBase)
  }
  
  public var extraTabWidth: CGFloat = 0 {
    didSet {
      setNeedsLayout()
    }
  }

  var interpolatedColor: UIColor? {
    didSet {
      if let color = interpolatedColor {
        label.textColor = color
      }
    }
  }

  public let label: UILabel = UILabel()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    secondPhaseInitializer()
  }
  
  
  public static func widthThatFits(_ title: String, extraTabWidth: CGFloat, color: UIColor, font: UIFont) -> CGFloat {
    return sizeForCell(with: title, extraTabWidth: extraTabWidth, color: color, font: font).width
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    secondPhaseInitializer()
  }
  
  static func sizeForCell(with title: String, extraTabWidth: CGFloat, color: UIColor, font: UIFont) -> CGSize {
    let ns = NSString(string: title)
    let size = ns.size(withAttributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font])
    return CGSize(width: size.width + extraTabWidth, height: size.height)
  }


  override public var isSelected: Bool {
    get {
      return super.isSelected
    }
    set {
      label.textColor = newValue ? selectedColor : normalColor
      interpolatedColor = nil
      super.isSelected = newValue
      label.setNeedsLayout()
      label.setNeedsDisplay()
    }
  }
  
  fileprivate func secondPhaseInitializer() {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false

    label.textAlignment = .center
    label.textColor = normalColor
    label.font = font
    label.clipsToBounds = true
    label.backgroundColor = .clear
    label.baselineAdjustment = UIBaselineAdjustment.alignCenters

    NSLayoutConstraint.activate([
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
        contentView.topAnchor.constraint(equalTo: topAnchor),
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ])

    clipsToBounds = true
  }
}

