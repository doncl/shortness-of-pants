//
//  DivisionCell.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/5/21.
//

import UIKit

extension ConferenceCell {
    class DivisionCell: UITableViewCell, ExpandingTableCellProtocol {
        static let id: String = "TeamCellID"
        var label = UILabel()
        var table = UITableView(frame: .zero, style: .grouped)
        let button = UIButton(type: .custom)

        var division = NFL.Division(name: "West", teams: NFL.shared.afcWestTeams) {
            didSet {
                label.text = division.name
            }
        }

        var leftPad: CGFloat {
            return 32.0
        }

        var tableHeight = NSLayoutConstraint()
        var indexPath = IndexPath(item: 0, section: 0)

        weak var delegate: ExpandingCellDelegate?

        var expanded: Bool = false {
            didSet {
                expandedWasSet(expanded)
            }
        }

        var cellHeight: CGFloat {
            return TeamCell.Constants.cellHeight
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
            selectionStyle = .none
            table.register(TeamCell.self, forCellReuseIdentifier: TeamCell.id)
            table.allowsMultipleSelection = true
            table.dataSource = self
            table.delegate = self
            table.reloadData()
            table.sizeToFit()
            label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.addTarget(self, action: #selector(DivisionCell.buttonPressed(_:)), for: UIControl.Event.touchUpInside)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc func buttonPressed(_: UIButton) {
            toggleSectionVisibility(section: 0)
        }
    }
}

typealias DivisionCell = ConferenceCell.DivisionCell
extension DivisionCell: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return rowCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamCell.id, for: indexPath) as? TeamCell,
              indexPath.item < division.teams.count
        else {
            fatalError("shouldn't happen")
        }

        cell.team = division.teams[indexPath.item]
        if let ma = delegate as? ParentExpandingCellDelegate {
            if ma.isChildSelected(parentIndexPath: self.indexPath, indexPath: indexPath) {
                table.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        cell.setNeedsDisplay()
        return cell
    }
}

extension ConferenceCell.DivisionCell: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ma = delegate as? ParentExpandingCellDelegate {
            ma.setChildSelected(selected: true, parentIndexPath: self.indexPath, atChildIndexPath: indexPath)
        }
    }

    func tableView(_: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let ma = delegate as? ParentExpandingCellDelegate {
            ma.setChildSelected(selected: false, parentIndexPath: self.indexPath, atChildIndexPath: indexPath)
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return TeamCell.Constants.cellHeight
    }

    func tableView(_: UITableView, titleForHeaderInSection _: Int) -> String? {
        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
