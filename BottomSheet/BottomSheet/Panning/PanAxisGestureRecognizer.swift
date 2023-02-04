//
//  PanAxisGestureRecognizer.swift
//  BottomSheet
//
//  Created by Don Clore on 2/4/23.
//

import UIKit

public enum PanAxis {
  case vertical
  case horizontal
}

/// It just makes the later logic easier if this pan gesture is limited to vertical or
/// horizontal
public class PanAxisGestureRecognizer: UIPanGestureRecognizer {

  let axis: PanAxis

  public init(axis: PanAxis, target: AnyObject, action: Selector) {
    self.axis = axis
    super.init(target: target, action: action)
  }

  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
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

