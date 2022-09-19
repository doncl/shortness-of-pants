//
//  ViewController.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/5/21.
//

import UIKit

class LeagueVC: UIViewController {
    enum Constants {
        static let topPad: CGFloat = 8.0
        static let allContentTop: CGFloat = 32.0
        static let horzPad: CGFloat = 16.0
        static let topCollapseTargetHeight: CGFloat = 20.0
    }

    let allContent = AllContentButton(leagueName: "NFL")
    let tableView = ExpandingHierarchicalTable()
    let collapseTarget = UIView()
    let leagueLabel = UILabel()
    let button = UIButton(type: UIButton.ButtonType.custom)
    var tableHeight = NSLayoutConstraint()
    var tableBottom = NSLayoutConstraint()

    var expanded: Bool = true {
        didSet {
            expandedWasSet(expanded)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [collapseTarget, allContent, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [leagueLabel, button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            collapseTarget.addSubview($0)
        }

        collapseTarget.backgroundColor = UIColor.clear
        collapseTarget.isUserInteractionEnabled = true
        let collapse = UITapGestureRecognizer(target: self, action: #selector(LeagueVC.expandButtonTapped(_:)))
        collapseTarget.addGestureRecognizer(collapse)

        leagueLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        leagueLabel.textColor = ExpandingHierarchicalTable.textColor
        leagueLabel.text = "NFL"

        button.setImage(UIImage(systemName: "minus"), for: UIControl.State.normal)
        button.tintColor = ExpandingHierarchicalTable.textColor

        view.backgroundColor = ExpandingHierarchicalTable.backColor
        tableView.backgroundColor = ExpandingHierarchicalTable.backColor

        tableHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableBottom = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            collapseTarget.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horzPad),
            collapseTarget.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topPad),
            collapseTarget.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horzPad),
            collapseTarget.heightAnchor.constraint(equalToConstant: Constants.topCollapseTargetHeight),

            leagueLabel.topAnchor.constraint(equalTo: collapseTarget.topAnchor),
            leagueLabel.leadingAnchor.constraint(equalTo: collapseTarget.leadingAnchor),

            button.centerYAnchor.constraint(equalTo: leagueLabel.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: collapseTarget.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: ExpandingCellConstants.buttonDim),
            button.widthAnchor.constraint(equalToConstant: ExpandingCellConstants.buttonDim),

            allContent.topAnchor.constraint(equalTo: collapseTarget.bottomAnchor, constant: Constants.allContentTop),
            allContent.heightAnchor.constraint(equalToConstant: AllContentButton.Constants.height),
            allContent.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horzPad),
            allContent.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horzPad),

            tableView.topAnchor.constraint(equalTo: allContent.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            tableBottom,
        ])

        button.addTarget(self, action: #selector(LeagueVC.expandButtonTapped(_:)), for: UIControl.Event.touchUpInside)
        tableView.expandingDelegate = self
        allContent.addTarget(self, action: #selector(LeagueVC.allContentButtonTapped(_:)), for: UIControl.Event.touchUpInside)
    }
}

// MARK: Actions

extension LeagueVC {
    @objc func expandButtonTapped(_: UIButton) {
        expanded = !expanded
    }

    @objc func allContentButtonTapped(_: AllContentButton) {
        expanded = false
        tableView.selectAllChildren()
    }

    func expandedWasSet(_ expand: Bool) {
        if expand {
            button.setImage(UIImage(systemName: "minus"), for: .normal)
            expandTable()
        } else {
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            contractTable()
        }
    }

    private func expandTable() {
        tableHeight.isActive = false
        tableBottom.isActive = true
        tableView.refresh()
    }

    private func contractTable() {
        tableBottom.isActive = false
        tableHeight.isActive = true
    }
}

// MARK: AllContentButton

extension LeagueVC {
    class AllContentButton: UIButton {
        enum Constants {
            static let height: CGFloat = 80.0
            static let leadingPad: CGFloat = 16.0
            static let logoDim: CGFloat = 64.0
            static let cornerRadiusFactor: CGFloat = 0.14
            static let borderWidth: CGFloat = 4.0
            static let font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        }

        let logo = UIImageView(image: UIImage(named: "nfllogo")!)
        let label = UILabel()

        init(leagueName: String) {
            super.init(frame: CGRect.zero)
            [logo, label].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                addSubview($0)
            }

            logo.contentMode = UIView.ContentMode.scaleAspectFit
            backgroundColor = TeamCell.Constants.backColor
            label.textColor = ExpandingHierarchicalTable.redColor
            label.textAlignment = NSTextAlignment.left
            label.text = "All Content from \(leagueName.uppercased())"
            label.font = Constants.font
            layer.cornerRadius = Constants.height * Constants.cornerRadiusFactor

            NSLayoutConstraint.activate([
                logo.centerYAnchor.constraint(equalTo: centerYAnchor),
                logo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leadingPad),
                logo.widthAnchor.constraint(equalToConstant: Constants.logoDim),
                logo.heightAnchor.constraint(equalToConstant: Constants.logoDim),

                label.centerYAnchor.constraint(equalTo: logo.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: Constants.leadingPad),
            ])

            addTarget(self, action: #selector(AllContentButton.buttonTouched(_:)), for: UIControl.Event.touchDown)
            showBorder(show: false)
        }

        func showBorder(show: Bool) {
            layer.borderColor = show ? ExpandingHierarchicalTable.redColor.cgColor : UIColor.clear.cgColor
            layer.borderWidth = Constants.borderWidth
            layer.setNeedsDisplay()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc func buttonTouched(_: UIButton) {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                self.layer.opacity = 0.6
            }, completion: { _ in
                self.layer.opacity = 1
                self.showBorder(show: true)
                self.isEnabled = false
            })
        }
    }
}

extension LeagueVC: ExpandingHierarchicalTableDelegate {
    func someoneWasDeselected() {
        allContent.showBorder(show: false)
        allContent.isEnabled = true
    }

    func collapse() {
        expanded = false
    }
}
