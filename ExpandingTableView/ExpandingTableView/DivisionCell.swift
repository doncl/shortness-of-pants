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
    var label: UILabel = UILabel()
    var table: UITableView = UITableView(frame: .zero, style: .grouped)
    let button: UIButton = UIButton(type: .custom)
    
    var division: NFL.Division = NFL.Division(name: "West", teams: NFL.shared.afcWestTeams) {
      didSet {
        label.text = division.name 
      }
    }
    
    var leftPad: CGFloat {
      return 32.0
    }
    
    var tableHeight: NSLayoutConstraint = NSLayoutConstraint()
    var indexPath: IndexPath = IndexPath(item: 0, section: 0)
    
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
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
      toggleSectionVisibility(section: 0)
    }
  }  
}

typealias DivisionCell = ConferenceCell.DivisionCell
extension DivisionCell: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rowCount()
  }
        
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamCell.id, for: indexPath) as? TeamCell,
      indexPath.item < division.teams.count else {
      
      fatalError("shouldn't happen")
    }
    
    cell.team = division.teams[indexPath.item]
    
    return cell
  }
}

extension ConferenceCell.DivisionCell: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("\(#function)")
    delegate?.thumpPhone()
  }
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    print("\(#function)")
    delegate?.thumpPhone()
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return TeamCell.Constants.cellHeight
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return nil
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
}
