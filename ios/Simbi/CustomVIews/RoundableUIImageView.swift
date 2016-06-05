//
//  RoundableUIImageView.swift
//  Simbi
//
//  Created by Seif Kobrosly on 3/25/16.
//  Copyright © 2016 SimbiSocial. All rights reserved.
//

import UIKit

@IBDesignable class RoundableUIImageView: UIImageView {

    private var _round = false
    @IBInspectable var round: Bool {
        set {
            _round = newValue
            makeRound()
        }
        get {
            return self._round
        }
    }
    override internal var frame: CGRect {
        set {
            super.frame = newValue
            makeRound()
        }
        get {
            return super.frame
        }
        
    }
    
    
    private func makeRound() {
        if self.round == true {
            self.clipsToBounds = true
            self.layer.cornerRadius = (self.frame.width + self.frame.height) / 4
        } else {
            self.layer.cornerRadius = 0
        }
    }
}

