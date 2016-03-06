//
//  Profile.swift
//  Simbi
//
//  Created by Seif Kobrosly on 12/11/15.
//  Copyright © 2015 SimbiSocial. All rights reserved.
//

import Foundation

import UIKit

final class Profile {
    
    static let sharedInstance = Profile()
    
    var image: UIImage?
    var name: String?
    var gender: String?
    var birthDay: NSDate?
    var introduction: String?
    var moreInformation = false
    var nickname: String?
    var location: String?
    var phoneNumber: String?
    var job: String?
}