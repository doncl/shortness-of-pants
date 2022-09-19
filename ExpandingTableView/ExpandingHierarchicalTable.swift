//
//  ExpandingNFLTable.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/6/21.
//

import UIKit

typealias TeamCell = ConferenceCell.DivisionCell.TeamCell

protocol ExpandingHierarchicalTableDelegate: AnyObject {
    func collapse()
    func someoneWasDeselected()
}

class ExpandingHierarchicalTable: UITableView {
    enum Constants {
        static let headerHeight: CGFloat = 44.0
        static let headerLeading: CGFloat = 16.0
        static let pickYourTeamsFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
    }

    static let backColor = UIColor.black
    static let textColor = UIColor.white
    static let redColor = UIColor.red

    private lazy var haptic: UINotificationFeedbackGenerator = {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        return gen
    }()

    struct ConferenceCellExpansionState {
        var expanded: Bool
        var childExpansionStates: [Bool] = Array(repeating: false, count: 4)
    }

    var expandedState: [IndexPath: ConferenceCellExpansionState] = [
        IndexPath(item: 0, section: 0): ConferenceCellExpansionState(expanded: true),
        IndexPath(item: 1, section: 0): ConferenceCellExpansionState(expanded: false),
    ]

    var teamSelectionStates: [[[Bool]]] = Array(repeating: Array(repeating: Array(repeating: false, count: 4), count: 4), count: 2)

    let header = PickYourTeamsView()
    weak var expandingDelegate: ExpandingHierarchicalTableDelegate?

    init() {
        super.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        register(ConferenceCell.self, forCellReuseIdentifier: ConferenceCell.id)
        delegate = self
        dataSource = self
        separatorStyle = .none
        backgroundColor = ExpandingHierarchicalTable.backColor
        allowsSelection = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func footerTapped(_: CollapseAllFooterView) {
        thumpPhone()
        expandingDelegate?.collapse()
    }
}

// MARK: UITableViewDataSource

extension ExpandingHierarchicalTable: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConferenceCell.id, for: indexPath) as? ConferenceCell,
              let conferenceType = NFL.ConferenceType(rawValue: indexPath.item)
        else {
            fatalError("should not happen")
        }

        let conference: NFL.Conference
        switch conferenceType {
        case .nfc:
            conference = NFL.shared.nfc
        case .afc:
            conference = NFL.shared.afc
        }
        if let conferenceCellState = expandedState[indexPath] {
            cell.expanded = conferenceCellState.expanded
        }
        cell.conference = conference
        cell.indexPath = indexPath
        cell.delegate = self
        cell.setNeedsLayout()
        return cell
    }
}

// MARK: UITableViewDelegate

extension ExpandingHierarchicalTable: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let conferenceCellState = expandedState[indexPath], conferenceCellState.expanded {
            let childExpandedCount = CGFloat(conferenceCellState.childExpansionStates.filter { $0 == true }.count)

            let height = ExpandingCellConstants.labelHeight + ExpandingCellConstants.topPad +
                (4 * ConferenceCell.Constants.cellHeight) +
                childExpandedCount * (ExpandingCellConstants.topPad + TeamCell.Constants.cellHeight * 4)

            return height
        }
        return ExpandingCellConstants.labelHeight
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        return header
    }

    func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        let footer = CollapseAllFooterView()
        footer.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        footer.addTarget(self, action: #selector(ExpandingHierarchicalTable.footerTapped(_:)), for: UIControl.Event.touchUpInside)
        return footer
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return Constants.headerHeight
    }
}

extension ExpandingHierarchicalTable: GrandParentExpandingCellDelegate {
    func isGrandChildSelected(grandParentIndexPath: IndexPath, parentIndexPath: IndexPath, childIndexPath: IndexPath) -> Bool {
        guard checkHierarchySanity(grandParentIndexPath: grandParentIndexPath, parentIndexPath: parentIndexPath,
                                   childIndexPath: childIndexPath)
        else {
            return false
        }
        return teamSelectionStates[grandParentIndexPath.item][parentIndexPath.item][childIndexPath.item]
    }

    private func checkHierarchySanity(grandParentIndexPath: IndexPath, parentIndexPath: IndexPath, childIndexPath: IndexPath) -> Bool {
        guard teamSelectionStates.count > grandParentIndexPath.item else {
            return false
        }
        let conferenceSelectionStates = teamSelectionStates[grandParentIndexPath.item]
        guard conferenceSelectionStates.count > parentIndexPath.item else {
            return false
        }
        let divisionSelectionStates = conferenceSelectionStates[parentIndexPath.item]
        guard divisionSelectionStates.count > childIndexPath.item else {
            return false
        }
        return true
    }

