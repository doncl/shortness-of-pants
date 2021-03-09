//
//  Pager.swift
//  ScrollingTabPager
//
//  Created by Don Clore on 3/8/21.
//
import UIKit

public protocol PagerDelegate: class {
    func viewController(forIndex index: Int) -> UIViewController
    func reverted(to index: Int)
    func update(_ horizontalPercent: CGFloat, direction: PanDirection, from sourcePageIndex: Int, to destPageIndex: Int)
    func didMove(to viewControllerIndex: Int)
}

public enum PanDirection {
    case backward
    case forward
}

public enum PanAxis {
    case vertical
    case horizontal
}

public class PanAxisGestureRecognizer: UIPanGestureRecognizer {
    
  let axis: PanAxis
  
  public init(axis: PanAxis, target: AnyObject, action: Selector) {
      self.axis = axis
      super.init(target: target, action: action)
  }
    
  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if state == .began {
            let vel = velocity(in: view)
            switch axis {
            case .horizontal where abs(vel.y) > abs(vel.x):
                state = .cancelled
            case .vertical where abs(vel.x) > abs(vel.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}

// This is just for panning back (i.e. custom uinavigationcontroller gesture)
public class PanBackGestureRecognizer: UIPanGestureRecognizer {
  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)
    if state == .began {
      let vel = velocity(in: view)
      if abs(vel.y) > abs(vel.x) {
        state = .cancelled
      } else if vel.x < 0 {
        state = .cancelled
      }
    }
  }
}

public class Pager: UIViewController {
    let verticalSwipeLabel: String = "verticalSwipeGesture"
    let panLabel: String = "panGesture"
    let velocityThreshold: CGFloat = 400.0
    var currPage: Int = 0
    var pageWidth: CGFloat = 0 {
      didSet {
        //Global.log.debug("\(#function) - new value = \(self.pageWidth)")
      }
    }
    var xOffset: CGFloat = 0
    var animationDuration = 0.30
    var animatedDestinationBounds: CGRect = .zero
    var oldTranslationOffset: CGFloat = 0
    var precedingVC: UIViewController?
    var currentVC: UIViewController?
    var subsequentVC: UIViewController?
    let rubicon: CGFloat = 0.5   // we've Crossed The Rubicon
    var pan: PanAxisGestureRecognizer!
    weak var delegate: PagerDelegate?
  
    private var contentWidth: CGFloat = 0
    private var maxPageXOffset: CGFloat = 0
    
    var isEnabled: Bool = true {
        didSet {
            pan.isEnabled = isEnabled
        }
    }

