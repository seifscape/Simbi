//
//  CGFloatHelper.swift
//  Simbi
//
//  Created by flynn on 10/8/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//


// Extensions to provide a shorthand property to cast primitives as CGFloats

extension Int {
    var CG: CGFloat {
        get {
            return CGFloat(self)
        }
    }
}


extension Float {
    var CG: CGFloat {
        get {
            return CGFloat(self)
        }
    }
}


extension Double {
    var CG: CGFloat {
        get {
            return CGFloat(self)
        }
    }
}
