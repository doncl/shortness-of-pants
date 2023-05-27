//
//  ExpandingNFLTable.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/6/21.
//

import UIKit

typealias TeamCell = ConferenceCell.DivisionCell.TeamCell

class ExpandingNFLTable: UITableView {
  struct Constants {
    static let headerHeight: CGFloat = 44.0
    static let headerLeading: CGFloat = 16.0
    static let pickYourTeamsFont: UIFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
  }

  static let backColor: UIColor = UIColor.black
  static let textColor: UIColor = UIColor.white
  static let redColor: UIColor = UIColor.red
  
  lazy private var haptic : UINotificationFeedbackGenerator = {
    let gen = UINotificationFeedbackGenerator()
    gen.prepare()
    return gen
  }()
    
  struct ConferenceCellState {
    var expanded: Bool
    var childExpansionStates: [Bool] = Array(repeating: false, count: 4)
  }
  
  var expandedState: [IndexPath: ConferenceCellState] = [
    IndexPath(item: 0, section:0) : ConferenceCellState(expanded: true),
    IndexPath(item: 1, section: 0) : ConferenceCellState(expanded: false),
  ]
  
  let header: PickYourTeamsView = PickYourTeamsView()
  
  init() {
    super.init(frame: CGRect.zero, style: UITableView.Style.grouped)        
    register(ConferenceCell.self, forCellReuseIdentifier: ConferenceCell.id)
    delegate = self
    dataSource = self
    separatorStyle = .none
    backgroundColor = ExpandingNFLTable.backColor
    allowsSelection = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: UITableViewDataSource
extension ExpandingNFLTable: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ConferenceCell.id, for: indexPath) as? ConferenceCell,
      let conferenceType = NFL.ConferenceType(rawValue: indexPath.item) else {
      
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
extension ExpandingNFLTable: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let conferenceCellState = expandedState[indexPath], conferenceCellState.expanded {
      let childExpandedCount = CGFloat(conferenceCellState.childExpansionStates.filter({$0 == true}).count)
      
      let height = ExpandingCellConstants.labelHeight + ExpandingCellConstants.topPad +
        (4 * ConferenceCell.Constants.cellHeight) +
        childExpandedCount * (ExpandingCellConstants.topPad + TeamCell.Constants.cellHeight * 4)
      
      return height
    }
    return ExpandingCellConstants.labelHeight
  }
    
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section == 0 else {
      return nil
    }
    return header
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return Constants.headerHeight
  }
}

extension ExpandingNFLTable: ExpandingCellDelegate {
  func thumpPhone() {
    haptic.notificationOccurred(.success)
  }
  
  func isExpanded(parentIndexPath: IndexPath, atChildIndexPath childIndexPath: IndexPath) -> Bool {
    guard let conferenceCellState = expandedState[parentIndexPath], conferenceCellState.expanded else {
      return false
    }
    guard conferenceCellState.childExpansionStates.count > childIndexPath.item else {
      return false
    }
    return conferenceCellState.childExpansionStates[childIndexPath.item]
  }
  
  func toggledChild(expanded: Bool, indexPath: IndexPath, childIndexPath: IndexPath) {
    expandedState[indexPath]?.childExpansionStates[childIndexPath.item] = expanded
    beginUpdates()
    endUpdates()
    haptic.notificationOccurred(.success)
  }
  func toggled(expanded: Bool, indexPath: IndexPath) {
    expandedState[indexPath]?.expanded = expanded
    
    beginUpdates()
    endUpdates()
    haptic.notificationOccurred(.success)
  }
}

extension ExpandingNFLTable {
  class PickYourTeamsView: UIView {
    let pickYourTeams: UILabel = UILabel()
    override init(frame: CGRect) {
      super.init(frame: frame)
      
      pickYourTeams.backgroundColor = ExpandingNFLTable.backColor
      pickYourTeams.textColor = ExpandingNFLTable.textColor
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
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}
