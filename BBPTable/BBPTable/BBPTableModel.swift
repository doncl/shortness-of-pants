//
//  BBPTableModel.swift
//  BBPTable
//
//  Created by Don Clore on 8/3/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

class BBPTableModel: NSObject {
    var rowData: Array<Array<String>> = [[]]
    
    override init() {
        super.init()
        rowData = generateRowData()
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


    //
    //  THIS IS SCAFFOLDING that should be replaced.
    //
    private func generateRowData() -> Array<Array<String>> {
        return [
            ["#",  "PLAYER",          "POS","TEAM",     "BYE","INJURY","AGE","ADP","AAV","PROCJECTED PTS.", "BOX SCORE"],
            ["1",  "Antonio Brown",   "WR", "Steelers", "11", "",    "27",  "3.88",  "$40", "371.5", "2363"],
            ["2",  "Odel Beckham",    "WR", "Jets",     "11", "Pro", "22",  "5.23",  "$39", "371.2", "2360"],
            ["3",  "Jamaal Charles",  "RB", "Chiefs",   "11", "",    "28",  "8.92",  "$33", "313.3", "2354"],
            ["4",  "Le'Veon Bell",    "RB", "Steelers", "11", "Sus", "22",  "3.96",  "$40", "311.0", "2341"],
            ["5",  "Matt Forte",      "RB", "Bears",    "7",  "",    "29",  "19.93", "$27", "291.0", "2131"],
            ["6",  "Rob Gronkowski",  "TE", "Patriots", "4",  "",    "26",  "9.73",  "$37", "303.9", "2116"],
            ["7",  "Eddie Lacy",      "RB", "Packers",  "7",  "",    "24",  "7.96",  "$35", "288.3", "2104"],
            ["8",  "Adrian Peterson", "RB", "Vikings",  "5",  "",    "30",  "11.21", "$30", "284.2", "2063"],
            ["9",  "Julio Jones",     "WR", "Eagles",   "10", "",    "26",  "7.46",  "$37", "339.9", "2047"],
            ["10", "C.J. Anderson",   "RB", "Broncos",  "7",  "",    "24",  "21.96", "$26", "280.5", "2026"],
            ["11", "Arian Foster",    "RB", "Texans",   "9",  "",    "28",  "25.22", "$26", "277.1", "1992"],
            ["12", "Marshawn Lynch",  "RB", "Seahawks", "9",  "",    "29",  "20.83", "$29", "275.8", "1979"]
        ]
    }
}
