//
//  StringFormats.swift
//  Simbi
//
//  Created by flynn on 10/26/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


func heightString(feet: Int, inches: Int) -> String {
    
    if feet >= 7 {
        return "7'+"
    }
    else if feet < 4 || (feet == 4 && inches == 0) {
        return "4'"
    }
    else {
        return "\(feet)'\(inches)\""
    }
}


func heightString(value: Int) -> String {
    return heightString(value/12, inches: value%12)
}
