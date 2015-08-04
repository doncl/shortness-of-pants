//
//  BBPTableCellCollectionViewCell.swift
//  BBPTable
//
//  Created by Don Clore on 8/3/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

enum CellType : Int {
    case ColumnHeading = 1
    case DataOdd = 2
    case DataEven = 4
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
        label.setContentHuggingPriority(0, forAxis:.Horizontal)
        label.setContentCompressionResistancePriority(1000, forAxis:.Horizontal)
        label.numberOfLines = 0
        setupCellInfo(.DataOdd)
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(label)
        setupConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func initializeCellProperties(props: CellProperties) {
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
    func setCellText(text: String) {
        label.text = text
    }
    
    func setupConstraints() {
        
        var cellLabel = label
        
        var viewDict = ["cellLabel" : cellLabel]
        var horizontalConstraints =
        NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cellLabel]-0-|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: viewDict)
        
        let centeringXConstraint =
        NSLayoutConstraint(item: self, attribute:.CenterX,
            relatedBy:.Equal, toItem:label,
            attribute:.CenterX, multiplier:1.0, constant:0.0)
        
        let centeringYConstraint =
        NSLayoutConstraint(item: self, attribute:.CenterY,
            relatedBy:.Equal, toItem:label,
            attribute:.CenterY, multiplier:1.0, constant:0.0)
        
        let centeringConstraints = [centeringXConstraint, centeringYConstraint]
        
        addConstraints(horizontalConstraints)
        NSLayoutConstraint.activateConstraints(horizontalConstraints)
        NSLayoutConstraint.activateConstraints(centeringConstraints)
    }
    
    func setupCellInfo(cellType: CellType) {
        var ci = BBPTableCell.getCellInfoForTypeOfCell(cellType)
        layer.borderWidth = ci.borderWidth!
        layer.borderColor = ci.borderColor!.CGColor
        label.baselineAdjustment = ci.baselineAdjustment!
        label.backgroundColor = ci.backgroundColor
        backgroundColor = ci.backgroundColor
        label.textAlignment = ci.textAlignment!
        label.font = UIFont(name: ci.fontName!, size: ci.fontSize!)
        label.textColor = ci.textColor!
    }
    
    static func getCellInfoForTypeOfCell(cellType: CellType) -> CellInfo {
        var info = CellInfo()
        info.borderColor = BBPTableCell.borderColor
        info.borderWidth = BBPTableCell.borderWidth
        info.baselineAdjustment = .AlignCenters
        info.textAlignment = .Center
        
        // TODO: a Swift switch statement might be better here.
        if cellType == .DataOdd || cellType == .DataEven {
            info.textColor = BBPTableCell.dataCellTextColor
            info.fontSize = BBPTableCell.dataCellFontSize
            info.fontName = BBPTableCell.dataCellFontName
            info.backgroundColor = cellType == .DataOdd ?
                BBPTableCell.oddRowColor : BBPTableCell.evenRowColor
        } else if cellType == .ColumnHeading {
            info.backgroundColor = BBPTableCell.headerColor
            info.textColor = BBPTableCell.headerTextColor
            info.fontSize = BBPTableCell.headerFontSize
            info.fontName = BBPTableCell.headerFontName
        } else {
            fatalError("Unknown cellType \(cellType)")
        }
        
        return info
    }
    
    // MARK: overriden methods

}
