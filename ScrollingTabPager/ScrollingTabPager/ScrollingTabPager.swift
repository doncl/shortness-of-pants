//
//  ScrollingTabPager.swift
//  ScrollingTabPager
//
//  Created by Don Clore on 3/8/21.
//
import UIKit

public protocol ScrollingTabPagerDelegate: AnyObject {
  func viewController(forIndex index: Int, and delegateId: String?) -> UIViewController
  func pageSelected(forIndex index: Int, and delegateId: String?)
}

private protocol DesignObjectDelegate: AnyObject {
  func didSetAlignment(alignment: ScrollingTabPager.HeaderAlignment)
  func didSetBackgroundColor(color: UIColor)
  func didSetExtraTabWidth(extraTabWidth: CGFloat)
  func didSetHeaderUnderline(headerUnderline: Bool)
  func didSetHeaderUnderlineColor(headerUnderlineColor: UIColor?)
  func didSetShowsHeaderMoreContentArrow(showMoreArrow: Bool)
  func didSetHeaderHeight(headerHeight: CGFloat)
  func didSetHeaderTextColor(color: UIColor)
}

open class ScrollingTabPager: UIViewController {
  public static let defaultBlack = UIColor(red: 27 / 255, green: 27 / 255, blue: 27 / 255, alpha: 1.0)

  public struct ViewModel {
      var titles: [String]
      var designObject: DesignObject
  }

  public struct DesignObject {
    fileprivate weak var delegate: DesignObjectDelegate?
    public var headerAlignment: HeaderAlignment {
      didSet {
        delegate?.didSetAlignment(alignment: headerAlignment)
      }
    }
    
    public var headerTextColor: UIColor {
      didSet {
        delegate?.didSetHeaderTextColor(color: headerTextColor)
      }
    }
    
    public var headerDeSelectedTextColor: UIColor?
    public var headerFont: UIFont
    
    public var headerHeight: CGFloat = ScrollingTabHeader.defaultHeaderHeight {
      didSet {
        delegate?.didSetHeaderHeight(headerHeight:headerHeight)
      }
    }
    
    public var backgroundColor: UIColor {
      didSet {
        delegate?.didSetBackgroundColor(color: backgroundColor)
      }
    }
    
    public var headerUnderline: Bool {
      didSet {
        delegate?.didSetHeaderUnderline(headerUnderline: headerUnderline)
      }
    }
    
    public var headerUnderlineColor: UIColor? {
      didSet {
        delegate?.didSetHeaderUnderlineColor(headerUnderlineColor: headerUnderlineColor)
      }
    }

    public var extraTabWidth: CGFloat {
      didSet {
        delegate?.didSetExtraTabWidth(extraTabWidth: extraTabWidth)
      }
    }
    
    public var showsHeaderMoreContentArrow: Bool {
      didSet {
        delegate?.didSetShowsHeaderMoreContentArrow(showMoreArrow: showsHeaderMoreContentArrow)
      }
    }
    
    public init(headerAlignment: HeaderAlignment = .center,
                backgroundColor: UIColor = ScrollingTabPager.defaultBlack,
                extraTabWidth: CGFloat = 0,
                headerHeight: CGFloat = ScrollingTabHeader.defaultHeaderHeight,
                headerUnderline: Bool = true,
                headerUnderlineColor: UIColor? = nil,
                headerTextColor: UIColor = UIColor.white,
                headerDeSelectedTextColor: UIColor? = nil,
                headerFont: UIFont = UIFont.boldSystemFont(ofSize: 16),
                showsHeaderMoreContentArrow: Bool = false) {
      
      self.headerAlignment = headerAlignment
      self.backgroundColor = backgroundColor
      self.extraTabWidth = extraTabWidth
      self.headerUnderline = headerUnderline
      self.headerHeight = headerHeight
      if let headerUnderlineColor = headerUnderlineColor {
        self.headerUnderlineColor = headerUnderlineColor
      }
      self.headerTextColor = headerTextColor
      self.headerDeSelectedTextColor = headerDeSelectedTextColor
      self.headerFont = headerFont
      self.showsHeaderMoreContentArrow = showsHeaderMoreContentArrow
    }
    
