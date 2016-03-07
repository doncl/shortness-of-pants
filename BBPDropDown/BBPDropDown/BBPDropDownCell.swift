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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        textLabel!.textColor = UIColor.whiteColor()
        textLabel!.font = UIFont(name: "HelveticaNueue", size:22.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView!.frame = CGRectOffset(imageView!.frame, 6, 0)
        textLabel!.frame = CGRectOffset(textLabel!.frame, 6, 0)
    }

    func showSelectionMark(selected: Bool) {
        selectionIndicator.hidden = !selected
    }
}
