//
//  CellProperties.swift
//  BBPTable
//
//  Created by Don Clore on 8/3/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

class CellProperties: NSObject {
    // Background color of header.
    var headerColor: UIColor?
    
    // Header font properties.
    var headerFontName: String?
    var headerFontSize: CGFloat?
    var headerTextColor: UIColor?
    
    // Data cell font properties.
    var dataCellFontName: String?
    var dataCellFontSize: CGFloat?
    var dataCellTextColor: UIColor?
    
    // Odd and even rows have different colors.  Set the same if you want them the same.
    var oddRowColor: UIColor?
    var evenRowColor: UIColor?
    
    // Border properties.
    var borderColor: UIColor?
    var borderWidth: CGFloat?
}
