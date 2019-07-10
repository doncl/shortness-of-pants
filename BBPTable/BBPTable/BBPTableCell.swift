//
//  BBPTableCellCollectionViewCell.swift
//  BBPTable
//
//  Created by Don Clore on 8/3/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

enum CellType : Int {
    case columnHeading = 1
    case dataOdd = 2
    case dataEven = 4
}

class BBPTableCell: UICollectionViewCell {

    // MARK: Default cell values

    // Header characteristics.
    static var headerFontName: String = "HelveticaNeue-Bold"
    static var headerFontSize: CGFloat = 12.0
    static var headerTextColor: UIColor = UIColor(red:0.976, green: 0.976, blue: 0.976,
            alpha: 1.0)

    static var headerColor: UIColor = UIColor(red:0.271, green: 0.271, blue: 0.271, alpha: 1.0)

    // Data cell characteristics.
    static var dataCellFontName: String = "HelveticaNeue"
    static var dataCellFontSize: CGFloat = 10.0
    static var dataCellTextColor: UIColor = UIColor(red:0.271, green:0.271, blue:0.271,
            alpha:1.0)

    static var oddRowColor: UIColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
    static var evenRowColor: UIColor = UIColor(red:0.976, green:0.976, blue:0.976, alpha: 1.0)
    static var borderColor: UIColor = UIColor(red:223.0/255.0, green:223.0/255.0,
            blue:223.0/255.0, alpha:1.0)

    static var borderWidth: CGFloat = 0.5

    // MARK: Cell instance data
    var label : UILabel!

    // MARK: initializers
    override init(frame: CGRect) {
        super.init(frame: frame)

        label = UILabel(frame: self.contentView.bounds)
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 0), for:.horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for:.horizontal)
        label.numberOfLines = 0
        setupCellInfo(.dataOdd)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func initializeCellProperties(_ props: CellProperties) {
        headerColor = props.headerColor!
        
        headerFontName = props.headerFontName!
        headerFontSize = props.headerFontSize!
        headerTextColor = props.headerTextColor!
        
        dataCellFontName = props.dataCellFontName!
        dataCellFontSize = props.dataCellFontSize!
        dataCellTextColor = props.dataCellTextColor!
        
        oddRowColor = props.oddRowColor!
        evenRowColor = props.evenRowColor!
        borderColor = props.borderColor!
        borderWidth = props.borderWidth!
    }
    
    // MARK: instance methods
    func setCellText(_ text: String) {
        label.text = text
    }
    
    func setupConstraints() {
        let viewDict = ["cellLabel" : label! as Any]
        let horizontalConstraints =
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cellLabel]-0-|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDict)
        
        let centeringXConstraint =
        NSLayoutConstraint(item: self, attribute:.centerX,
            relatedBy:.equal, toItem:label,
            attribute:.centerX, multiplier:1.0, constant:0.0)
        
        let centeringYConstraint =
        NSLayoutConstraint(item: self, attribute:.centerY,
            relatedBy:.equal, toItem:label,
            attribute:.centerY, multiplier:1.0, constant:0.0)
        
        let centeringConstraints = [centeringXConstraint, centeringYConstraint]
        
        addConstraints(horizontalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        NSLayoutConstraint.activate(centeringConstraints)
    }
    
    func setupCellInfo(_ cellType: CellType) {
        let ci = BBPTableCell.getCellInfoForTypeOfCell(cellType)
        layer.borderWidth = ci.borderWidth
        layer.borderColor = ci.borderColor.cgColor
        label.baselineAdjustment = ci.baselineAdjustment
        label.backgroundColor = ci.backgroundColor
        backgroundColor = ci.backgroundColor
        label.textAlignment = ci.textAlignment
        label.font = UIFont(name: ci.fontName, size: ci.fontSize)
        label.textColor = ci.textColor
    }
    
    static func getCellInfoForTypeOfCell(_ cellType: CellType) -> CellInfo {
      let fontSize: CGFloat
      let textColor: UIColor
      let fontName: String
      let backgroundColor: UIColor
      
      switch cellType {
        
      case .columnHeading:
        fontSize = BBPTableCell.headerFontSize
        textColor = BBPTableCell.headerTextColor
        fontName = BBPTableCell.headerFontName
        backgroundColor = BBPTableCell.headerColor
        
      case .dataOdd, .dataEven:
        fontSize = BBPTableCell.dataCellFontSize
        fontName = BBPTableCell.dataCellFontName
        backgroundColor = cellType == .dataOdd ? BBPTableCell.oddRowColor : BBPTableCell.evenRowColor
        textColor = BBPTableCell.dataCellTextColor
      }
      
      return CellInfo(fontSize: fontSize, fontName: fontName, textColor: textColor,
                      backgroundColor: backgroundColor, borderColor: BBPTableCell.borderColor,
                      borderWidth: BBPTableCell.borderWidth, textAlignment: NSTextAlignment.center,
                      baselineAdjustment: UIBaselineAdjustment.alignCenters)
    }    
}