    public func clone() -> DesignObject {
      return DesignObject(headerAlignment: headerAlignment, backgroundColor: backgroundColor, extraTabWidth: extraTabWidth,
                          headerHeight: headerHeight, headerUnderline: headerUnderline, headerUnderlineColor: headerUnderlineColor,
                          headerTextColor: headerTextColor, headerDeSelectedTextColor: headerDeSelectedTextColor,
                          headerFont: headerFont, showsHeaderMoreContentArrow: showsHeaderMoreContentArrow)
    }
  }
  
  lazy var showMoreArrow: GradientArrow = {
    let arrow = GradientArrow()
    arrow.translatesAutoresizingMaskIntoConstraints = false
    arrow.isHidden = true
    return arrow
  }()

  public enum HeaderAlignment {
    case center
    case leading(leadingOffset: CGFloat, trailingOffset: CGFloat)
    case leadingStayVisible(leadingOffset: CGFloat, trailingOffset: CGFloat)
  }

  var initialSetup: Bool = false
  var headerLayoutComplete: Bool = false
  var pagerLayoutComplete: Bool = false
  var interpolateHeaderColors: Bool = true
  public var titles: [String]
  var delegateId: String?
  let header: ScrollingTabHeader
  let pager: Pager = Pager()
  
  public var headerCenteredLayoutWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
  public var headerCenteringContraint: NSLayoutConstraint = NSLayoutConstraint()
  public var headerLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint()
  public var headerLeadingLayoutWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
  public var headerHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
  public var headerTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
  
  public var pagerTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
  
  public var headerView: UIView {
    return header
  }
  
  var showsMoreArrowRightConstraint: NSLayoutConstraint = NSLayoutConstraint()
  public weak var delegate: ScrollingTabPagerDelegate?

  public var currentIndex: Int = 0

  var numSegments: Int {
    return titles.count
  }

  public var designObject: DesignObject
  
  var isEnabled: Bool = true {
    didSet {
      pager.isEnabled = isEnabled
      header.isUserInteractionEnabled = isEnabled
    }
  }
  
  var doesHapticFeedback: Bool
  
  lazy private var haptic : UINotificationFeedbackGenerator = {
    let gen = UINotificationFeedbackGenerator()
    gen.prepare()
    return gen
  }()
  
    
  convenience public init(_ titles: [String], delegate: ScrollingTabPagerDelegate, delegateId: String,
                          designObject: DesignObject = DesignObject(),
                          doesHapticFeedback: Bool = true) {
    

    self.init(titles, delegateId: delegateId, designObject: designObject, doesHapticFeedback: doesHapticFeedback)
    self.delegate = delegate
    setup()
  }

