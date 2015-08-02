//
//  SMBFriendsListViewController.swift
//  Simbi
//
//  Created by flynn on 10/10/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import MessageUI

class SMBFriendsListViewController: UITableViewController {
    
    let menuButton = UIButton()
    let chatButton = UIButton()
    
    var objects: [SMBFriendsListModel] = []
    var objectsInSimbiAndContactsButNotSimbiFrieds:[SMBFriendsListModel] = []
    var objectsNotInSimbiAndButInContacts:[SMBFriendsListModel] = []
    var contantPhoneNumberArray:NSMutableArray = []
    var simbiUserPhoneInContact:NSMutableArray = []
    var ContactsArray:Array<Dictionary<String,AnyObject>>=[]
    // MARK: - ViewController Lifecycle
    
    convenience init() { self.init(style: .Grouped) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Friends"
        
        SMBFriendsManager.sharedManager().addDelegate(self)
        SMBFriendRequestsManager.sharedManager().addDelegate(self)
        
        self.tableView.backgroundColor = UIColor.simbiWhiteColor()
        
        self.tableView.registerClass(SMBFriendsListModel.cellClass(), forCellReuseIdentifier: SMBFriendsListModel.cellReuse())
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshAction:", forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl
        
        //get the contact
        ContactsArray = getSysContacts()

        //self.downLoadsContactToServer(array)
        
        for contact in ContactsArray {
            var ph:[String] = contact["Phone"] as! [String]
            for phone: String in ph {
                var ppp = phone.stringByReplacingOccurrencesOfString("[^0-9]*",
                    withString: "",
                    options: .RegularExpressionSearch,
                    range: Range(start: phone.startIndex, end: phone.endIndex))
               
                //添加国家代码 USA：1
                if count(ppp) == 10 {
                    ppp = "1" + ppp
                }
//                var ppp =  (phone as! String).stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.allZeros)
                
                self.contantPhoneNumberArray.addObject(ppp)
            }
        }
        
        //download contacts to sever
        let userdefaults = NSUserDefaults.standardUserDefaults()
        if userdefaults.objectForKey("HasDownLoadContact") == nil{
            userdefaults.setBool(false, forKey: "HasDownLoadContact")
            userdefaults.synchronize()
            downLoadsContactToServer(ContactsArray)
        }else{
            if userdefaults.boolForKey("HasDownLoadContact") == false{
                downLoadsContactToServer(ContactsArray)
            }
        }
        
        loadObjects()
        loadSimbiUserNotSimbiFriendButIncontact(ContactsArray)
//        loadContactNotInSimi(ContactsArray)
    }
    
    // MARK: - Private Methods
    
