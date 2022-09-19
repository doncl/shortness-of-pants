//
//  ExpandingTableCell.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/5/21.
//

import UIKit

class ConferenceCell: UITableViewCell, ExpandingTableCellProtocol {
    enum Constants {
        static let cellHeight: CGFloat = 44.0
    }

    static let id: String = "ConferenceCellID"

    var conference: NFL.Conference = NFL.shared.nfc {
        didSet {
            label.text = conference.name
        }
    }

    var label = UILabel()
    var tableHeight = NSLayoutConstraint()

    var indexPath = IndexPath(item: 0, section: 0)

    weak var delegate: ExpandingCellDelegate?

    var expanded: Bool = false {
        didSet {
            expandedWasSet(expanded)
        }
    }

    var leftPad: CGFloat {
        return 16.0
    }

    let button = UIButton(type: .custom)

    let table = UITableView(frame: .zero, style: .grouped)

    var cellHeight: CGFloat {
        return Constants.cellHeight
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        button.addTarget(self, action: #selector(ConferenceCell.buttonPressed(_:)), for: .touchUpInside)
        table.register(DivisionCell.self, forCellReuseIdentifier: DivisionCell.id)
        table.dataSource = self
        table.delegate = self
        table.reloadData()
        table.sizeToFit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func buttonPressed(_: UIButton) {
        toggleSectionVisibility(section: 0)
    }

    func refresh() {
        if expanded {
            toggleSectionVisibility(section: 0)
        }
    }
}

public extension NSLayoutConstraint {
    class func activate(constraints: [NSLayoutConstraint], andSetPriority priority: UILayoutPriority) {
        constraints.forEach {
            $0.priority = priority
            $0.isActive = true
        }
    }
}

extension ConferenceCell: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        rowCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DivisionCell.id, for: indexPath) as? DivisionCell else {
            fatalError("shouldn't happen")
        }

        let division: NFL.Division

        switch indexPath.item {
        case 0:
            division = conference.east
        case 1:
            division = conference.north
        case 2:
            division = conference.south
        case 3:
            division = conference.west
        default:
            fatalError("should not happen")
        }

        cell.division = division
        cell.indexPath = indexPath
        if let delegate = delegate {
            let expanded = delegate.isExpanded(parentIndexPath: self.indexPath, atChildIndexPath: indexPath)
            cell.expanded = expanded
        }
        cell.delegate = self

        return cell
    }
}

extension ConferenceCell: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRow(atIndexPath: indexPath)
    }

    func heightForRow(atIndexPath indexPath: IndexPath) -> CGFloat {
        guard let delegate = delegate else {
            return ExpandingCellConstants.labelHeight
        }
        let ownIndexPath = self.indexPath
        if delegate.isExpanded(parentIndexPath: ownIndexPath, atChildIndexPath: indexPath) {
            let ht = ExpandingCellConstants.labelHeight + ExpandingCellConstants.topPad + (4 * TeamCell.Constants.cellHeight)
            return ht
        }
        return ExpandingCellConstants.labelHeight
    }

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        thumpPhone()
    }

    func tableView(_: UITableView, didDeselectRowAt _: IndexPath) {
        thumpPhone()
    }

    func tableView(_: UITableView, titleForHeaderInSection _: Int) -> String? {
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension ConferenceCell: ParentExpandingCellDelegate {
    func isChildSelected(parentIndexPath: IndexPath, indexPath: IndexPath) -> Bool {
        guard let grandma = delegate as? GrandParentExpandingCellDelegate else {
            return false
        }
        return grandma.isGrandChildSelected(grandParentIndexPath: self.indexPath,
                                            parentIndexPath: parentIndexPath,
                                            childIndexPath: indexPath)
    }

    func setChildSelected(selected: Bool, parentIndexPath: IndexPath, atChildIndexPath childIndexPath: IndexPath) {
        if let grandma = delegate as? GrandParentExpandingCellDelegate {
            grandma.setGranchildSelected(selected: selected, grandParentIndexPath: indexPath,
                                         parentIndexPath: parentIndexPath, atChildIndexPath: childIndexPath)
        }
    }

    func thumpPhone() {
        delegate?.thumpPhone()
    }

    func toggledChild(expanded _: Bool, indexPath _: IndexPath, childIndexPath _: IndexPath) {
        fatalError("Should not happen in 3 level hierarchy.")
    }

    func toggled(expanded: Bool, indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        let selfIndexPath = self.indexPath
        delegate.toggledChild(expanded: expanded, indexPath: selfIndexPath, childIndexPath: indexPath)
        table.beginUpdates()
        table.endUpdates()
    }

    func isExpanded(parentIndexPath _: IndexPath, atChildIndexPath _: IndexPath) -> Bool {
        fatalError("never called")
    }
}