  public init(_ titles: [String], delegateId: String, designObject: DesignObject = DesignObject(),
       doesHapticFeedback: Bool = true) {
  
    self.doesHapticFeedback = doesHapticFeedback
    let layout: ScrollingTabHeaderLayout = ScrollingTabHeaderLayout()
    
    header = ScrollingTabHeader(layout: layout, extraTabWidth: designObject.extraTabWidth,
                                hasUnderline: designObject.headerUnderline,
                                underlineColor: designObject.headerUnderlineColor,
                                showsMoreContentArrow: designObject.showsHeaderMoreContentArrow)
  
    self.designObject = designObject
    self.titles = titles
    super.init(nibName: nil, bundle: nil)
    layout.delegate = self
    header.delegate = self
    self.delegateId = delegateId
    loadViewIfNeeded()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bumpPhone() {
    if doesHapticFeedback {
      haptic.notificationOccurred(.success)
    }
  }
  
  public func reloadHeader() {
    header.reloadData()
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
    view.clipsToBounds = true
    view.backgroundColor = designObject.backgroundColor
    header.backgroundColor = designObject.backgroundColor
    pager.view.backgroundColor = designObject.backgroundColor

    addChild(pager)
    pager.delegate = self
    pager.didMove(toParent: self)
    view.addSubview(pager.view)
    
    headerLayout()
    pagerLayout()
    
    designObject.delegate = self
    navigationItem.largeTitleDisplayMode = .automatic
  }
  
  public func reParentHeader(toParentView parentView: UIView, vertOffset: CGFloat) {
    assert(header.superview != nil)
    
    [headerTopConstraint, headerLeadingLayoutWidthConstraint, headerCenteringContraint,
     headerLeadingConstraint, pagerTopConstraint].forEach {
      $0.isActive = false
     }
    
    header.removeFromSuperview()
    parentView.addSubview(header)
    
    headerTopConstraint = header.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: vertOffset)
    headerTopConstraint.isActive = true
    
    headerLeadingLayoutWidthConstraint = header.widthAnchor.constraint(lessThanOrEqualTo: parentView.widthAnchor)
    headerLeadingLayoutWidthConstraint.isActive = true
    headerLeadingLayoutWidthConstraint.priority = UILayoutPriority.required
    
    headerCenteringContraint = header.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)

