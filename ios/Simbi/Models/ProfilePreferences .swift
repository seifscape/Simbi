//
//  ProfilePreferences .swift
//  Simbi
//
//  Created by Seif Kobrosly on 12/25/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import Foundation

class ProfilePreferences {
    
//    static let sharedInstance = ProfilePreferences()

    var gender: Int
    var age: Int
    var name: String
    var height: String
    var agePref = ()
    var genderPref: Int
    var heightPref = ()
    var eyeColorPref: UIColor
    var hairColorPref: UIColor
    
    init(gender: Int, age: Int, name: String, height: String, agePref: (), genderPref: Int, heightPref: (), eyeColorPref: UIColor, hairColorPref: UIColor ) {
        
        self.gender = gender
        self.age = age
        self.name = name
        self.height = height
        self.agePref = agePref
        self.genderPref = genderPref
        self.heightPref = heightPref
        self.eyeColorPref = eyeColorPref
        self.hairColorPref = hairColorPref
        
    }
}