//
//  ViewController.swift
//  BBPTable
//
//  Created by Don Clore on 8/3/15.
//  Copyright (c) 2015 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

enum TableLoadMode {
    case DefaultView
    case CreateView
}

class BBPTableViewController: UIViewController, UICollectionViewDataSource,
        UICollectionViewDelegate {
    
    //MARK: properties
    var tableProperties: TableProperties?
    var model: BBPTableModel?
    var nonFixedView: UICollectionView?
    var fixedView: UICollectionView?
    var fixedModel: BBPTableModel?
    var nonFixedModel: BBPTableModel?
    var loadMode: TableLoadMode
    var viewWidth: CGFloat?

    //MARK: Initialization
    init(loadMode: TableLoadMode) {
        self.loadMode = loadMode
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(loadMode: TableLoadMode, width: CGFloat) {
        self.init(loadMode: loadMode)
        viewWidth = width
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        BBPTableCell.initializeCellProperties(tableProperties!)
        BBPTableModel.buildFixedAndNonFixedModels(model!, fixedColumnModel: &fixedModel,
                nonFixedColumnModel: &nonFixedModel,
                fixedColumnCount: tableProperties!.fixedColumns!)

        let fixedLayout = BBPTableLayout()
        fixedLayout.calculateCellSizes(fixedModel!)

        let nonFixedLayout = BBPTableLayout()
        nonFixedLayout.calculateCellSizes(nonFixedModel!)

        if loadMode == .DefaultView {
            super.loadView() // Go ahead and call superclass to get a plain vanilla UIView.
        } else {
            let frame = CGRect(x: 0, y:0, width:viewWidth!, height: fixedLayout.tableHeight!)
            self.view = UIView(frame: frame)
        }

        fixedView = createCollectionView(view, layout: fixedLayout, x: 0.0,
            width: fixedLayout.tableWidth!)
        
        let nonFixedX = view.frame.origin.x + fixedLayout.tableWidth!
        let nonFixedWidth = view.frame.size.width - nonFixedX
        
        nonFixedView = createCollectionView(view, layout: nonFixedLayout,
            x: nonFixedX, width: nonFixedWidth)
        
        nonFixedView!.scrollEnabled = true
        nonFixedView!.showsHorizontalScrollIndicator = true
        
        view.addSubview(fixedView!)
        view.addSubview(nonFixedView!)
    }
    
    private func createCollectionView(parentView: UIView,
        layout: BBPTableLayout, x: CGFloat, width: CGFloat) -> UICollectionView {
            
        let frame = CGRect(x: x, y:parentView.frame.origin.y, width:width,
                height: parentView.frame.size.height)
            
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(BBPTableCell.self,
            forCellWithReuseIdentifier: "cellIdentifier")
        collectionView.backgroundColor = UIColor.whiteColor()
        return collectionView
    }
    
    //MARK: Handling synchronized scrolling.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == fixedView! {
            matchScrollView(nonFixedView!, second:fixedView!)
        } else {
            matchScrollView(fixedView!, second: nonFixedView!)
        }
    }
    
    private func matchScrollView(first: UIScrollView, second: UIScrollView) {
        var offset = first.contentOffset
        offset.y = second.contentOffset.y
        first.setContentOffset(offset, animated:false)
    }
    
    //MARK: UICollectionViewDataSource methods
    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        let model = getModel(collectionView)
        return model.numberOfColumns
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
        let model = getModel(collectionView)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellIdentifier",
            forIndexPath: indexPath) as! BBPTableCell
            
        let layout = collectionView.collectionViewLayout as! BBPTableLayout
        let columnIdx = indexPath.row
        let rowIdx = indexPath.section
            
        let cellData = model.dataAtLocation(rowIdx, column: columnIdx)
        let cellType = getCellType(indexPath)
        cell.setupCellInfo(cellType)
        cell.setCellText(cellData)
        let columnWidth = layout.columnWidths[columnIdx]
        cell.contentView.bounds = CGRect(x:0, y:0, width:columnWidth, height: layout.rowHeight!)
        return cell
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let model = getModel(collectionView)
        return model.numberOfRows
    }
    
    private func getCellType(indexPath: NSIndexPath) -> CellType {
        var cellType: CellType
        if indexPath.section == 0 {
            cellType = .ColumnHeading
        } else if ((indexPath.section + 1) % 2) == 0 {
            cellType = .DataEven
        } else {
            cellType = .DataOdd
        }
        return cellType
    }
    
    private func getModel(view: UICollectionView) -> BBPTableModel {
        if (view == fixedView!) {
            return fixedModel!
        } else {
            return nonFixedModel!
        }
    }

}