    var numPages: Int = 0 {
        didSet {
            updateContentWidth()
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
        secondPhaseInitializer()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        secondPhaseInitializer()
    }

    private func secondPhaseInitializer() {

    }

    private func updateContentWidth() {
        //Global.log.debug("\(#function) - currPage = \(currPage)")
        if let view = view {
            pageWidth = view.bounds.width
        }
        contentWidth = pageWidth * CGFloat(numPages)
        maxPageXOffset = contentWidth - pageWidth
      
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "ScrollingTabbedPagerView"
        pan = PanAxisGestureRecognizer(axis: PanAxis.horizontal, target: self, action: #selector(Pager.handlePan(_:)))
        pan.delegate = self
        pan.accessibilityLabel = panLabel
        view.addGestureRecognizer(pan)
    }
  
    func addPriorityGestures(_ gestures: [UIGestureRecognizer]) {
        for gr in gestures {
            pan.require(toFail: gr)
        }
    }
    
    private func calculateReplaceVCFrame(replacementVC: UIViewController,
                                         vcToEject: UIViewController?,
                                         state: Pager.PagePosition) {

        let x: CGFloat = CGFloat(currPage) * pageWidth
        var replacementFrame = CGRect(x: x, y: 0, width: pageWidth, height: view.bounds.height)
        if state == .previousvc {
            replacementFrame = replacementFrame.translateHorizontally(by: -pageWidth)
        } else if state == .subsequentvc {
            replacementFrame = replacementFrame.translateHorizontally(by: pageWidth)
        }
        replacementVC.view.frame = replacementFrame
    }

    private func parentTheNewVC(replacementVC: UIViewController, vcToEject: UIViewController?, state: PagePosition) {
        calculateReplaceVCFrame(replacementVC: replacementVC, vcToEject: vcToEject, state: state)
        addChild(replacementVC)
        view.addSubview(replacementVC.view)
        replacementVC.didMove(toParent: self)
    }

    private func replaceVC(replacementVC: UIViewController, vcToEject: UIViewController?, state: PagePosition) {
        parentTheNewVC(replacementVC: replacementVC, vcToEject: vcToEject, state: state)

        if let vcToEject = vcToEject {
            removeOldVC(vcToEject: vcToEject)
        }
    }

    fileprivate func removeOldVC(vcToEject: UIViewController) {
        guard vcToEject.parent != nil else { return }
        vcToEject.didMove(toParent: nil)
        vcToEject.view.removeFromSuperview()
        vcToEject.removeFromParent()
    }

    private enum PagePosition {
        case beforeloadedvcs
        case previousvc
        case currentvc
        case subsequentvc
        case afterloadedvcs

        var inRetained3PageRange: Bool {
            return [.previousvc, .currentvc, .subsequentvc].contains(self)
        }
    }

    private func getPagePosition(for index: Int) -> PagePosition {
        if index < (currPage - 1) {
            return .beforeloadedvcs
        } else if index == currPage - 1 {
            return .previousvc
        } else if index == currPage {
            return .currentvc
        } else if index == currPage + 1 {
            return .subsequentvc
        } else {
            return .afterloadedvcs
        }
    }

    func reload(at index: Int) {
        guard numPages > index, let delegate = delegate else { return }
        let stateOfVCToLoad = getPagePosition(for: index)
        guard stateOfVCToLoad.inRetained3PageRange else { return }

        let replacementVC = delegate.viewController(forIndex: index)
        replacementVC.loadViewIfNeeded()

        switch stateOfVCToLoad {
        case .previousvc:
            replaceVC(replacementVC: replacementVC, vcToEject: precedingVC, state: stateOfVCToLoad)
            precedingVC = replacementVC
        case .currentvc:
            replaceVC(replacementVC: replacementVC, vcToEject: currentVC, state: stateOfVCToLoad)
            currentVC = replacementVC
        case .subsequentvc:
            replaceVC(replacementVC: replacementVC, vcToEject: subsequentVC, state: stateOfVCToLoad)
            subsequentVC = replacementVC
        default:
            fatalError("something wrong with logic - should never happen")
        }

        replacementVC.view.setNeedsDisplay()
    }

    func insert(at index: Int) {
        guard index <= numPages, let _ = delegate else { return }
        let insertPosition = getPagePosition(for: index)
        defer {
            numPages += 1
            layEverythingOut()
        }

        switch insertPosition {
        case .beforeloadedvcs, .afterloadedvcs:
            return // nothing to do here.
        case .previousvc:
            reload(at: index - 1)
            reload(at: index)
            reload(at: index + 1)
        case .currentvc:
            reload(at: index)
            reload(at: index + 1)
        case .subsequentvc:
            reload(at: index + 1)
        }
    }

    func remove(at index: Int) {
        guard index < numPages, let _ = delegate else {
            return
        }
        defer {
            numPages -= 1
        }
        let removePosition = getPagePosition(for: index)
        switch removePosition {

        case .beforeloadedvcs, .afterloadedvcs:
            return // nothing to do.
        case .previousvc:
            if let prev = precedingVC {
                removeOldVC(vcToEject: prev)
                self.precedingVC = nil
            }
            if index > 1 {
                reload(at: index - 1)
            }
        case .subsequentvc:
            if let sub = subsequentVC {
                removeOldVC(vcToEject: sub)
                self.subsequentVC = nil
            }
            if index < numPages - 2 {
                reload(at: index + 1)
            }

        case .currentvc:
            let curr = currentVC
            if index == 0 {
                scrollTo(1)
            } else {
                scrollTo(index - 1)
            }
            if let curr = curr {
                removeOldVC(vcToEject: curr)
            }
        }

        layoutViewControllers()
    }
    
    private func layoutViewControllers() {
        //Global.log.debug("\(#function) - currPage = \(currPage)")
        let x: CGFloat = CGFloat(currPage) * pageWidth
        xOffset = x
        view.bounds.origin.x = x
        if let precedingVC = precedingVC {
            precedingVC.loadViewIfNeeded()
            precedingVC.view.frame = CGRect(x: x - pageWidth, y: 0, width: pageWidth, height: view.bounds.height)
            precedingVC.view.setNeedsDisplay()
        }
        if let currentVC = currentVC {
            currentVC.loadViewIfNeeded()
            currentVC.view.frame = CGRect(x: x, y: 0, width: pageWidth, height: view.bounds.height)
            currentVC.view.setNeedsDisplay()
        }
        if let subsequentVC = subsequentVC {
            subsequentVC.loadViewIfNeeded()
            subsequentVC.view.frame = CGRect(x: x + pageWidth, y: 0, width: pageWidth, height: view.bounds.height)
            subsequentVC.view.setNeedsDisplay()
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layEverythingOut()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layEverythingOut()
    }

    private func layEverythingOut() {
        //Global.log.debug("\(#function) - currPage = \(currPage)")
        updateContentWidth()
        layoutViewControllers()
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.layEverythingOut()
        }, completion: nil)
    }
  
    override public func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
        }, completion: { ctxt in
          self.layEverythingOut()
        })
    }
}

