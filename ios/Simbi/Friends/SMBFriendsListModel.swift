//
//  SMBFriendsListModel.swift
//  Simbi
//
//  Created by flynn on 10/12/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit

protocol SMBSendSMSDelegate {
    func sendInviteSMS(phoneNo:String, senderName:String)
}

class SMBFriendsListModel: NSObject {
    /*added by zhy at 2015-06-18 for inviting friend*/
    var sendSMSDelegate:SMBSendSMSDelegate?

    // MARK: - Class Methods
    
    class func cellClass()  -> AnyClass { return SMBFriendsListCell.classForCoder() }
    class func cellReuse()  -> String   { return "FriendsListCell" }
    class func cellHeight() -> CGFloat  { return SMBFriendsListCell.cellHeight() }
    
    // MARK: - Implementation
    var parent:UIViewController = UIViewController()
    let user: SMBUser
    var request: SMBFriendRequest?
    
    var cell: SMBFriendsListCell?
    
    var isProcessingRequest = false
    var type = 0
    
    var fullname:String = ""
    var phoneNo = ""
    override init() {
        self.user = SMBUser.currentUser()
    }
    init(name:String,phone:String){
        self.user = SMBUser.currentUser()
        self.fullname = name
        self.phoneNo = phone
    }
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
        
        if type ==  2{
            cell?.nameLabel.text = self.fullname
            cell?.emailLabel.text = self.phoneNo
            
            
            cell?.requesetButton.hidden = true
            cell?.acceptButton.hidden = true
            cell?.inviteButton.hidden = false
            cell!.activityIndicator.hidden = true
            cell?.inviteButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)

            cell!.inviteButton.addTarget(self, action: "inviteFriends:", forControlEvents: .TouchUpInside)
            return cell!
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
        if type==1 {
            cell?.requesetButton.hidden = false
            cell?.acceptButton.hidden = true
            cell?.inviteButton.hidden = true
            cell!.activityIndicator.hidden = true
            
            cell!.requesetButton.addTarget(self, action: "requestFriend:", forControlEvents: .TouchUpInside)
        }
        return cell!
    }
    func inviteFriends(sender: AnyObject) {
//        let hud = MBProgressHUD.HUDwithMessage("Sending ....", parent:self.parent)
//
//        var dic:NSMutableDictionary = NSMutableDictionary()
//        dic.setValue(self.phoneNo, forKey: "phoneNumber")
//        PFCloud.callFunctionInBackground("sendInviteMsg", withParameters:dic as [NSObject : AnyObject]) { (obj, err) -> Void in
//            if err==nil {
//                (sender as! UIButton).hidden = true
//                hud.dismissWithMessage("Invited sucuss!")
//            }else{
//                hud.dismissWithMessage("Invited failed!")
//            }
//        }
        
       
        /*modified by zhy at 2015-06-18*/
        
        sendSMSDelegate?.sendInviteSMS(self.phoneNo, senderName: self.user.name)
    }
    func requestFriend(sender: AnyObject) {
        let hud = MBProgressHUD.HUDwithMessage("Sending ....", parent: self.parent)
        var dic:NSMutableDictionary = NSMutableDictionary()
        var userid = self.user.objectId
        dic.setValue(userid, forKey: "toUser")
        PFCloud.callFunctionInBackground("sendFriendRequest", withParameters: dic as [NSObject : AnyObject]) { (obj, err) -> Void in
            //sender.setTitle("requested", forState: .Normal)
            if err==nil {
                (sender as! UIButton).hidden = true
                hud.dismissWithMessage("Request sucuss!")
            }else{
                hud.dismissWithMessage("Request failed!")
            }
        }
        println(self.user.objectId)
    }
    
    func acceptFriendRequest(sender: AnyObject) {
        
        if let request = self.request {
            
            isProcessingRequest = true
            
            cell?.animateAcceptButton()
            var dic:NSMutableDictionary = NSMutableDictionary()
            dic.setValue(request.objectId, forKey: "friendRequest")
                        
            PFCloud.callFunctionInBackground("acceptFriendRequest", withParameters: dic as [NSObject : AnyObject], block: { (object: AnyObject?, error: NSError?) -> Void in
                
                self.isProcessingRequest = false
                
                if object != nil {
                    
                    SMBFriendRequestsManager.sharedManager().removeObject(self.request)
                    SMBFriendsManager.sharedManager().addObject(self.request?.fromUser)
                    
                    self.request = nil
                    
                    if self.user == self.cell?.user {
                        
                        self.cell?.nameLabel.text = self.user.name
                        self.cell?.activityIndicator.stopAnimating()
                    }
                }
                else if self.user == self.cell?.user {
                    
                    self.cell?.acceptButton.hidden = false
                    self.cell?.activityIndicator.stopAnimating()
                }
            })
        }
    }
}