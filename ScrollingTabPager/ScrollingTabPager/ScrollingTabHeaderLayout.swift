//
//  ScrollingTabHeaderLayout.swift
//  ScrollingTabPager
//
//  Created by Don Clore on 3/8/21.
//
import UIKit

public protocol ScrollingTabHeaderLayoutDelegate: AnyObject {
    var designObject: ScrollingTabPager.DesignObject { get }
    var titles: [String] { get }
    func getHeaderContentWidth(titles: [String]) -> CGFloat
    var headerHeight: CGFloat { get }
    var headerInteritemSpacing: CGFloat { get }
}

public class ScrollingTabHeaderLayout: UICollectionViewLayout {
  public weak var delegate: ScrollingTabHeaderLayoutDelegate?
  private var cache: [UICollectionViewLayoutAttributes] = []
  
  override open var collectionViewContentSize: CGSize {
    guard let delegate = delegate, delegate.titles.count > 0 else { return .zero }
  
    let width = delegate.getHeaderContentWidth(titles: delegate.titles)
    let height = delegate.headerHeight
  
    return CGSize(width: width, height: height)
  }
  
  override public func prepare() {
    assert(delegate != nil)
    guard let delegate = delegate else {
        return
    }
    cache.removeAll()
    switch delegate.designObject.headerAlignment {
      
    case ScrollingTabPager.HeaderAlignment.leading, ScrollingTabPager.HeaderAlignment.leadingStayVisible:
        cache = getAttributesForLeadingLayout()
      
    case ScrollingTabPager.HeaderAlignment.center:
        cache = getAttributesForCenteredLayout()
    }
  }
    
  private func getAttributesForLeadingLayout(startX: CGFloat = 0) -> [UICollectionViewLayoutAttributes] {
    guard let delegate = delegate else { return [] }
    
    let titles = delegate.titles
    let extraTabWidth = delegate.designObject.extraTabWidth
    let font: UIFont = delegate.designObject.headerFont
    let color: UIColor = delegate.designObject.headerTextColor
    var currX: CGFloat = startX
    var attrs: [UICollectionViewLayoutAttributes] = []

    for (itemIndex, title) in titles.enumerated() {
      let indexPath = IndexPath(item: itemIndex, section: 0)
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      let size = HeaderCell.sizeForCell(with: title, extraTabWidth: extraTabWidth, color: color, font: font)
      var width = size.width
      width += delegate.headerInteritemSpacing

      let height = delegate.headerHeight
      attributes.frame = CGRect(x: currX, y: 0, width: width, height: height)
      attrs.append(attributes)
      currX += width
    }
    return attrs
  }
    
    private func getAttributesForCenteredLayout() -> [UICollectionViewLayoutAttributes] {
        guard let header = collectionView as? ScrollingTabHeader else { return [] }

        let contentWidth = collectionViewContentSize.width
        let boundsWidth = header.bounds.width
        if abs(contentWidth - boundsWidth) > 2.0 {
            // If the content is wider than the bounds, we're not going to force a centered layout on it
            // that makes no sense; just use the leading layout.
            return getAttributesForLeadingLayout()
        }

        let boundsCenterX = boundsWidth / 2
        let startX: CGFloat = max(boundsCenterX - (contentWidth / 2), 0)
        return getAttributesForLeadingLayout(startX: startX)
    }
  
  public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
      
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
  
  public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard cache.count > indexPath.item else { return nil }
        return cache[indexPath.item]
    }
}
