function createUserPrivate(user)
{
    // createUserPrivate:
    //
    //      Creates a UserPrivate object for the given user with appropriate
    //      defaults and ACLs.

    var UserPrivate = Parse.Object.extend("UserPrivate");

    var userPrivate = new UserPrivate();
    userPrivate.set("user", user);

    var acl = new Parse.ACL();
    acl.setPublicWriteAccess(false);
    acl.setPublicReadAccess(false);
    acl.setReadAccess(user.id, true);
    acl.setWriteAccess(user.id, true);

    userPrivate.setACL(acl);

    return userPrivate;
}


function createUserCredits(user)
{
    // createUserCredits:
    //
    //      Creates a UserCredits object for the given user with appropriate
    //      defaults and ACLs.

    var UserCredits = Parse.Object.extend("UserCredits");

    var userCredits = new UserCredits();
    userCredits.set("user", user);
    userCredits.set("balance", 0);

    var acl = new Parse.ACL();
    acl.setPublicWriteAccess(false);
    acl.setPublicReadAccess(false);
    acl.setReadAccess(user.id, true);
    acl.setWriteAccess(user.id, false);

    userCredits.setACL(acl);

    return userCredits;
}


Parse.Cloud.beforeSave("_User", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // _User beforeSave:
    //
    //      Checks to see if the name or email of the user has changed, and will concatenate
    //      them in an all-lowercase seach field that we can run general queries against.

    var user = request.object;


    if (user.id == undefined)
    	user.set('isConfirmed', false);


    if (user.dirty("firstName") ||
        user.dirty("lastName")  ||
        user.dirty("email")     ||
        user.get("searchString") == undefined)
    {
        var firstName = new String(user.get("firstName"));
        var lastName  = new String(user.get("lastName"));
        var email = "";

        // For the email, hack off everything after the "@" from the email field.

        if (user.get("email") != undefined)
        {
            var emailWithDomain = new String(user.get("email"));

            for (var i = 0; i < emailWithDomain.length; i++)
            {
                if (emailWithDomain[i] == '@')
                    break;
            }

            email = emailWithDomain.substr(0, i);
        }

        // Combine the strings in an all-lowercase search field.

        var searchString = "";

        if (firstName != "undefined")
            searchString += firstName.toLowerCase() + " ";
        if (lastName != "undefined")
            searchString += lastName.toLowerCase() + " ";
        if (email != "undefined")
            searchString += email.toLowerCase();

        user.set("searchString", searchString);
    }


    response.success();
});


Parse.Cloud.afterSave("_User", function(request)
{
    Parse.Cloud.useMasterKey();

    // _User afterSave:
    //
    //      Checks to see if the user has a UserCredits or UserPrivate object. If not, then
    //      create them and set the ACLs appropriately.

    var objectsToSave = [];

    var userCredits = undefined;
    var userPrivate = undefined;

    if (request.object.get("credits") == undefined)
    {
        userCredits = createUserCredits(request.object);
        objectsToSave.push(userCredits);
    }

    if (request.object.get("private") == undefined)
    {
        userPrivate = createUserPrivate(request.object);
        objectsToSave.push(userPrivate);
    }

    if (objectsToSave.length > 0)
    {
        Parse.Object.saveAll(objectsToSave,
        {
            success: function(objects)
            {
                if (userCredits != undefined)
                    request.object.set("credits", userCredits);

                if (userPrivate != undefined)
                    request.object.set("private", userPrivate);

                request.object.save(null,
                {
                    success: function(user)
                    {
                        // Success!
                    },
                    error: function(user, error)
                    {
                        console.error("_User afterSave: Could not save _User");
                    }
                });
            },
            error: function(objects, error)
            {
                console.error("_User afterSave: Could not save UserCredits and UserPrivate objects")
            }
        });
    }
});


Parse.Cloud.beforeDelete("_User", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // _User beforeDelete:
    //
    //      Ensures that the user's private information is wiped upon account deletion. Leaves the
    //      UserCredits object dangling for historical purposes.

    if (request.object.get("private") != undefined)
    {
        var userPrivate = request.object.get("private");

        userPrivate.fetch(
        {
            success: function(userPrivate)
            {
                userPrivate.destroy(
                {
                    success: function(userPrivate)
                    {
                        response.success();
                    },
                    error: function(userPrivate, error)
                    {
                        response.error("Could not destroy private information");
                    }
                });
            },
            error: function(error)
            {
                response.error("Could not fetch private information");
            }
        });
    }
    else
    {
        // No private information, go ahead and delete
        response.success();
    }
});