    func setGranchildSelected(selected: Bool, grandParentIndexPath: IndexPath, parentIndexPath: IndexPath,
                              atChildIndexPath childIndexPath: IndexPath)
    {
        guard teamSelectionStates.count > grandParentIndexPath.item else {
            return
        }
        let conferenceSelectionStates = teamSelectionStates[grandParentIndexPath.item]
        guard conferenceSelectionStates.count > parentIndexPath.item else {
            return
        }
        let divisionSelectionStates = conferenceSelectionStates[parentIndexPath.item]
        guard divisionSelectionStates.count > childIndexPath.item else {
            return
        }

        teamSelectionStates[grandParentIndexPath.item][parentIndexPath.item][childIndexPath.item] = selected

        // We need to let the parent know that somebody got deselected, so it can remove highlighting from the all content button.
        if let expandingDelegate = expandingDelegate, !selected {
            expandingDelegate.someoneWasDeselected()
        }
    }

    func refresh() {
        reloadData()
        expandedState[IndexPath(item: 0, section: 0)]?.expanded = false
        let numRows = numberOfRows(inSection: 0)
        for i in 0 ..< numRows {
            let indexPath = IndexPath(item: i, section: 0)
            guard let cellWithTable = cellForRow(at: indexPath) as? ConferenceCell else {
                continue
            }
            cellWithTable.refresh()
        }
    }

    func thumpPhone() {
        haptic.notificationOccurred(.success)
    }

    func isExpanded(parentIndexPath: IndexPath, atChildIndexPath childIndexPath: IndexPath) -> Bool {
        guard let conferenceCellState = expandedState[parentIndexPath] else {
            return false
        }
        guard conferenceCellState.childExpansionStates.count > childIndexPath.item else {
            return false
        }
        return conferenceCellState.childExpansionStates[childIndexPath.item]
    }

    private func setChildExpandedState(to expanded: Bool, forIndexPath indexPath: IndexPath, atChildIndex childIndexPath: IndexPath) {
        guard let state = expandedState[indexPath], state.childExpansionStates.count > childIndexPath.item else {
            return
        }

        expandedState[indexPath]?.childExpansionStates[childIndexPath.item] = expanded
    }

    func selectAllChildren() {
        for i in 0 ..< teamSelectionStates.count {
            for j in 0 ..< teamSelectionStates[i].count {
                for k in 0 ..< teamSelectionStates[i][j].count {
                    teamSelectionStates[i][j][k] = true
                }
            }
        }
        beginUpdates()
        endUpdates()
        thumpPhone()
    }

    func toggledChild(expanded: Bool, indexPath: IndexPath, childIndexPath: IndexPath) {
        setChildExpandedState(to: expanded, forIndexPath: indexPath, atChildIndex: childIndexPath)
        beginUpdates()
        endUpdates()
        thumpPhone()
    }

    func toggled(expanded: Bool, indexPath: IndexPath) {
        expandedState[indexPath]?.expanded = expanded

        beginUpdates()
        endUpdates()
        thumpPhone()
    }
}

extension ExpandingHierarchicalTable {
    class PickYourTeamsView: UIView {
        let pickYourTeams = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)

            pickYourTeams.backgroundColor = ExpandingHierarchicalTable.backColor
            pickYourTeams.textColor = ExpandingHierarchicalTable.textColor
            pickYourTeams.text = "Pick Your Teams"
            pickYourTeams.textAlignment = NSTextAlignment.left
            pickYourTeams.font = Constants.pickYourTeamsFont

            pickYourTeams.translatesAutoresizingMaskIntoConstraints = false
            addSubview(pickYourTeams)
            NSLayoutConstraint.activate([
                pickYourTeams.bottomAnchor.constraint(equalTo: bottomAnchor),
                pickYourTeams.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.headerLeading),
            ])
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension ExpandingHierarchicalTable {
    class CollapseAllFooterView: UIControl {
        enum Constants {
            static let font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
            static let color = UIColor.white.withAlphaComponent(0.5)
            static let collapseArrowDim: CGFloat = 8.0
            static let collapseLeading: CGFloat = 6.0
        }

        let button = UIButton(type: UIButton.ButtonType.custom)
        let collapse = UIImageView(image: UIImage(named: "collapsetable")!)

        override init(frame: CGRect) {
            super.init(frame: frame)
            button.tintColor = Constants.color
            button.setTitleColor(Constants.color, for: .normal)
            backgroundColor = ExpandingHierarchicalTable.backColor
            button.setTitle("Hide Teams", for: .normal)

            [button, collapse].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                addSubview($0)
            }

            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: centerXAnchor),
                button.centerYAnchor.constraint(equalTo: centerYAnchor),
                collapse.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: Constants.collapseLeading),
                collapse.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                collapse.heightAnchor.constraint(equalToConstant: Constants.collapseArrowDim),
                collapse.widthAnchor.constraint(equalToConstant: Constants.collapseArrowDim),
            ])
            button.sizeToFit()
            button.addTarget(self, action: #selector(CollapseAllFooterView.buttonTapped(_:)), for: UIControl.Event.touchUpInside)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc func buttonTapped(_: UIButton) {
            sendActions(for: UIControl.Event.touchUpInside)
        }
    }
}
