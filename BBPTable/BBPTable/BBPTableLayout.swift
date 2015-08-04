//
//  BBPTableLayout.swift
//  BBPTable
//
//  Created by Don Clore on 8/3/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

class BBPTableLayout: UICollectionViewLayout {
    //MARK: static constants
    // TODO:  These possibly should be exposed as properties on the object, with a default
    // value that works for most cases.
    static let cellVerticalPadding: Double = 15.0
    static let cellHorizontalPadding: Double = 15.0
    
    //MARK: Instance data
    var columnWidths: Array<CGFloat> = []
    var rowHeight: CGFloat?
    var tableHeight: CGFloat?
    var tableWidth: CGFloat?
    var rows: Int?
    var columns: Int?

    //MARK: UICollectionViewLayout implementation.
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) ->
        UICollectionViewLayoutAttributes! {
        var attrs = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attrs.frame = frameForItemAtIndexPath(indexPath)
        return attrs
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attrsArray: [UICollectionViewLayoutAttributes] = []
        
        for (var i = 0; i < columns; i++) {
            for (var j = 0; j < rows; j++) {
                var cellRect = getCellRect(i, row: j)
                if (CGRectIntersectsRect(cellRect, rect)) {
                    var indexPath = NSIndexPath(forItem:i, inSection:j)
                    var attrs = layoutAttributesForItemAtIndexPath(indexPath)
                    attrsArray.append(attrs)
                }
            }
        }
        return attrsArray
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: tableWidth!, height: tableHeight!)
    }
    
    private func frameForItemAtIndexPath(indexPath:NSIndexPath) -> CGRect {
        // section is row, row is column.
        return getCellRect(indexPath.row, row: indexPath.section)
    }
    
    private func getCellRect(column: Int, row: Int) -> CGRect {
        var x = CGFloat(0.0)
        var y = CGFloat(row) * rowHeight!
        var height = rowHeight!
        
        // The column widths are variable values, so they have to be added up.
        for (var i = 0; i < column; i++) {
            x += columnWidths[i]
        }
        var width = columnWidths[column]
        
        return CGRect(x:x, y:y, width:width, height:height)
    }
    
    //MARK: CalculateCellSizes implementation.
    func calculateCellSizes(model: BBPTableModel) {
        tableWidth = 0.0
        columns = model.numberOfColumns
        rows = model.numberOfRows
        rowHeight = 0.0
        
        for (var i = 0; i < columns; i++) {
            var columnSize = calculateColumnSize(model, columnIndex: i, rowCount: rows!)
            columnWidths.append(columnSize.width)
            if columnSize.height > rowHeight {
                rowHeight = columnSize.height
            }
            tableWidth! += columnSize.width
        }
        tableHeight = rowHeight! * CGFloat(rows!)
    }
    
    private func calculateColumnSize(
        model: BBPTableModel,
        columnIndex: Int,
        rowCount: Int) -> CGSize {
        var largestWidth = CGFloat(0.0)
        var largestHeight = CGFloat(0.0)
            
        for (var i = 0;  i < rowCount; i++) {
            var cellData = model.dataAtLocation(i, column: columnIndex)
            var type = model.getCellType(i)
            var cellInfo = BBPTableCell.getCellInfoForTypeOfCell(type)
            var font = UIFont(name: cellInfo.fontName!, size: cellInfo.fontSize!)
            
            // The Interwebs suggests we'll get better and more accurate required lengths for
            // strings by replacing the spaces with a capital letter glyph.
            var newString = cellData.stringByReplacingOccurrencesOfString(" ", withString: "X")
            var attributes = [NSFontAttributeName : font!]
            
            var rect = NSString(string: newString).boundingRectWithSize(
                CGSize(width:DBL_MAX, height:DBL_MAX),
                options:NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes:attributes,
                context:nil)
            
            if rect.size.height > largestHeight {
                largestHeight = rect.size.height
            }
            if rect.size.width > largestWidth {
                largestWidth = rect.size.width
            }
            
        }
        return CGSize(
            width:largestWidth + CGFloat((BBPTableLayout.cellHorizontalPadding * 2.0)),
            height:largestHeight + CGFloat((BBPTableLayout.cellVerticalPadding * 2.0)))
    }
}

