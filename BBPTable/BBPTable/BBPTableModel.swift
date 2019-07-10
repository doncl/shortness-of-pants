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
    try! NSRegularExpression(pattern:"<table.*?>(.*?)<\\/table>",
            options:[.caseInsensitive, .dotMatchesLineSeparators])

    static let headRegex: NSRegularExpression =
    try! NSRegularExpression(pattern:"<thead.*?>(.*?)<\\/thead>",
            options:[.caseInsensitive, .dotMatchesLineSeparators])

    static let bodyRegex: NSRegularExpression =
    try! NSRegularExpression(pattern:"<tbody.*?>(.*?)<\\/tbody>",
            options:[.caseInsensitive, .dotMatchesLineSeparators])

    static let rowRegex: NSRegularExpression =
    try! NSRegularExpression(pattern:"<tr.*?>(.*?)<\\/tr>",
            options:[.caseInsensitive, .dotMatchesLineSeparators])

    static let dataRegex: NSRegularExpression =
    try! NSRegularExpression(pattern:"<td><a.*?>(.*?)<\\/a><\\/td>|<td>(.*?)<\\/td>",
            options:[.caseInsensitive, .dotMatchesLineSeparators])

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

    func dataAtLocation(_ row: Int, column: Int) -> String {
        return rowData[row][column];
    }

    func getCellType(_ row: Int) -> CellType {
        if (row == 0) {
            return .columnHeading
        }
        return ((row + 1) % 2) == 0 ? .dataEven : .dataOdd
    }

    func buildFromText(_ text: String) ->Bool {
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
                        print("Error - expected row to be \(colCount) cells, not " +
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

    func strMatch(_ pattern: NSRegularExpression, text:String, index:Int) -> String? {
        let textToSearch = text.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)

        let result = pattern.firstMatch(in: textToSearch, options:[],
                    range:NSMakeRange(0, textToSearch.count))!

        let matchRange = result.range
        if matchRange.location == NSNotFound {
            return nil
        }

        let matchGroupRange = result.range(at: index)
        let nsString = textToSearch as NSString
        let str =  nsString.substring(with: matchGroupRange)
        return str
    }

    func strsMatch(_ pattern: NSRegularExpression, text:String, index: Int)
                    -> Array<String> {

        var strings:Array<String> = []
        let textToSearch = text.trimmingCharacters(
        in: CharacterSet.whitespacesAndNewlines)

        let matches = pattern.matches(in: textToSearch, options:[],
                range:NSMakeRange(0, textToSearch.count))

        for match in matches {
            var matchRange = match.range(at: index)
            if matchRange.location == NSNotFound {
               matchRange = match.range(at: index + 1)
               if matchRange.location == NSNotFound {
                   fatalError("dang")
               }
            }

            let nsString = textToSearch as NSString
            let str = nsString.substring(with: matchRange)
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
    static func buildFixedAndNonFixedModels(_ srcModel: BBPTableModel,
                                            fixedColumnModel: inout BBPTableModel?,
                                            nonFixedColumnModel: inout BBPTableModel?,
                                            fixedColumnCount: Int) {
        let rows = srcModel.numberOfRows
        fixedColumnModel = BBPTableModel()
        nonFixedColumnModel = BBPTableModel()
                                                
        var fixedOuterArray = Array<Array<String>>()
        var nonFixedOuterArray = Array<Array<String>>()
                                                
        for i in 0..<rows {
            var srcRow = srcModel.rowData[i];
            let fixedRow = srcRow[0...fixedColumnCount - 1]
            let nonFixedRow = srcRow[fixedColumnCount...srcRow.count - 1]
            
            fixedOuterArray.append(Array(fixedRow))
            nonFixedOuterArray.append(Array(nonFixedRow))
        }
        fixedColumnModel!.rowData = fixedOuterArray
        nonFixedColumnModel!.rowData = nonFixedOuterArray
    }

}
