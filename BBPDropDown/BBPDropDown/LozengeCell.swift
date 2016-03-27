//
//  LozengeCellCollectionViewCell.swift
//  BBPDropDown
//
//  Created by Don Clore on 3/6/16.
//  Copyright © 2016 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

protocol LozengeCellDelegate {
    func deleteTapped(cell: LozengeCell)
}

class LozengeCell: UICollectionViewCell {
    @IBOutlet var lozengeText: UILabel!
    @IBOutlet var deleteImage: UIImageView!
    
    var tapDeleteImageRecognizer: UITapGestureRecognizer?
    
    var delegate : LozengeCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupDeleteTap() {
        userInteractionEnabled = true
        
        if let _ = tapDeleteImageRecognizer {
            return
        }

        deleteImage.userInteractionEnabled = true
        tapDeleteImageRecognizer = UITapGestureRecognizer()
        tapDeleteImageRecognizer!.numberOfTapsRequired = 1
        tapDeleteImageRecognizer!.numberOfTouchesRequired = 1
        tapDeleteImageRecognizer!.addTarget(self, action: #selector(LozengeCell.tappedDelete))
        tapDeleteImageRecognizer!.enabled = true
        addGestureRecognizer(tapDeleteImageRecognizer!)
    }
    
    func tappedDelete() {
        print("delete tapped")
        if let delegate = delegate {
            delegate.deleteTapped(self)
        }
    }
}