//
//  SMBUserCredits.swift
//  Simbi
//
//  Created by flynn on 11/14/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

class SMBUserCredits: PFObject, PFSubclassing {
    
    @NSManaged var user: SMBUser?
    @NSManaged var balance: Int
    @NSManaged var transactions: PFRelation
    
    class func parseClassName() -> String! {
        return "UserCredits"
    }
}