    private func loadObjects() {
        
        objects = []
        
        // Get friends, sort alphabetically by name
        var friends = SMBFriendsManager.sharedManager().objects
        friends = sorted(friends) { a, b in
            
            var aName: String
            var bName: String
            
            if a is SMBUser { aName = (a as! SMBUser).name }
            else            { aName = (a as! SMBFriendRequest).fromUser.name }
            
            if b is SMBUser { bName = (b as! SMBUser).name }
            else            { bName = (b as! SMBFriendRequest).fromUser.name }
            
            return aName < bName
        }
        
        for friend in friends {
            var model: SMBFriendsListModel
            model = SMBFriendsListModel(user: friend as! SMBUser)
            model.type = 0
            model.parent = self
            objects.append(model)
        }
        
        
        // Get friend requests, sort alphabetically by name
        var friendRequests = SMBFriendRequestsManager.sharedManager().objects
        friendRequests = sorted(friendRequests) { a, b in
            
            var aName: String
            var bName: String
            
            if a is SMBUser { aName = (a as! SMBUser).name }
            else            { aName = (a as! SMBFriendRequest).fromUser.name }
            
            if b is SMBUser { bName = (b as! SMBUser).name }
            else            { bName = (b as! SMBFriendRequest).fromUser.name }
            
            return aName < bName
        }
        
        for friendRequest in friendRequests {
            if friendRequest.isAccepted == false {
                
                var model: SMBFriendsListModel
                model = SMBFriendsListModel(request: friendRequest as! SMBFriendRequest)
                model.type = 1
                model.parent = self
                objects.append(model)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func loadSimbiUserNotSimbiFriendButIncontact(contacts:NSArray){
        let query:PFQuery = PFQuery(className: "_User")
        query.whereKey("phoneNumber", containedIn: self.contantPhoneNumberArray as [AnyObject])

        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, err:NSError?) -> Void in
            self.objectsInSimbiAndContactsButNotSimbiFrieds = []
            self.simbiUserPhoneInContact = []
            for object in objects! {
                
                var isSimibiFriend = false
                
                var phoneNo = (object as! SMBUser).phoneNumber as String
                
                if (object as! SMBUser).objectId != SMBUser.currentUser().objectId {
                    self.simbiUserPhoneInContact.addObject(phoneNo)
                }
                
                for friendId in SMBFriendsManager.sharedManager().friendsObjectIds(){
                    if friendId as? String == (object as! SMBUser).objectId {
                        isSimibiFriend = true
                        break
                    }
                }
                
                if isSimibiFriend == true{
                    continue
                }
                
                var model:SMBFriendsListModel
                model = SMBFriendsListModel(user: object as! SMBUser)
                model.type = 2
                model.parent = self
                self.objectsInSimbiAndContactsButNotSimbiFrieds.append(model)
            }
            
            //load after simbiUserPhoneInContact is ok
            self.loadContactNotInSimi(contacts)
            
            
            /*added by zhy at 2015-06-09*/
            self.objectsInSimbiAndContactsButNotSimbiFrieds = (self.objectsInSimbiAndContactsButNotSimbiFrieds as NSArray).sortedArrayUsingComparator({ (obj1, obj2) -> NSComparisonResult in
                if (obj1 as! SMBFriendsListModel).fullname < (obj2 as! SMBFriendsListModel).fullname {
                    return NSComparisonResult.OrderedAscending
                } else {
                    return NSComparisonResult.OrderedDescending
                }
            }) as! [SMBFriendsListModel]
            

            self.tableView.reloadData()
        }
             
    }
    
    func loadContactNotInSimi(contacts:NSArray){
        self.objectsNotInSimbiAndButInContacts = []
        for contact in contacts {
            var ph:NSArray = contact["Phone"] as! NSArray
            var isSimbiUser = false
            var name = contact["fullName"]
            var phoneNo:String = ""

            for phone in ph {
                phoneNo = phone as! String
                phoneNo = phoneNo.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.allZeros)

                if !(self.simbiUserPhoneInContact.indexOfObject(phoneNo) == NSNotFound){
                    isSimbiUser = true
                    break
                }
            }
            if isSimbiUser == false{
                var model:SMBFriendsListModel = SMBFriendsListModel()
                model.sendSMSDelegate = self/*added by zhy at 2015-06-18 for inviting friend*/
                model.fullname = name as! String
                model.phoneNo = phoneNo
                model.type = 3
                model.parent = self
                self.objectsNotInSimbiAndButInContacts.append(model)
            }
        }
        
        /*added by zhy at 2015-06-09*/
        self.objectsNotInSimbiAndButInContacts = ((self.objectsNotInSimbiAndButInContacts as NSArray).sortedArrayUsingComparator { (obj1, obj2) -> NSComparisonResult in
            if (obj1 as! SMBFriendsListModel).fullname < (obj2 as! SMBFriendsListModel).fullname {
                return NSComparisonResult.OrderedAscending
            } else {
                return NSComparisonResult.OrderedDescending
            }
            
            }) as! [SMBFriendsListModel]
        
        self.tableView.reloadData()
    }
    
    func downLoadsContactToServer(contacts:NSArray){
        let obid = SMBUser.currentUser().objectId
        if obid=="" {
            return
        }
        let query = PFQuery(className: "_User")
        query.getObjectInBackgroundWithId(obid!) { (obj:PFObject?, err:NSError?) -> Void in
            if obj==nil{
                return
            }
            obj?["ContactList"] = contacts
            obj?.saveInBackgroundWithBlock({ (succ:Bool, err:NSError?) -> Void in
                if succ == true{
                    let userdefaults = NSUserDefaults.standardUserDefaults()
                    userdefaults.setBool(true, forKey: "HasDownLoadContact")
                    userdefaults.synchronize()
                }
                let alert = UIAlertView()
                alert.title = "Tip"
                alert.message = succ ? "upload contact's success!" : "upload contact's failed!  [ERR:\(err)]"
                alert.addButtonWithTitle("Ok")
                alert.show()
            })
        }
    }
    
    // MARK: - User Actions
    
    func refreshAction(sender: AnyObject) {
        
        let refreshControl = sender as! UIRefreshControl
        
        self.tableView.userInteractionEnabled = false
        
        SMBFriendsManager.sharedManager().loadObjects { (Bool) -> Void in
            SMBFriendRequestsManager.sharedManager().loadObjects({ (Bool) -> Void in
                self.tableView.userInteractionEnabled = true
                self.loadObjects()
                self.loadSimbiUserNotSimbiFriendButIncontact(self.ContactsArray)
                self.loadContactNotInSimi(self.ContactsArray)
                refreshControl.endRefreshing()
            })
        }
    }
    
    
    
    
    // MARK: - UITableViewDataSource/Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return objects.count
        case 1:
            return self.objectsInSimbiAndContactsButNotSimbiFrieds.count
        case 2:
            return self.objectsNotInSimbiAndButInContacts.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Simbi Friends"
    
