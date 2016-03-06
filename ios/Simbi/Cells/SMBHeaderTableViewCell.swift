//
//  SMBHeaderTableViewCell.swift
//  Simbi
//
//  Created by Seif Kobrosly on 11/25/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import UIKit

class SMBHeaderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutMargins = UIEdgeInsetsZero //or UIEdgeInsetsMake(top, left, bottom, right)
        self.separatorInset = UIEdgeInsetsZero //if you also want to adjust separatorInset
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
