//
//  ExpandingTableCellProtocol.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/6/21.
//

import UIKit

protocol ExpandingTableCellProtocol: AnyObject {
    var leftPad: CGFloat { get }
    var label: UILabel { get }
    var indexPath: IndexPath { get }
    var expanded: Bool { get set }
    var tableHeight: NSLayoutConstraint { get set }
    var delegate: ExpandingCellDelegate? { get }
    var table: UITableView { get }
    var button: UIButton { get }
    var cellHeight: CGFloat { get }

    func expandedWasSet(_ expand: Bool)
    func calcTableHeight(numRows: Int) -> CGFloat
    func rowCount() -> Int
    func toggleSectionVisibility(section: Int)
    func setup()
}

enum ExpandingCellConstants {
    static let topPad: CGFloat = 8.0
    static let horzPad: CGFloat = 8.0
    static let buttonDim: CGFloat = 16.0
    static let labelHeight: CGFloat = 44.0
}

extension ExpandingTableCellProtocol where Self: UITableViewCell {
    func setup() {
        contentView.backgroundColor = ExpandingHierarchicalTable.backColor
        backgroundColor = ExpandingHierarchicalTable.backColor
        [label, button, table].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        label.textColor = ExpandingHierarchicalTable.textColor
        table.isScrollEnabled = false
        table.rowHeight = UITableView.automaticDimension
        let estimated = calcTableHeight(numRows: 4) + ExpandingCellConstants.labelHeight + ExpandingCellConstants.topPad
        table.estimatedRowHeight = estimated
        tableHeight = table.heightAnchor.constraint(equalToConstant: 0)
        tableHeight.priority = UILayoutPriority(rawValue: 999)
        tableHeight.isActive = true
        table.backgroundColor = ExpandingHierarchicalTable.backColor

        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ExpandingCellConstants.topPad).isActive = true
        table.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        table.topAnchor.constraint(equalTo: label.bottomAnchor, constant: ExpandingCellConstants.topPad).isActive = true

        NSLayoutConstraint.activate(constraints: [
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftPad),
            button.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ExpandingCellConstants.horzPad * 2),
            button.heightAnchor.constraint(equalToConstant: ExpandingCellConstants.buttonDim),
            button.widthAnchor.constraint(equalToConstant: ExpandingCellConstants.buttonDim),
            table.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: ExpandingCellConstants.labelHeight),
        ], andSetPriority: UILayoutPriority(rawValue: 999))

        button.tintColor = ExpandingHierarchicalTable.textColor
        table.sectionHeaderHeight = CGFloat.leastNormalMagnitude
    }

    func calcTableHeight(numRows: Int) -> CGFloat {
        return cellHeight * CGFloat(numRows) + table.contentInset.top + table.contentInset.bottom
    }

    func expandedWasSet(_ expand: Bool) {
        if expand {
            button.setImage(UIImage(systemName: "minus"), for: .normal)
            tableHeight.constant = calcTableHeight(numRows: 4)
        } else {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            tableHeight.constant = 0
        }
        setNeedsLayout()
    }

    func rowCount() -> Int {
        return expanded ? 4 : 0
    }

    func toggleSectionVisibility(section: Int) {
        expanded = !expanded

        var indexPaths: [IndexPath] = []
        for i in 0 ..< 4 {
            let ip = IndexPath(item: i, section: section)
            indexPaths.append(ip)
        }

        if expanded {
            table.insertRows(at: indexPaths, with: .fade)
        } else {
            table.deleteRows(at: indexPaths, with: .fade)
            table.contentSize = .zero
        }
        delegate?.toggled(expanded: expanded, indexPath: indexPath)
    }
}
