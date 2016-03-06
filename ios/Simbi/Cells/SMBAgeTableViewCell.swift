//
//  SMBAgeTableViewCell.swift
//  Simbi
//
//  Created by Seif Kobrosly on 12/24/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import UIKit
import TTRangeSlider


class SMBAgeTableViewCell: UITableViewCell,TTRangeSliderDelegate {
    
    @IBOutlet var ageSlider:TTRangeSlider!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        
    }

}
