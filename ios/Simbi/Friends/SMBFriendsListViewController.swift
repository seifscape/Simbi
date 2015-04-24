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
            var ph:NSArray = contact["Phone"] as! NSArray
            for phone in ph {
               var ppp =  (phone as! String).stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.allZeros)
                self.contantPhoneNumberArray.addObject(ppp)
            }
        }
        println("========================")
        println(self.contantPhoneNumberArray)
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
        loadContactNotInSimi(ContactsArray)
    }
    func loadContactNotInSimi(contacts:NSArray){
        self.objectsNotInSimbiAndButInContacts = []
            for contact in contacts {
            var ph:NSArray = contact["Phone"] as! NSArray
            var isSimbiUser = false
            var name = contact["fullName"]
            var phoneNo:String = ""
            println(name)
            for phone in ph {
                phoneNo = phone as! String
                phoneNo = phoneNo.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.allZeros)
                print("check:")
                println(phoneNo)
                if !(self.simbiUserPhoneInContact.indexOfObject(phoneNo) == NSNotFound){
                    isSimbiUser = true
                    break
                }
            }
            if isSimbiUser == false{
                var model:SMBFriendsListModel = SMBFriendsListModel()
                model.fullname = name as! String
                model.phoneNo = phoneNo
                model.type = 2
                model.parent = self
                self.objectsNotInSimbiAndButInContacts.append(model)
            }
        }
        self.tableView.reloadData()
    }
    func loadSimbiUserNotSimbiFriendButIncontact(contacts:NSArray){
        let query:PFQuery = PFQuery(className: "_User")
        query.whereKey("phoneNumber", containedIn: self.contantPhoneNumberArray as [AnyObject])
        //query.whereKey(<#key: String!#>, containedIn: <#[AnyObject]!#>)
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, err:NSError?) -> Void in
            self.objectsInSimbiAndContactsButNotSimbiFrieds = []
            self.simbiUserPhoneInContact = []
            for object in objects! {
                //SMBFriendsManager.sharedManager().friendsObjectIds().IndexOfObject((object as SMBUser).objectId)
                var isSimibiFriend = false
                var phoneNo = (object as! SMBUser).phoneNumber as String
                if !((object as! SMBUser).objectId == SMBUser.currentUser().objectId){
                        self.simbiUserPhoneInContact.addObject(phoneNo)
                    }
                for simbifriend in SMBFriendsManager.sharedManager().objects{
                    if (simbifriend as! SMBUser).objectId == (object as! SMBUser).objectId{
                        isSimibiFriend = true
                        break
                    }
                }
                if isSimibiFriend == true{
                    continue
                }
                var model:SMBFriendsListModel
                model = SMBFriendsListModel(user: object as! SMBUser)
                model.type = 1
                model.parent = self
                self.objectsInSimbiAndContactsButNotSimbiFrieds.append(model)
            }
            self.loadContactNotInSimi(contacts)
            self.tableView.reloadData()
        }
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
                alert.message = succ ? "upload contact's success!":"upload contact's failed!"
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
    
    
    // MARK: - Private Methods
    
    private func loadObjects() {
        
        objects = []
        
        // Get all friends and friend requests, sort alphabetically by name
        
        var allObjects = SMBFriendsManager.sharedManager().objects + SMBFriendRequestsManager.sharedManager().objects
        
        allObjects = sorted(allObjects) { a, b in
            
            var aName: String
            var bName: String
            
            if a is SMBUser { aName = (a as! SMBUser).name }
            else            { aName = (a as! SMBFriendRequest).fromUser.name }
            
            if b is SMBUser { bName = (b as! SMBUser).name }
            else            { bName = (b as! SMBFriendRequest).fromUser.name }
            
            return aName < bName
        }
        
        // Put each item in the model object
        
        for object in allObjects {
            
            var model: SMBFriendsListModel
            
            if object is SMBUser {
                model = SMBFriendsListModel(user: object as! SMBUser)
            }
            else {
                model = SMBFriendsListModel(request: object as! SMBFriendRequest)
            }
            
            objects.append(model)
        }
        
        self.tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDataSource/Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return objects.count
            break
        case 1:
            return self.objectsInSimbiAndContactsButNotSimbiFrieds.count
            break
        case 2:
            return self.objectsNotInSimbiAndButInContacts.count
            break
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
        var error:Unmanaged<CFError>?
        var addressBook: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
        
        if sysAddressBookStatus == .Denied || sysAddressBookStatus == .NotDetermined {
            // Need to ask for authorization
            var authorizedSingal:dispatch_semaphore_t = dispatch_semaphore_create(0)
            var askAuthorization:ABAddressBookRequestAccessCompletionHandler = { success, error in
                if success {
                    ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
                    dispatch_semaphore_signal(authorizedSingal)
                }
            }
            ABAddressBookRequestAccessWithCompletion(addressBook, askAuthorization)
            dispatch_semaphore_wait(authorizedSingal, DISPATCH_TIME_FOREVER)
        }
        
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
                // 姓、姓氏拼音
                var FirstName:String = ABRecordCopyValue(contact, kABPersonFirstNameProperty)?.takeRetainedValue() as! String? ?? ""
                currentContact["FirstName"] = FirstName
                currentContact["FirstNamePhonetic"] = ABRecordCopyValue(contact, kABPersonFirstNamePhoneticProperty)?.takeRetainedValue() as! String? ?? ""
                // 名、名字拼音
                var LastName:String = ABRecordCopyValue(contact, kABPersonLastNameProperty)?.takeRetainedValue() as! String? ?? ""
                currentContact["LastName"] = LastName
                currentContact["LirstNamePhonetic"] = ABRecordCopyValue(contact, kABPersonLastNamePhoneticProperty)?.takeRetainedValue() as! String? ?? ""
                // 昵称
                currentContact["Nikename"] = ABRecordCopyValue(contact, kABPersonNicknameProperty)?.takeRetainedValue() as! String? ?? ""
                
                // 姓名整理
                currentContact["fullName"] = LastName + FirstName
                
                // 公司（组织）
                currentContact["Organization"] = ABRecordCopyValue(contact, kABPersonOrganizationProperty)?.takeRetainedValue() as! String? ?? ""
                // 职位
                currentContact["JobTitle"] = ABRecordCopyValue(contact, kABPersonJobTitleProperty)?.takeRetainedValue() as! String? ?? ""
                // 部门
                currentContact["Department"] = ABRecordCopyValue(contact, kABPersonDepartmentProperty)?.takeRetainedValue() as! String? ?? ""
                // 备注
                currentContact["Note"] = ABRecordCopyValue(contact, kABPersonNoteProperty)?.takeRetainedValue() as! String? ?? ""
                // 生日（类型转换有问题，不可用）
                //currentContact["Brithday"] = ((ABRecordCopyValue(contact, kABPersonBirthdayProperty)?.takeRetainedValue()) as NSDate).description
                
                /*
                部分多值属性
                */
                // 电话
                var Phone:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonPhoneProperty)
                if Phone != nil {
                    currentContact["Phone"] = Phone
                }
                
                // 地址
                var Address:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonAddressProperty)
                if Address != nil {
                    currentContact["Address"] = Address
                }
                
                // E-mail
                var Email:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonEmailProperty)
                if Email != nil {
                    currentContact["Email"] = Email
                }
                // 纪念日
                var Date:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonDateProperty)
                if Date != nil {
                    currentContact["Date"] = Date
                }
                // URL
                var URL:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonURLProperty)
                if URL != nil{
                    currentContact["URL"] = URL
                }
                // SNS
                var SNS:Array<AnyObject>? = analyzeContactProperty(contact, kABPersonSocialProfileProperty)
                if SNS != nil {
                    currentContact["SNS"] = SNS
                }
                allContacts.append(currentContact)
            }
            return allContacts
        }
        return analyzeSysContacts( ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray )
    }
}


// MARK: - SMBManagerDelegate

extension SMBFriendsListViewController: SMBManagerDelegate {
    
    func manager(manager: SMBManager!, didUpdateObjects objects: [AnyObject]!) {
        
        loadObjects()
    }
    
    
    func manager(manager: SMBManager!, didFailToLoadObjects error: NSError!) {
        
    }
}
