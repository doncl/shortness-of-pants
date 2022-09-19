//
//  ExpandingCellDelegate.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/8/21.
//

import UIKit

protocol ExpandingCellDelegate: AnyObject {
    func toggledChild(expanded: Bool, indexPath: IndexPath, childIndexPath: IndexPath)
    func toggled(expanded: Bool, indexPath: IndexPath)
    func isExpanded(parentIndexPath: IndexPath, atChildIndexPath childIndexPath: IndexPath) -> Bool
    func thumpPhone()
}

protocol ParentExpandingCellDelegate: ExpandingCellDelegate {
    func setChildSelected(selected: Bool, parentIndexPath: IndexPath, atChildIndexPath childIndexPath: IndexPath)
    func isChildSelected(parentIndexPath: IndexPath, indexPath: IndexPath) -> Bool
}

protocol GrandParentExpandingCellDelegate: ExpandingCellDelegate {
    func isGrandChildSelected(grandParentIndexPath: IndexPath, parentIndexPath: IndexPath, childIndexPath: IndexPath) -> Bool
    func setGranchildSelected(selected: Bool, grandParentIndexPath: IndexPath, parentIndexPath: IndexPath,
                              atChildIndexPath childIndexPath: IndexPath)
}
