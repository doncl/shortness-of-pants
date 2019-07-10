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
    override func layoutAttributesForItem(at indexPath: IndexPath) ->
        UICollectionViewLayoutAttributes? {
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attrs.frame = frameForItemAtIndexPath(indexPath)
        return attrs
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrsArray: [UICollectionViewLayoutAttributes] = []
      
        guard let columns = columns, let rows = rows else {
          return attrsArray
        }
        for i in 0..<columns {
            for j in 0..<rows {
                let cellRect = getCellRect(i, row: j)
                if (cellRect.intersects(rect)) {
                    let indexPath = IndexPath(item:i, section:j)
                    let attrs = layoutAttributesForItem(at: indexPath)
                    attrsArray.append(attrs!)
                }
            }
        }
        return attrsArray
    }
    
    override var collectionViewContentSize : CGSize {
        return CGSize(width: tableWidth!, height: tableHeight!)
    }
    
    fileprivate func frameForItemAtIndexPath(_ indexPath:IndexPath) -> CGRect {
        // section is row, row is column.
        return getCellRect(indexPath.row, row: indexPath.section)
    }
    
    fileprivate func getCellRect(_ column: Int, row: Int) -> CGRect {
        var x = CGFloat(0.0)
        let y = CGFloat(row) * rowHeight!
        let height = rowHeight!
        
        // The column widths are variable values, so they have to be added up.
        for i in 0..<column {
            x += columnWidths[i]
        }
        let width = columnWidths[column]
        
        return CGRect(x:x, y:y, width:width, height:height)
    }
    
    //MARK: CalculateCellSizes implementation.
    func calculateCellSizes(_ model: BBPTableModel) {
        tableWidth = 0.0
        columns = model.numberOfColumns
        rows = model.numberOfRows
        rowHeight = 0.0
      
        guard let columns = columns else {
          return
        }
      
        for i in 0..<columns {
            let columnSize = calculateColumnSize(model, columnIndex: i, rowCount: rows!)
            columnWidths.append(columnSize.width)
            assert(rowHeight != nil)
            if columnSize.height > rowHeight! {
                rowHeight = columnSize.height
            }
            tableWidth! += columnSize.width
        }
        tableHeight = rowHeight! * CGFloat(rows!)
    }
    
    fileprivate func calculateColumnSize(
        _ model: BBPTableModel,
        columnIndex: Int,
        rowCount: Int) -> CGSize {
        var largestWidth = CGFloat(0.0)
        var largestHeight = CGFloat(0.0)
            
        for i in 0..<rowCount {
            let cellData = model.dataAtLocation(i, column: columnIndex)
            let type = model.getCellType(i)
            let cellInfo = BBPTableCell.getCellInfoForTypeOfCell(type)            
            let font = UIFont(name: cellInfo.fontName, size: cellInfo.fontSize)
            
            // The Interwebs suggests we'll get better and more accurate required lengths for
            // strings by replacing the spaces with a capital letter glyph.
            let newString = cellData.replacingOccurrences(of: " ", with: "X")
            let attributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font) : font!]
            
            let rect = NSString(string: newString).boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height:CGFloat.greatestFiniteMagnitude),
                options:NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes:convertToOptionalNSAttributedStringKeyDictionary(attributes),
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


fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
  return input.rawValue
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
