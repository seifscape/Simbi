//
//  SMBReceipt.swift
//  Simbi
//
//  Created by flynn on 11/14/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

class SMBReceipt: PFObject, PFSubclassing {
    
    @NSManaged var user: SMBUser?
    @NSManaged var data: PFFile?
    @NSManaged var identifier: String?
    
    class func parseClassName() -> String! {
        return "Receipt"
    }
}