// MARK: Motion
extension Pager {
    private func scrollTo(_ viewControllerIndex: Int, animated: Bool = true) {
        guard let delegate = delegate else { return }
        guard viewControllerIndex != currPage else { return }

        let direction: PanDirection = currPage < viewControllerIndex ? .forward : .backward

        let viewControllerToScrollTo: UIViewController = delegate.viewController(forIndex: viewControllerIndex)
        let viewX: CGFloat = pageWidth * CGFloat(viewControllerIndex)
        let animFromX: CGFloat = viewX + (direction == .forward ? pageWidth : -pageWidth)
        let initialRect: CGRect = CGRect(x: animFromX, y: 0, width: pageWidth, height: view.bounds.height)
        let finalRect: CGRect = CGRect(x: viewX, y: 0, width: pageWidth, height: view.bounds.height)
        let currentViewRect = view.bounds
        let rectToPutCurrentVCIn: CGRect = currentViewRect.translateHorizontally(by: direction == PanDirection.forward ? -pageWidth: pageWidth)

        viewControllerToScrollTo.view.frame = initialRect
        viewControllerToScrollTo.loadViewIfNeeded()
        addChild(viewControllerToScrollTo)
        view.addSubview(viewControllerToScrollTo.view)
        viewControllerToScrollTo.didMove(toParent: self)

        let duration: TimeInterval = animated ? 0.25 : 0

        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.currentVC?.view.frame = rectToPutCurrentVCIn
            viewControllerToScrollTo.view.frame = currentViewRect
        }, completion: { _ in
            self.view.bounds.origin.x = viewX
            viewControllerToScrollTo.view.frame = finalRect
            self.currPage = viewControllerIndex
            if let current = self.currentVC {
                current.didMove(toParent: nil)
                current.view.removeFromSuperview()
                current.removeFromParent()
                self.currentVC = nil
            }
            self.currentVC = viewControllerToScrollTo

            self.xOffset = viewX
            if let next = self.subsequentVC {
                if next != viewControllerToScrollTo {
                    self.removeOldVC(vcToEject: next)
                }
                self.subsequentVC = nil
            }

            if let prev = self.precedingVC {
                if prev != viewControllerToScrollTo {
                    self.removeOldVC(vcToEject: prev)
                }
                self.precedingVC = nil
            }

            if viewControllerIndex > 0 {
                self.reload(at: viewControllerIndex - 1)
            }
            if viewControllerIndex < (self.numPages - 1) {
                self.reload(at: viewControllerIndex + 1)
            }
        })
    }

    func select(viewControllerIndex: Int, animated: Bool = true) {
        guard let _ = delegate,
            viewControllerIndex >= 0,
            viewControllerIndex < numPages,
            viewControllerIndex != currPage else { return }
      
        scrollTo(viewControllerIndex, animated: animated)
    }

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let translationOffset = -translation.x
        let direction: PanDirection = translation.x > 0 ? .backward : .forward

        switch recognizer.state {
        case .began:
            view.layer.removeAllAnimations()
            oldTranslationOffset = 0
        case .changed:
            calculateXOffsetFromInteractiveProgress(translationOffset, direction)
        case .ended, .cancelled:
            calculateXOffsetFromInteractiveProgress(translationOffset, direction)
            let velocity = recognizer.velocity(in: view).x
            oldTranslationOffset = 0
            startSnapAnimation(velocity: velocity, direction: direction)

        case .possible, .failed:
            break
        @unknown default:
          break
      }
    }

    fileprivate func calculateXOffsetFromInteractiveProgress(_ translationOffset: CGFloat, _ direction: PanDirection) {
        let incrementalTransitionOffset = translationOffset - oldTranslationOffset
        oldTranslationOffset = translationOffset
        xOffset += incrementalTransitionOffset
        notifyPercentInteractiveProgress(direction: direction)
        view.bounds.origin.x = xOffset
    }

    fileprivate func notifyPercentInteractiveProgress(direction: PanDirection) {
        let modulo = xOffset.truncatingRemainder(dividingBy: pageWidth)
        let percent: CGFloat
        let fromPage: Int = currPage
        let toPage: Int
        if direction == .forward {
            guard fromPage < numPages - 1 else { return }
            percent = abs(modulo / pageWidth)
            toPage = fromPage + 1
        } else {
            guard fromPage > 0 else { return }
            percent = abs((pageWidth - modulo) / pageWidth)
            toPage = fromPage - 1
        }
        delegate?.update(percent, direction: direction, from: fromPage, to: toPage)
    }

    private func startSnapAnimation(velocity: CGFloat, direction: PanDirection) {
        guard view.bounds.origin.x.truncatingRemainder(dividingBy: pageWidth) != 0.0 else { return }
        let distance = distanceToNearestPageBoundary(velocity: velocity, direction: direction)
        makeAnimation(for: distance)
    }

    fileprivate func makeAnimation(for distance: CGFloat) {
        let animation = CABasicAnimation(keyPath: "bounds")
        let originalBounds = view.layer.bounds
        let newX = max(min(maxPageXOffset, originalBounds.origin.x + distance), 0)
        animatedDestinationBounds = CGRect(x: newX, y: originalBounds.origin.y, width: originalBounds.width, height: originalBounds.height)
        animation.fromValue = NSValue(cgRect: originalBounds)
        animation.toValue = NSValue(cgRect: animatedDestinationBounds)
        animation.duration = animationDuration
        animation.delegate = self
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(animation, forKey: nil)
    }

    fileprivate func weAreGoodToSnapInPanDirection(
        _ crossedVelocityThreshold: Bool,
        _ distanceToDestination: CGFloat) -> Bool {

        return crossedVelocityThreshold || distanceToDestination < pageWidth * (1.0 - rubicon)
    }

    private func distanceToNearestPageBoundary(velocity: CGFloat, direction: PanDirection) -> CGFloat {
        guard let delegate = delegate else { return 0 }
        assert(currentVC != nil, "bad logic - currentVC must never be nil")
        assert(currPage > 0 || precedingVC == nil, "bad logic - if currentPage == 0, preceeding VC must nil")
        assert(currPage < numPages - 1 || subsequentVC == nil, "bad logic - if we're at the right end, subsequentVC must be nil")
        let absVelocity = abs(velocity)
        let distances = calculatePageDistances(direction: direction)
        let crossedVelocityThreshold = absVelocity > velocityThreshold
        if direction == .backward {
            if weAreGoodToSnapInPanDirection(crossedVelocityThreshold, distances.distanceToDest)
                && currPage > 0 {
                // Changing index backwards
                currPage += -1
                let r: CGRect = CGRect(x: CGFloat(currPage) * pageWidth, y: 0, width: pageWidth, height: view.bounds.height)
                if let sub = subsequentVC {
                    removeOldVC(vcToEject: sub)
                    self.subsequentVC = nil
                }
                subsequentVC = currentVC
                if precedingVC == nil {
                    currentVC = addViewController(at: currPage, initialFrame: r)
                } else {
                    currentVC = precedingVC
                    precedingVC = nil
                }
                if currPage > 0 {
                    if precedingVC == nil {
                        precedingVC = addViewController(at: currPage - 1, initialFrame: r.translateHorizontally(by: -pageWidth))
                    }
                } else {
                    precedingVC = nil
                }
                delegate.didMove(to: currPage)
                return -distances.distanceToDest  // complete backwards.
            } else {
                delegate.reverted(to: currPage)
                return distances.distanceFromStart  // normal reversion
            }
        } else {
            if weAreGoodToSnapInPanDirection(crossedVelocityThreshold, distances.distanceToDest) &&
                currPage < (numPages - 1) {

                currPage += 1

                if let prev = precedingVC {
                    removeOldVC(vcToEject: prev)
                    self.precedingVC = nil
                }
                precedingVC = currentVC
                let r: CGRect = CGRect(x: CGFloat(currPage) * pageWidth, y: 0, width: pageWidth, height: view.bounds.height)
                if subsequentVC == nil {
                    currentVC = addViewController(at: currPage, initialFrame: r)
                } else {
                    currentVC = subsequentVC
                    subsequentVC = nil
                }
                if currPage < (numPages - 1) {
                    if subsequentVC == nil {
                        subsequentVC = addViewController(at: currPage + 1, initialFrame: r.translateHorizontally(by: pageWidth))
                    }
                } else {
                    subsequentVC = nil
                }
                    
                delegate.didMove(to: currPage)
                return distances.distanceToDest  // complete forwards
            } else {
                delegate.reverted(to: currPage)
                return -distances.distanceFromStart // normal reversion
            }
        }
    }

    private func calculatePageDistances(direction: PanDirection) -> (distanceFromStart: CGFloat, distanceToDest: CGFloat) {
        let currentX = view.bounds.origin.x
        let xOfPageWereHeadedTo: CGFloat
        let xOfPageWereComingFrom: CGFloat = CGFloat(currPage) * pageWidth
        if direction == .forward {
            xOfPageWereHeadedTo = CGFloat(currPage + 1) * pageWidth
            return (distanceFromStart: (currentX - xOfPageWereComingFrom), distanceToDest: (xOfPageWereHeadedTo - currentX))
        } else {
            xOfPageWereHeadedTo = CGFloat(currPage - 1) * pageWidth
            return (distanceFromStart: (xOfPageWereComingFrom - currentX), distanceToDest: (currentX - xOfPageWereHeadedTo))
        }
    }
    
    private func addViewController(at index: Int, initialFrame: CGRect) -> UIViewController {
        assert(delegate != nil, "Should never happen")
        let vc = delegate!.viewController(forIndex: index)
        vc.loadViewIfNeeded()
        vc.view.frame = initialFrame
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        return vc
    }
}

extension Pager: CAAnimationDelegate {
  public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        view.layer.removeAllAnimations()
        view.bounds = animatedDestinationBounds
        xOffset = animatedDestinationBounds.origin.x
        layoutViewControllers()
    }
}

private extension CGRect {
    func translateHorizontally(by xOffset: CGFloat) -> CGRect {
        return CGRect(x: origin.x + xOffset, y: origin.y, width: width, height: height)
    }
}

extension Pager: UIGestureRecognizerDelegate {
}