Parse.Cloud.define("phoneNumberExists", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // phoneNumberExists:
    //
    //      Checks all of the phone numbers saved in the UserPrivate objects and sees whether or not
    //      the given phone number exists. UserPrivate objects all have public read/write turned off,
    //      so this needs to be done server-side.
    //
    //      Params:
    //          phoneNumber - A string that is the phone number to send the message to, without dashes
    //                        or spaces (ex: '15551234567' for '1 (555) 123-4567')
    //
    //      Returns "YES" in response.success() if the phone number exists, "NO" if not.

    var UserPrivate = Parse.Object.extend("UserPrivate");

    var query = new Parse.Query(UserPrivate);
    query.equalTo("phoneNumber", request.params.phoneNumber);

    query.count(
    {
        success: function(count)
        {
            if (count > 0)
                response.success("YES");
            else
                response.success("NO");
        },
        error: function(error)
        {
            response.error();
        }
    });
});


Parse.Cloud.define("sendConfirmationCode", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // sendConfirmationCode:
    //
    //      Sends the user a 6-digit code via SMS to confirm that they are in fact a real person.
    //
    //      Params:
    //          phoneNumber - A string that is the phone number to send the message to, without dashes
    //                        or spaces (ex: '15551234567' for '1 (555) 123-4567')

    var twilio = require('twilio')('AC753ce97055bea451a2500f9119008894', '4832f4a341144e11ddd77176f79dc0a8');

    var confirmationCode = '';

    // If they don't have a code or are trying to use a different phone number, assign a new code.

    if (Parse.User.current().get('confirmationCode') == undefined ||
        Parse.User.current().get('confirmingPhoneNumber') !== request.params.phoneNumber)
    {
        for (var i = 0; i < 6; i++)
            confirmationCode += Math.floor(10*Math.random()).toString();

        Parse.User.current().set('confirmationCode', confirmationCode);
        Parse.User.current().set('confirmingPhoneNumber', request.params.phoneNumber)
    }
    else // Otherwise, just use the one already assigned.
        confirmationCode = Parse.User.current().get('confirmationCode');

    Parse.User.current().save(null,
    {
        success: function()
        {
            twilio.sendSms(
            {
                to: '+' + Parse.User.current().get('confirmingPhoneNumber'),
                from: '+12014251120',
                body: 'Welcome to Simbi! Your confirmation code is ' + confirmationCode
            }, function(error, responseData)
            {
                if (error)
                    response.error();
                else
                    response.success();
            });
        },
        error: function()
        {
            response.error();
        }
    });
});


Parse.Cloud.define("checkConfirmationCode", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // checkConfirmationCode:
    //
    //      Checks a provided confirmation code against the user's assigned code. If they have it
    //      correct, flip the 'isConfirmed' flag and respond with success. Otherwise, respond with error.
    //
    //      Params:
    //          confirmationCode - The user-provided code to compare with.

    if (Parse.User.current().get('confirmationCode') === request.params.confirmationCode)
    {
        if (Parse.User.current().get('private') == undefined)
        {
            var userPrivate = createUserPrivate(Parse.User.current());
            userPrivate.save();
            Parse.User.current().set('private', userPrivate);
        }
        
        var userPrivate = Parse.User.current().get('private');

        userPrivate.fetch(
        {
            success: function(userPrivate)
            {
                userPrivate.set('phoneNumber', Parse.User.current().get('confirmingPhoneNumber'));
                Parse.User.current().unset('confirmingPhoneNumber');
                Parse.User.current().set('isConfirmed', true);

                Parse.Object.saveAll([Parse.User.current(), userPrivate],
                {
                    success: function(objects)
                    {
                        response.success();
                    },
                    error: function(objects, error)
                    {
                        response.error('Unable to save objects');
                    }
                });
            },
            error: function(userPrivate, error)
            {
                response.error('Unable to fetch UserPrivate objects');
            }
        });
    }
    else
        response.error('Code does not match');
});

