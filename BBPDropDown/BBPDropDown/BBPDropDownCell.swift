//
//  BBPDropDownCell.swift
//  BBPDropDown
//
//  Created by Don Clore on 3/5/16.
//  Copyright © 2016 Beer Barrel Poker Studios. All rights reserved.
//

import UIKit

class BBPDropDownCell: UITableViewCell {
    @IBOutlet var selectionIndicator: UIImageView!

    var selectionImage : UIImage? {
        get {
            return selectionIndicator.image
        }
        set (newImage) {
            selectionIndicator.image = newImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        textLabel!.textColor = UIColor.white
        textLabel!.font = UIFont(name: "HelveticaNueue", size:22.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView!.frame = imageView!.frame.offsetBy(dx: 6, dy: 0)
        textLabel!.frame = textLabel!.frame.offsetBy(dx: 6, dy: 0)
    }

    func showSelectionMark(_ selected: Bool) {
        selectionIndicator.isHidden = !selected
    }
}