        case 1:
            return "Simbi User"
            
        case 2:
            return "Contact Friends"
            
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SMBFriendsListModel.cellHeight()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                return objects[indexPath.row].cellForTable(tableView, indexPath: indexPath)
            case 1:
                return self.objectsInSimbiAndContactsButNotSimbiFrieds[indexPath.row].cellForTable(tableView, indexPath: indexPath)
            case 2:
            return self.objectsNotInSimbiAndButInContacts[indexPath.row].cellForTable(tableView, indexPath: indexPath)
            
            default :
            return UITableViewCell()
        }
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if !(section==2){
            return nil
        }
        let findFriendsButton = UIButton()
        findFriendsButton.frame = CGRectMake(0, 0, self.view.frame.width, 44)
        findFriendsButton.setTitle("Find Friends", forState: .Normal)
        findFriendsButton.setTitleColor(UIColor.simbiBlueColor(), forState: .Normal)
        findFriendsButton.titleLabel?.font = UIFont.simbiFontWithSize(14)
        findFriendsButton.addTarget(self, action: "findFriendsAction:", forControlEvents: .TouchUpInside)
        
        return findFriendsButton
    }
    
    
    // MARK: - User Actions
    
    func findFriendsAction(sender: AnyObject) {
        
        self.navigationController?.pushViewController(SMBFindFriendsViewController(), animated: true)
    }
    
    func getSysContacts() -> [[String:AnyObject]] {
        
        func analyzeSysContacts(sysContacts:NSArray) -> [[String:AnyObject]] {
            var allContacts:Array = [[String:AnyObject]]()
            
            func analyzeContactProperty(contact:ABRecordRef, property:ABPropertyID) -> [AnyObject]? {
                var propertyValues:ABMultiValueRef? = ABRecordCopyValue(contact, property)?.takeRetainedValue()
                if propertyValues != nil {
                    var values:Array<AnyObject> = Array()
                    for i in 0 ..< ABMultiValueGetCount(propertyValues) {
                        var value = ABMultiValueCopyValueAtIndex(propertyValues, i)
                        switch property {
                            // 地址
                        case kABPersonAddressProperty :
                            var valueDictionary:Dictionary = [String:String]()
                            
                            var addrNSDict:NSMutableDictionary = value.takeRetainedValue() as! NSMutableDictionary
                            valueDictionary["_Country"] = addrNSDict.valueForKey(kABPersonAddressCountryKey as String) as? String ?? ""
                            valueDictionary["_State"] = addrNSDict.valueForKey(kABPersonAddressStateKey as String) as? String ?? ""
                            valueDictionary["_City"] = addrNSDict.valueForKey(kABPersonAddressCityKey as String) as? String ?? ""
                            valueDictionary["_Street"] = addrNSDict.valueForKey(kABPersonAddressStreetKey as String) as? String ?? ""
                            valueDictionary["_Contrycode"] = addrNSDict.valueForKey(kABPersonAddressCountryCodeKey as String) as? String ?? ""
                            
                            // 地址整理
                            var fullAddress:String = (valueDictionary["_Country"]! == "" ? valueDictionary["_Contrycode"]! : valueDictionary["_Country"]!) + ", " + valueDictionary["_State"]! + ", " + valueDictionary["_City"]! + ", " + valueDictionary["_Street"]!
                            values.append(fullAddress)
                            
                            // SNS
                        case kABPersonSocialProfileProperty :
                            var valueDictionary:Dictionary = [String:String]()
                            
                            var snsNSDict:NSMutableDictionary = value.takeRetainedValue() as! NSMutableDictionary
                            valueDictionary["_Username"] = snsNSDict.valueForKey(kABPersonSocialProfileUsernameKey as String) as? String ?? ""
                            valueDictionary["_URL"] = snsNSDict.valueForKey(kABPersonSocialProfileURLKey as String) as? String ?? ""
                            valueDictionary["_Serves"] = snsNSDict.valueForKey(kABPersonSocialProfileServiceKey as String) as? String ?? ""
                            
                            values.append(valueDictionary)
                            // IM
                        case kABPersonInstantMessageProperty :
                            var valueDictionary:Dictionary = [String:String]()
                            
                            var imNSDict:NSMutableDictionary = value.takeRetainedValue() as! NSMutableDictionary
                            valueDictionary["_Serves"] = imNSDict.valueForKey(kABPersonInstantMessageServiceKey as String) as? String ?? ""
                            valueDictionary["_Username"] = imNSDict.valueForKey(kABPersonInstantMessageUsernameKey as String) as? String ?? ""
                            
                            values.append(valueDictionary)
                            // Date
                        case kABPersonDateProperty :
                            var date:String? = (value.takeRetainedValue() as? NSDate)?.description
                            if date != nil {
                                values.append(date!)
                            }
                            // Email
                        case kABPersonEmailProperty :
                            var mail:String? = value.takeRetainedValue() as? String
                            if mail != nil {
                                values.append(mail!)
                            }
                            // Phone
                        case kABPersonPhoneProperty :
                            var phone:String? = value.takeRetainedValue() as? String
                            if phone != nil {
                                values.append(phone!)
                            }
                        default :
                            var val:String = value.takeRetainedValue() as? String ?? ""
                            values.append(val)
                        }
                    }
                    return values
                }else{
                    return nil
                }
            }
            
            for contact in sysContacts {
                var currentContact:Dictionary = [String:AnyObject]()
                
                /*
                部分单值属性
                */
                
                // 名、名字拼音
                var FirstName:String = ABRecordCopyValue(contact, kABPersonFirstNameProperty)?.takeRetainedValue() as! String? ?? ""
//                currentContact["FirstName"] = FirstName
//                currentContact["FirstNamePhonetic"] = ABRecordCopyValue(contact, kABPersonFirstNamePhoneticProperty)?.takeRetainedValue() as! String? ?? ""
               
                // 姓、姓氏拼音
                var LastName:String = ABRecordCopyValue(contact, kABPersonLastNameProperty)?.takeRetainedValue() as! String? ?? ""
//                currentContact["LastName"] = LastName
//                currentContact["LirstNamePhonetic"] = ABRecordCopyValue(contact, kABPersonLastNamePhoneticProperty)?.takeRetainedValue() as! String? ?? ""
                
                // 姓名整理
                currentContact["fullName"] = FirstName + " " + LastName
                
                /*
                部分多值属性
                */
                
                // 电话
                var Phone:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonPhoneProperty)
                if Phone != nil {
                    currentContact["Phone"] = Phone
                }
                
                // E-mail
//                var Email:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonEmailProperty)
//                if Email != nil {
//                    currentContact["Email"] = Email
//                }
                
                allContacts.append(currentContact)
            }
            return allContacts
        }
        
        
        
        var isAllowAccess = false
        
        let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
        println("---------AddressBookStatus----\(sysAddressBookStatus)------")
        if sysAddressBookStatus == ABAuthorizationStatus.Authorized
        || sysAddressBookStatus == ABAuthorizationStatus.NotDetermined {
            var error:Unmanaged<CFError>?
            var addressBook: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
            
            // Need to ask for authorization
            var authorizedSingal:dispatch_semaphore_t = dispatch_semaphore_create(0)
            var askAuthorization:ABAddressBookRequestAccessCompletionHandler = { success, error in
                if success {
                    isAllowAccess = true
                    dispatch_semaphore_signal(authorizedSingal)
                } else {
                    isAllowAccess = false
                    dispatch_semaphore_signal(authorizedSingal)
                }
            }
            ABAddressBookRequestAccessWithCompletion(addressBook, askAuthorization)
            dispatch_semaphore_wait(authorizedSingal, DISPATCH_TIME_FOREVER)
            
            if isAllowAccess {
                return analyzeSysContacts( ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray )
            } else {
                return []
            }
            
        } else {
            return []
        }
        
    }
}


// MARK: - SMBManagerDelegate | MFMessageComposeViewControllerDelegate | SMBSendSMSDelegate

extension SMBFriendsListViewController: SMBManagerDelegate, MFMessageComposeViewControllerDelegate, SMBSendSMSDelegate{
    //SMBManagerDelegate
    func manager(manager: SMBManager!, didUpdateObjects objects: [AnyObject]!) {
        
        loadObjects()
    }
    
    
    func manager(manager: SMBManager!, didFailToLoadObjects error: NSError!) {
        
    }
    
    
    /*
        added by zhy at 2015-06-18
    
        function: send SMS for inviting friend
    */
    
    //MFMessageComposeViewControllerDelegate
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //SMBSendSMSDelegate
    func sendInviteSMS(phoneNo: String, senderName: String) {
        
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        var rcp:Array = [phoneNo]
        messageComposeVC.recipients = rcp
        messageComposeVC.body = "Hey friend - Add me on Simbi! Username:" + senderName + " https://www.simbisocial.com"
        self.presentViewController(messageComposeVC, animated: true, completion: nil)
        
    }
}