    headerCenteringContraint = header.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
    headerLeadingConstraint = header.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 8)
    headerLeadingConstraint.isActive = true
    
    pagerTopConstraint = pager.view.topAnchor.constraint(equalTo: view.topAnchor)
    pagerTopConstraint.isActive = true
    didSetAlignment(alignment: designObject.headerAlignment)
  }
    
  private func initialHeaderLayout() {
    view.addSubview(header)
    headerTopConstraint = header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    headerTopConstraint.isActive = true
    
    headerHeightConstraint = header.heightAnchor.constraint(equalToConstant: designObject.headerHeight)
    headerHeightConstraint.isActive = true
    
    headerLeadingLayoutWidthConstraint = header.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor)
    headerLeadingLayoutWidthConstraint.isActive = true
    headerLeadingLayoutWidthConstraint.priority = UILayoutPriority.required
    
    headerCenteringContraint = header.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    headerLeadingConstraint = header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8)
    setHeaderWidthConstraintForCenteredLayouts()
  }
  
  private func headerLayout() {
    guard !headerLayoutComplete else {
      return
    }
    headerLayoutComplete = true
    
    header.translatesAutoresizingMaskIntoConstraints = false
    
    initialHeaderLayout()
    
    didSetAlignment(alignment: designObject.headerAlignment)
    if designObject.showsHeaderMoreContentArrow {
      view.addSubview(showMoreArrow)
      showMoreArrow.arrowColor = designObject.headerTextColor
      showMoreArrow.gradientColor = designObject.backgroundColor
      
      showsMoreArrowRightConstraint = showMoreArrow.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)
      NSLayoutConstraint.activate([
        showsMoreArrowRightConstraint,
        showMoreArrow.centerYAnchor.constraint(equalTo: header.centerYAnchor, constant: -4.0),
      ])
      view.bringSubviewToFront(showMoreArrow)
      showMoreArrow.addTarget(self, action: #selector(ScrollingTabPager.showMoreButtonTapped(_:)), for: .touchUpInside)
    }
  }
  
  private func pagerLayout() {
    guard !pagerLayoutComplete else {
      return
    }
    pagerLayoutComplete = true
    pager.view.translatesAutoresizingMaskIntoConstraints = false
    
    pagerTopConstraint = pager.view.topAnchor.constraint(equalTo: header.bottomAnchor)
    
    NSLayoutConstraint.activate([
      pagerTopConstraint,
      pager.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      pager.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      pager.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
  
  private func handleLeadingAlignment(leadingOffset: CGFloat, trailingOffset: CGFloat, contentWidth: CGFloat, currIndex: Int) {
    // We show the arrow if we have more content than can be displayed, but not if the last element is selected.
    let pad = leadingOffset + trailingOffset
    let maxWidth = view.bounds.width - pad
    
    let isHidden: Bool = contentWidth <= maxWidth || currIndex == titles.count - 1
    
    // We only set the arrow.isHidden flag if a change from current state needs to be made.
    if showMoreArrow.isHidden != isHidden {
      showMoreArrow.isHidden = isHidden
      // It seems to sometimes not behave properly, unless we tell UIKit to update this.
      showMoreArrow.setNeedsDisplay()
    }
  }
  
  /// Given contentWidth, and the current selected index, will show or hide the
  /// showMoreArrow.
  ///
  /// - Parameters:
  ///   - contentWidth: requires an accurate accounting of the current contentWidth
  ///   - currIndex: what is currently selected, or in the act of being selected.   It's important not to call this with
  ///                the old index, when we're in the middle of a selection operation.
  func showOrHideArrowAsAppropriate(contentWidth: CGFloat, currIndex: Int) {
    switch designObject.headerAlignment {
    case .center:
      // Centered alignment never shows the arrow.
      showMoreArrow.isHidden = true
      return
    case .leading(let leadingOffset, let trailingOffset):
      handleLeadingAlignment(leadingOffset: leadingOffset, trailingOffset: trailingOffset,
                             contentWidth: contentWidth, currIndex: currIndex)
      
    case .leadingStayVisible(let leadingOffset, let trailingOffset):
      handleLeadingAlignment(leadingOffset: leadingOffset, trailingOffset: trailingOffset,
                             contentWidth: contentWidth, currIndex: currIndex)
    }
  }
  
  @objc func showMoreButtonTapped(_ sender: GradientArrow) {
    let newIndex: Int = pager.currPage + 1
    select(at: newIndex)
  }
  
  func addPriorityGestures(_ gestures: [UIGestureRecognizer]) {
    pager.addPriorityGestures(gestures)
  }

  public func setup() {
    if initialSetup {
        return
    }
    initialSetup = true
    setHeaderWidthConstraintForCenteredLayouts()
    header.dataSource = self
    header.delegate = self
    header.reloadData()
    header.minimumInteritemSpacing = designObject.extraTabWidth
    pager.numPages = titles.count
    loadViewIfNeeded()
    pager.reload(at: 0)  // load up currentVC
    pager.reload(at: 1)  // load up subsequentVC, precedingVC remains nil, for now
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    select(at: currentIndex, doHaptic: false)
  }
  
  func getScrollPositionForAlignmentStyle() -> UICollectionView.ScrollPosition {
    let alignment = designObject.headerAlignment
    switch alignment {
    case .leading:
      return UICollectionView.ScrollPosition.left
    case .leadingStayVisible:
      return UICollectionView.ScrollPosition.centeredHorizontally
    case .center:
      return UICollectionView.ScrollPosition.centeredHorizontally
    }
  }

  public func select(at viewControllerIndex: Int, doHaptic: Bool = true, animated: Bool = true) {
    guard viewControllerIndex < titles.count else { return }

    let scrollPosition = getScrollPositionForAlignmentStyle()
    header.selectItem(at: IndexPath(item: viewControllerIndex, section: 0), animated: false,
                      scrollPosition: scrollPosition)

    pager.select(viewControllerIndex: viewControllerIndex, animated: animated)
    showOrHideArrowAsAppropriate(contentWidth: header.contentSize.width, currIndex: viewControllerIndex)
    pageSelectedWrapper(index: viewControllerIndex, doHaptic: doHaptic)
  }

  func insert(title: String, at index: Int, selectInsertion: Bool) {
    guard index < pager.numPages else { return }

    titles.insert(title, at: index)
    pager.insert(at: index)
    setHeaderWidthConstraintForCenteredLayouts()
    header.reloadData()
    if selectInsertion {
      select(at: index)
    }
  }

  func reload(at index: Int, with title: String) {
    guard titles.count > index else { return }
    self.pager.reload(at: index)
    titles[index] = title
    let indexPath = IndexPath(item: index, section: 0)
    header.reloadItems(at: [indexPath])
    select(at: index)
  }

  func remove(at index: Int) {
    // don't delete nonexistent segments, also...there's never any point
    // in having only 1 segment.
    guard numSegments > index, numSegments > 2 else { return }
    pager.remove(at: index)
    titles.remove(at: index)
    setHeaderWidthConstraintForCenteredLayouts()
    header.reloadData()
    header.setNeedsLayout()
    header.layoutIfNeeded()
    if currentIndex == index && currentIndex > 0 || currentIndex >= numSegments {
        currentIndex -= 1
    }
    select(at: currentIndex)
  }

  private func setHeaderWidthConstraintForCenteredLayouts() {
    let width = getHeaderContentWidth(titles: titles)
  
    headerCenteredLayoutWidthConstraint = header.widthAnchor.constraint(equalToConstant: width)

    // lower priority than the other width constant that say it can be no wider than the view.
    headerCenteredLayoutWidthConstraint.priority = UILayoutPriority(rawValue: 999)
    headerCenteredLayoutWidthConstraint.isActive = true
  }
  
  func setAlignment(toolbarAlignment: HeaderAlignment) {
    // will cause constraints to get re-set
    designObject.headerAlignment = toolbarAlignment
    header.setNeedsLayout()
  }

  func setBackgroundColor(backgroundColor: UIColor) {
    designObject.backgroundColor = backgroundColor
  }
}

extension ScrollingTabPager: PagerDelegate {
  public func reverted(to index: Int) {
    header.setUnderLine(for: IndexPath(item: index, section: 0))
  }

  public func update(_ horizontalPercent: CGFloat, direction: PanDirection, from sourcePageIndex: Int, to destPageIndex: Int) {
    guard let srcAttrs = header.layoutAttributesForItem(at: IndexPath(item: sourcePageIndex, section: 0)),
        let destAttrs = header.layoutAttributesForItem(at: IndexPath(item: destPageIndex, section: 0)) else { return }

    let srcFrame = srcAttrs.frame
    let destFrame = destAttrs.frame

    let totalDistance = destFrame.origin.x - srcFrame.origin.x
    let interpolatedX = srcFrame.origin.x + (totalDistance * horizontalPercent)
    let totalwidthChange = destFrame.width - srcFrame.width
    let interpolatedWidth = srcFrame.width + (totalwidthChange * horizontalPercent)

    if interpolateHeaderColors {
      header.setInterpolatedColorsFor(currentlySelectedPage: sourcePageIndex, andDestinationPage: destPageIndex,
                                      percentProgress: horizontalPercent)
    } else {
      let scrollPosition = getScrollPositionForAlignmentStyle()
      header.selectItem(at: IndexPath(item: destPageIndex, section: 0), animated: false,
                        scrollPosition: scrollPosition)
    }

    header.setUnderLine(x: interpolatedX, width: interpolatedWidth)
  }

  public func viewController(forIndex index: Int) -> UIViewController {
    guard let delegate = delegate else {
      fatalError("must have delegate set up to use this")
    }
    return delegate.viewController(forIndex: index, and: delegateId)
  }
    
    public func didMove(toDestinationViewController: UIViewController, atIndex destIndex: Int, fromSourceViewController: UIViewController, atIndex srcIndex: Int) {
        
        print("\(#function) - srcIndex \(srcIndex) - title \(fromSourceViewController.title ?? ""), destIndex \(destIndex) title \(toDestinationViewController.title ?? "")")
        currentIndex = destIndex
        let scrollPosition = getScrollPositionForAlignmentStyle()
        
        header.selectItem(at: IndexPath(item: currentIndex, section: 0), animated: true,
                            scrollPosition: scrollPosition)
        
        pageSelectedWrapper(index: destIndex, doHaptic: false)
        
        showOrHideArrowAsAppropriate(contentWidth: header.contentSize.width, currIndex: destIndex)
    }

  func pageSelectedWrapper(index: Int, doHaptic: Bool = true) {
    if doHaptic {
      bumpPhone()
    }
    delegate?.pageSelected(forIndex: index, and: delegateId)
  }
}

extension ScrollingTabPager: DesignObjectDelegate {
  
  func didSetHeaderTextColor(color: UIColor) {
    showMoreArrow.arrowColor = color
  }
  
  func didSetHeaderDeselectedTextColor(color: UIColor) {
    
  }
  
  func didSetHeaderHeight(headerHeight: CGFloat) {
    headerHeightConstraint.constant = headerHeight
  }
  
  func didSetShowsHeaderMoreContentArrow(showMoreArrow: Bool) {
    header.showsMoreContentArrow = showMoreArrow
  }
  
  func didSetHeaderUnderline(headerUnderline: Bool) {
    header.hasUnderline = headerUnderline
  }
  
  func didSetHeaderUnderlineColor(headerUnderlineColor: UIColor?) {
    header.underlineColor = headerUnderlineColor
  }
  
  func didSetExtraTabWidth(extraTabWidth: CGFloat) {
    header.minimumInteritemSpacing = extraTabWidth
    header.setNeedsLayout()
  }
  
  func didSetBackgroundColor(color: UIColor) {
    showMoreArrow.gradientColor = color
    header.backgroundColor = color
    header.setNeedsDisplay()
  }

  fileprivate func didSetLeadingAlignment(trailingOffset: CGFloat, leadingOffset: CGFloat) {
    showsMoreArrowRightConstraint.constant -= trailingOffset  // harmless to set this regardless of state.
    headerLeadingConstraint.isActive = true
    headerLeadingConstraint.constant = leadingOffset
    headerCenteringContraint.isActive = false
    headerLeadingLayoutWidthConstraint.constant = -trailingOffset
    headerLeadingLayoutWidthConstraint.isActive = true
    headerCenteredLayoutWidthConstraint.isActive = true
  }
  
  func didSetAlignment(alignment: ScrollingTabPager.HeaderAlignment) {
    switch alignment {
    case .leading(let leadingOffset, let trailingOffset):
      didSetLeadingAlignment(trailingOffset: trailingOffset, leadingOffset: leadingOffset)
    case .leadingStayVisible(let leadingOffset, let trailingOffset):
      didSetLeadingAlignment(trailingOffset: trailingOffset, leadingOffset: leadingOffset)
      header.isScrollEnabled = false
    case .center:
      headerCenteringContraint.isActive = true
      headerLeadingConstraint.isActive = false
      headerLeadingLayoutWidthConstraint.isActive = false
      headerCenteredLayoutWidthConstraint.isActive = true
    }
  }
    
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  
    // just make sure it's up to date
    if titles.count > 0 {
      headerCenteredLayoutWidthConstraint.constant = getHeaderContentWidth(titles: titles)
    }
  }
}

extension ScrollingTabPager: ScrollingTabHeaderLayoutDelegate {
  public var headerInteritemSpacing: CGFloat {
    return header.minimumInteritemSpacing
  }
  
  public var headerHeight: CGFloat {
    return headerHeightConstraint.constant
  }
  
  public func getHeaderContentWidth(titles: [String]) -> CGFloat {
    var width: CGFloat = 0
    let extraTabWidth = designObject.extraTabWidth
  
    for title in titles {
      width += HeaderCell.widthThatFits(title, extraTabWidth: extraTabWidth, color: designObject.headerTextColor,
                                        font: designObject.headerFont)
    }
    let margins = header.scrollingTabHeaderInset.left + header.scrollingTabHeaderInset.right
    width += (CGFloat(titles.count - 1) * headerInteritemSpacing) + margins
    return width
  }
}

extension ScrollingTabPager: ScrollingTabHeaderDelegate {
  public func didLayoutSubviews(contentWidth: CGFloat) {
    showOrHideArrowAsAppropriate(contentWidth: contentWidth, currIndex: pager.currPage )
  }
}

