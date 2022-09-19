//
//  TeamCell.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/5/21.
//

import UIKit

extension ConferenceCell.DivisionCell {
    class TeamCell: UITableViewCell {
        enum Constants {
            static let horzPad: CGFloat = 16.0
            static let logoDim: CGFloat = 64.0
            static let cellHeight: CGFloat = 88.0
            static let backgroundHeight: CGFloat = 80.0
            static let leadingPad: CGFloat = 32.0
            static let trailingPad: CGFloat = 16.0
            static let cornerRadiusFactor: CGFloat = 0.12
            static let borderWidth: CGFloat = 4.0
            static let borderColor = UIColor(red: 1, green: 0.161, blue: 0.161, alpha: 1)
            static let backColor = UIColor(red: 20 / 255, green: 20 / 255, blue: 20 / 255, alpha: 1)
        }

        static let id: String = "TeamCellID"

        let label = UILabel()
        let logo = UIImageView()
        let roundedRectBackground = UIView()

        var team = NFL.Team(name: "Kansas City Chiefs", abbrev: "KC") {
            didSet {
                label.text = team.name
                logo.image = team.logo
            }
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            showSelectionBorder(selected)
        }

        func showSelectionBorder(_ show: Bool) {
            if show {
                roundedRectBackground.layer.borderWidth = Constants.borderWidth
                roundedRectBackground.layer.borderColor = Constants.borderColor.cgColor
            } else {
                roundedRectBackground.layer.borderWidth = 0
                roundedRectBackground.layer.borderColor = UIColor.clear.cgColor
            }
            roundedRectBackground.layer.setNeedsDisplay()
            roundedRectBackground.setNeedsDisplay()
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            roundedRectBackground.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(roundedRectBackground)
            roundedRectBackground.layer.cornerRadius = Constants.cellHeight * Constants.cornerRadiusFactor
            roundedRectBackground.backgroundColor = Constants.backColor

            [logo, label].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                roundedRectBackground.addSubview($0)
            }

            label.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold)
            label.textColor = ExpandingHierarchicalTable.textColor
            label.textAlignment = NSTextAlignment.left
            contentView.backgroundColor = ExpandingHierarchicalTable.backColor

            label.accessibilityIdentifier = "teamname"
            logo.accessibilityIdentifier = "teamlogo"

            NSLayoutConstraint.activate(constraints: [
                roundedRectBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leadingPad),
                roundedRectBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.trailingPad),
                roundedRectBackground.heightAnchor.constraint(equalToConstant: Constants.backgroundHeight),
                roundedRectBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                logo.leadingAnchor.constraint(equalTo: roundedRectBackground.leadingAnchor, constant: Constants.horzPad),
                logo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                logo.heightAnchor.constraint(equalToConstant: Constants.logoDim),
                logo.widthAnchor.constraint(equalToConstant: Constants.logoDim),
                label.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: Constants.horzPad),
                label.centerYAnchor.constraint(equalTo: logo.centerYAnchor),
            ], andSetPriority: UILayoutPriority(rawValue: 999))
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
