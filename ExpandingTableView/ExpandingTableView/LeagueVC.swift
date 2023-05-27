//
//  ViewController.swift
//  ExpandingTableView
//
//  Created by Don Clore on 2/5/21.
//

import UIKit

class LeagueVC: UIViewController {
  struct Constants {
    static let topPad: CGFloat = 8.0
    static let allContentTop: CGFloat = 32.0
    static let horzPad: CGFloat = 16.0
  }
  
  let allContent: AllContentButton = AllContentButton(leagueName: "NFL")
  let tableView: ExpandingNFLTable = ExpandingNFLTable()
  let leagueLabel: UILabel = UILabel()
  let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
  var tableHeight: NSLayoutConstraint = NSLayoutConstraint()
  var tableBottom: NSLayoutConstraint = NSLayoutConstraint()
  
  var expanded: Bool = true {
    didSet {
      expandedWasSet(expanded)
    }
  }
      
  override func viewDidLoad() {
    super.viewDidLoad()
    
    [leagueLabel, button, allContent, tableView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }
    
    leagueLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
    leagueLabel.textColor = ExpandingNFLTable.textColor
    leagueLabel.text = "NFL"
    
    button.setImage(UIImage(systemName: "minus"), for: UIControl.State.normal)
    button.tintColor = ExpandingNFLTable.textColor
    
    view.backgroundColor = ExpandingNFLTable.backColor
    tableView.backgroundColor = ExpandingNFLTable.backColor
    
    tableHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
    tableBottom = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    
    NSLayoutConstraint.activate([
      leagueLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topPad),
      leagueLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horzPad),
      
      button.centerYAnchor.constraint(equalTo: leagueLabel.centerYAnchor),
      button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horzPad),
      button.heightAnchor.constraint(equalToConstant: ExpandingCellConstants.buttonDim),
      button.widthAnchor.constraint(equalToConstant: ExpandingCellConstants.buttonDim),
      
      allContent.topAnchor.constraint(equalTo: leagueLabel.bottomAnchor, constant: Constants.allContentTop),
      allContent.heightAnchor.constraint(equalToConstant: AllContentButton.Constants.height),
      allContent.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horzPad),
      allContent.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horzPad),
      
      tableView.topAnchor.constraint(equalTo: allContent.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      
      tableBottom,
    ])
    
    button.addTarget(self, action: #selector(LeagueVC.expandButtonTapped(_:)), for: UIControl.Event.touchUpInside)
  }
}

// MARK: Actions
extension LeagueVC {
  @objc func expandButtonTapped(_ sender: UIButton) {
    expanded = !expanded
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
    self.tableHeight.isActive = false
    self.tableBottom.isActive = true
  }
  
  private func contractTable() {
    self.tableBottom.isActive = false
    self.tableHeight.isActive = true
  }
}

// MARK: AllContentButton
extension LeagueVC {
  class AllContentButton: UIButton {
    struct Constants {
      static let height: CGFloat = 80.0
      static let leadingPad: CGFloat = 16.0
      static let logoDim: CGFloat = 64.0
      static let cornerRadiusFactor: CGFloat = 0.14
      static let borderWidth: CGFloat = 4.0
      static let font: UIFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
    }
    let logo: UIImageView = UIImageView(image: UIImage(named: "nfllogo")!)
    let label: UILabel = UILabel()
    
    init(leagueName: String) {
      super.init(frame: CGRect.zero)
      [logo, label].forEach {
        $0.translatesAutoresizingMaskIntoConstraints = false
        addSubview($0)
      }
      
      logo.contentMode = UIView.ContentMode.scaleAspectFit
      backgroundColor = ExpandingNFLTable.backColor
      label.textColor = ExpandingNFLTable.redColor
      label.textAlignment = NSTextAlignment.left
      label.text = "All Content from \(leagueName.uppercased())"
      label.font = Constants.font
      
      layer.cornerRadius = Constants.height * Constants.cornerRadiusFactor
      layer.borderColor = ExpandingNFLTable.redColor.cgColor
      layer.borderWidth = Constants.borderWidth
      
      NSLayoutConstraint.activate([
        logo.centerYAnchor.constraint(equalTo: centerYAnchor),
        logo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leadingPad),
        logo.widthAnchor.constraint(equalToConstant: Constants.logoDim),
        logo.heightAnchor.constraint(equalToConstant: Constants.logoDim),
        
        label.centerYAnchor.constraint(equalTo: logo.centerYAnchor),
        label.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: Constants.leadingPad),
      ])
      
      addTarget(self, action: #selector(AllContentButton.buttonTouched(_:)), for: UIControl.Event.touchDown)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTouched(_ sender: UIButton) {
      UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
        self.layer.opacity = 0.6
      }, completion: { _ in
        self.layer.opacity = 1
      })
    }
  }
}
