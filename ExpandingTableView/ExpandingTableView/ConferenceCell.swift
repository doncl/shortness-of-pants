//
//  ExpandingTableCell.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/5/21.
//

import UIKit

protocol ExpandingCellDelegate: class {
  func toggledChild(expanded: Bool, indexPath: IndexPath, childIndexPath: IndexPath)
  func toggled(expanded: Bool, indexPath: IndexPath)
  func isExpanded(parentIndexPath: IndexPath, atChildIndexPath childIndexPath: IndexPath) -> Bool
  func thumpPhone()
}

class ConferenceCell: UITableViewCell, ExpandingTableCellProtocol {
  struct Constants {
    static let cellHeight: CGFloat = 44.0
  }
  static let id: String = "ConferenceCellID"
  
  var conference: NFL.Conference = NFL.shared.nfc {
    didSet {
      label.text = conference.name
    }
  }
  
  var label: UILabel = UILabel()
  var tableHeight: NSLayoutConstraint = NSLayoutConstraint()
  
  var indexPath: IndexPath = IndexPath(item: 0, section: 0)
  
  weak var delegate: ExpandingCellDelegate?
  
  var expanded: Bool = false {
    didSet {
      expandedWasSet(expanded)
    }
  }
  
  var leftPad: CGFloat {
    return 16.0
  }
  
  let button: UIButton = UIButton(type: .custom)
  
  let table: UITableView = UITableView(frame: .zero, style: .grouped)
  
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
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func buttonPressed(_ sender: UIButton) {
    toggleSectionVisibility(section: 0)
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
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
      cell.expanded = delegate.isExpanded(parentIndexPath: self.indexPath, atChildIndexPath: indexPath)
    }
    cell.delegate = self

    return cell
  }
}

extension ConferenceCell: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return nil
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
}

extension ConferenceCell: ExpandingCellDelegate {
  func thumpPhone() {
    delegate?.thumpPhone()
  }
  
  func toggledChild(expanded: Bool, indexPath: IndexPath, childIndexPath: IndexPath) {
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
  
  func isExpanded(parentIndexPath: IndexPath, atChildIndexPath childIndexPath: IndexPath) -> Bool {
    fatalError("never called")
  }
}
