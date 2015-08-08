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
    var type = 0 // 0:friend   1:waiting accept   2:add friend   3:invite
    
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
        
        //invite people who are not simbi users
        if type == 3 {
            cell?.nameLabel.text = self.fullname
            cell?.emailLabel.text = self.phoneNo
            
            cell?.inviteButton.hidden = false
            cell?.requesetButton.hidden = true
            cell?.acceptButton.hidden = true
            cell?.chatButton.hidden = true
            cell!.activityIndicator.hidden = true
            cell?.inviteButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)

            cell!.inviteButton.addTarget(self, action: "inviteFriends:", forControlEvents: .TouchUpInside)
            return cell!
        }
        
        
        cell!.user = user
        
        cell!.profilePicture.setParseImage(user.profilePicture, withType: kImageTypeThumbnail)
        cell!.nameLabel.text = user.name
        cell!.emailLabel.text = user.email
        
        //already friend
        if type == 0 {
            cell?.chatButton.hidden = false
            cell?.acceptButton.hidden = true
            cell?.inviteButton.hidden = true
            cell?.requesetButton.hidden = true
            cell?.activityIndicator.hidden = true
            
            cell?.chatButton.addTarget(self, action: "chatWithFriend:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        //waiting accept
        if type == 1 {
            cell?.acceptButton.hidden = false
            cell?.inviteButton.hidden = true
            cell?.requesetButton.hidden = true
            cell?.chatButton.hidden = true
            cell?.activityIndicator.hidden = true
            
            cell!.nameLabel.text! += " wants to be your friend!"
            
            cell!.acceptButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            cell!.acceptButton.addTarget(self, action: "acceptFriendRequest:", forControlEvents: .TouchUpInside)
            
            cell!.acceptButton.hidden = isProcessingRequest
            isProcessingRequest ? cell!.activityIndicator.startAnimating() : cell!.activityIndicator.stopAnimating()
        }
        
        //add simbi user to friend
        if type == 2 {
            cell?.requesetButton.hidden = false
            cell?.acceptButton.hidden = true
            cell?.inviteButton.hidden = true
            cell?.chatButton.hidden = true
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
                
                if error == nil {
                    //accept ok
                    self.cell?.acceptButton.hidden = true
                    self.cell?.nameLabel.text = self.user.name
                    self.cell?.activityIndicator.stopAnimating()
                    
                    //reload friend
                    SMBFriendRequestsManager.sharedManager().removeObject(self.request)
                    SMBFriendsManager.sharedManager().addObject(self.request?.fromUser)

                } else {
                    var alert = UIAlertView(title: "Bad News", message: "\(error)", delegate: nil, cancelButtonTitle: "Cancel")
                    alert.show()
                }
                
            })
        }
    }
    
    func chatWithFriend(sender: AnyObject) {
        
        var chats:[SMBChat]? = SMBChatManager.sharedManager().objects as? [SMBChat]
        
        for chat:SMBChat in chats! {
            if chat.otherUser().objectId == user.objectId {
                var chatVC = SMBChatViewController.messagesViewControllerWithChat(chat, isViewingChat: true)
                chatVC.isFriend = true
                chatVC.isPushedFromRandomOrMap = false
                self.parent.navigationController?.pushViewController(chatVC, animated: true)
                
                return
            }
        }
        
        //create new chat
        var newChat: SMBChat? = SMBChat()
        newChat?.userOne = SMBUser.currentUser()
        newChat?.userTwo = user
        newChat?.save() //have to wait
        
        //add an empty message to new chat
        var msg: SMBMessage = SMBMessage()
        msg.fromUser = SMBUser.currentUser()
        msg.toUser = user
        msg.chat = newChat
        msg.messageText = ""
        
        SMBChatManager.sharedManager().addChat(newChat)
        
        var chatVC = SMBChatViewController.messagesViewControllerWithChat(newChat, isViewingChat: true)
        chatVC.isFriend = true
        chatVC.isPushedFromRandomOrMap = false
        self.parent.navigationController?.pushViewController(chatVC, animated: true)
    }
}