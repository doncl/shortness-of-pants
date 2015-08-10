//
//  BBPTableModel.swift
//  BBPTable
//
//  Created by Don Clore on 8/3/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

class BBPTableModel: NSObject {

    static let regex: NSRegularExpression =
    NSRegularExpression(pattern:"<table.*?>(.*?)<\\/table>",
            options:.CaseInsensitive | .DotMatchesLineSeparators,
            error:nil)!

    static let headRegex: NSRegularExpression =
    NSRegularExpression(pattern:"<thead.*?>(.*?)<\\/thead>",
            options:.CaseInsensitive | .DotMatchesLineSeparators,
            error:nil)!

    static let bodyRegex: NSRegularExpression =
    NSRegularExpression(pattern:"<tbody.*?>(.*?)<\\/tbody>",
            options:.CaseInsensitive | .DotMatchesLineSeparators,
            error:nil)!

    static let rowRegex: NSRegularExpression =
    NSRegularExpression(pattern:"<tr.*?>(.*?)<\\/tr>",
            options:.CaseInsensitive | .DotMatchesLineSeparators,
            error:nil)!

    static let dataRegex: NSRegularExpression =
    NSRegularExpression(pattern:"<td><a.*?>(.*?)<\\/a><\\/td>|<td>(.*?)<\\/td>",
            options:.CaseInsensitive | .DotMatchesLineSeparators,
            error:nil)!

    var rowData: Array<Array<String>> = [[]]
    
    override init() {
        super.init()
    }

    var numberOfRows: Int {
        get {
            return rowData.count
        }
    }

    var numberOfColumns: Int {
        get {
            return rowData[0].count
        }
    }

    func dataAtLocation(row: Int, column: Int) -> String {
        return rowData[row][column];
    }

    func getCellType(row: Int) -> CellType {
        if (row == 0) {
            return .ColumnHeading
        }
        return ((row + 1) % 2) == 0 ? .DataEven : .DataOdd
    }

    func buildFromText(text: String) ->Bool {
        var colCount: Int = 0
        rowData = Array<Array<String>>()

        if let tableText = strMatch(BBPTableModel.regex, text: text, index:1) {
            if let head = strMatch(BBPTableModel.headRegex, text: tableText, index:1) {
                if let headRow = strMatch(BBPTableModel.rowRegex, text:head, index:1) {
                    let headCells = strsMatch(BBPTableModel.dataRegex, text:headRow, index:2)
                    if headCells.count == 0 {
                        return false
                    }
                    colCount = headCells.count
                    var headArray = Array<String>()
                    for headCell in headCells {
                        headArray.append(headCell)
                    }
                    rowData.append(headArray)
                }
            }
            if let body = strMatch(BBPTableModel.bodyRegex, text: tableText, index:1) {
                let bodyRows = strsMatch(BBPTableModel.rowRegex, text:body, index:1)
                for bodyRow in bodyRows {
                    let bodyCells = strsMatch(BBPTableModel.dataRegex, text:bodyRow, index:1)
                    if bodyCells.count != colCount {
                        println("Error - expected row to be \(colCount) cells, not " +
                                "\(bodyCells.count)")
                        return false
                    }
                    var dataRow = Array<String>()
                    for bodyCell in bodyCells {
                        dataRow.append(bodyCell)
                    }
                    rowData.append(dataRow)
                }
            }
        }

        return true
    }

    func strMatch(pattern: NSRegularExpression, text:String, index:Int) -> String? {
        var textToSearch = text.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())

        var result = pattern.firstMatchInString(textToSearch, options:nil,
                    range:NSMakeRange(0, count(textToSearch)))!

        let matchRange = result.range
        if matchRange.location == NSNotFound {
            return nil
        }

        var matchGroupRange = result.rangeAtIndex(index)
        let nsString = textToSearch as NSString
        var str =  nsString.substringWithRange(matchGroupRange)
        return str
    }

    func strsMatch(pattern: NSRegularExpression, text:String, index: Int)
                    -> Array<String> {

        var strings:Array<String> = []
        var textToSearch = text.stringByTrimmingCharactersInSet(
        NSCharacterSet.whitespaceAndNewlineCharacterSet())

        var matches = pattern.matchesInString(textToSearch, options:nil,
                range:NSMakeRange(0, count(textToSearch)))

        for match in matches as! [NSTextCheckingResult] {
            var count = match.numberOfRanges
            var matchRange = match.rangeAtIndex(index)
            if matchRange.location == NSNotFound {
               matchRange = match.rangeAtIndex(index + 1)
               if matchRange.location == NSNotFound {
                   fatalError("dang")
               }
            }

            let nsString = textToSearch as NSString
            var str = nsString.substringWithRange(matchRange)
            strings.append(str)
        }
        return strings
    }

    //
    //  This method partitions the data model into two sub-datamodels, one for the 'fixed'
    //  columns, and one for the floating, 'non-fixed' columns to the right of it.  By doing it
    //  this way, the same UICollectionViewDataSource, UICollectionViewDelegate, and 
    //  UICollectionViewLayout-derived object (BBPTableLayout) can work for each part of the
    //  table identically.
    //
    static func buildFixedAndNonFixedModels(srcModel: BBPTableModel,
                                            inout fixedColumnModel: BBPTableModel?,
                                            inout nonFixedColumnModel: BBPTableModel?,
                                            fixedColumnCount: Int) {
        var rows = srcModel.numberOfRows
        var cols = srcModel.numberOfColumns
        
        fixedColumnModel = BBPTableModel()
        nonFixedColumnModel = BBPTableModel()
                                                
        var fixedOuterArray = Array<Array<String>>()
        var nonFixedOuterArray = Array<Array<String>>()
                                                
        for (var i = 0; i < rows; i++) {
            var srcRow = srcModel.rowData[i];
            var fixedRow = srcRow[0...fixedColumnCount - 1]
            var nonFixedRow = srcRow[fixedColumnCount...srcRow.count - 1]
            
            fixedOuterArray.append(Array(fixedRow))
            nonFixedOuterArray.append(Array(nonFixedRow))
        }
        fixedColumnModel!.rowData = fixedOuterArray
        nonFixedColumnModel!.rowData = nonFixedOuterArray
    }

}
