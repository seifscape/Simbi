//
//  SMBFriendsListModel.swift
//  Simbi
//
//  Created by flynn on 10/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


class SMBFriendsListModel: NSObject {
    
    // MARK: - Class Methods
    
    class func cellClass()  -> AnyClass { return SMBFriendsListCell.classForCoder() }
    class func cellReuse()  -> String   { return "FriendsListCell" }
    class func cellHeight() -> CGFloat  { return SMBFriendsListCell.cellHeight() }
    
    
    // MARK: - Implementation
    
    let user: SMBUser
    var request: SMBFriendRequest?
    
    var cell: SMBFriendsListCell?
    
    var isProcessingRequest = false
    
    
    init(user: SMBUser) {
        self.user = user
    }
    
    init(request: SMBFriendRequest) {
        self.user = request.fromUser
        self.request = request
    }
    

    func cellForTable(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        
        cell = tableView.dequeueReusableCellWithIdentifier(SMBFriendsListModel.cellReuse(), forIndexPath: indexPath) as? SMBFriendsListCell
        
        if cell == nil {
            cell = SMBFriendsListCell(style: .Default, reuseIdentifier: SMBFriendsListModel.cellReuse())
        }
        
        cell!.user = user
        
        cell!.profilePicture.setParseImage(user.profilePicture, withType: kImageTypeThumbnail)
        cell!.nameLabel.text = user.name
        cell!.emailLabel.text = user.email
        
        if let request = self.request {
            
            cell!.nameLabel.text! += " wants to be your friend!"
            
            cell!.acceptButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            cell!.acceptButton.addTarget(self, action: "acceptFriendRequest:", forControlEvents: .TouchUpInside)
            
            cell!.acceptButton.hidden = isProcessingRequest
            
            isProcessingRequest ? cell!.activityIndicator.startAnimating() : cell!.activityIndicator.stopAnimating()
        }
        else {
            cell!.acceptButton.hidden = true
            cell!.activityIndicator.hidden = true
        }
        
        return cell!
    }
    
    
    func acceptFriendRequest(sender: AnyObject) {
        
        if let request = self.request {
            
            isProcessingRequest = true
            
            cell?.animateAcceptButton()
            
            let params = ["friendRequest": request.objectId]
                        
            PFCloud.callFunctionInBackground("acceptFriendRequest", withParameters: params, block: { (object: AnyObject?, error: NSError?) -> Void in
                
                self.isProcessingRequest = false
                
                if object != nil {
                    
                    SMBFriendRequestsManager.sharedManager().removeObject(self.request?)
                    SMBFriendsManager.sharedManager().addObject(self.request?.fromUser)
                    
                    self.request = nil
                    
                    if self.user == self.cell?.user? {
                        
                        self.cell?.nameLabel.text = self.user.name
                        self.cell?.activityIndicator.stopAnimating()
                    }
                }
                else if self.user == self.cell?.user? {
                    
                    self.cell?.acceptButton.hidden = false
                    self.cell?.activityIndicator.stopAnimating()
                }
            })
        }
    }
}