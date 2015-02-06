// FriendRequest statuses:

var FriendRequestStatus = {
    pending : "Pending",
    accepted : "Accepted",
    declined : "Declined"
}


Parse.Cloud.define("sendBatchFriendRequests", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // sendBatchFriendRequests:
    //
    //      Sends a batch of friend requests to a group of users.
    //
    //      NOTE: This does not check for duplicates!
    //
    //  Parameters:
    //
    //      userIds - An array of objectIds that are the users to send a friend request to.

    var query = new Parse.Query(Parse.User);
    query.containedIn("objectId", request.params.userIds);

    query.find(
    {
        success: function(toUsers)
        {
            var fromUser = Parse.User.current();

            var FriendRequest = Parse.Object.extend("FriendRequest");

            var friendRequests = new Array(toUsers.length);

            for (var i = 0; i < toUsers.length; i++)
            {
                var toUser = toUsers[i];

                var friendRequest = new FriendRequest();
                friendRequest.set("toUser", toUser);
                friendRequest.set("fromUser", fromUser);
                friendRequest.set("status", FriendRequestStatus.pending);
                friendRequest.set("isAccepted", false);

                friendRequests[i] = friendRequest;
            }

            Parse.Object.saveAll(friendRequests,
            {
                success: function(friendRequests)
                {
                    for (var i = 0; i < toUsers.length; i++)
                    {
                        var toUser = toUsers[i];
                        var friendRequest = friendRequests[i];

                        toUser.relation("friendRequests").add(friendRequest);
                        fromUser.relation("friendRequests").add(friendRequest);
                    }

                    var objectsToSave = toUsers;
                    objectsToSave[objectsToSave.length] = fromUser;

                    Parse.Object.saveAll(objectsToSave,
                    {
                        success: function(savedObjects)
                        {
                            var pushQuery = new Parse.Query(Parse.Installation);
                            query.containedIn("user", toUsers);

                            Parse.Push.send(
                            {
                                where: pushQuery,
                                data:
                                {
                                    alert: fromUser.get("firstName") + " sent you a friend request!",
                                    pushType: "FriendRequestReceived",
                                    sound: "Notification.caf",

                                    fromUserId: fromUser.id
                                }
                            },{
                                success: function()
                                {
                                    response.success();
                                },
                                error: function()
                                {
                                    response.success();
                                }
                            });
                        },
                        error: function(error)
                        {
                            response.error("Could not save users");
                        }
                    });
                },
                error: function(error)
                {
                    response.error("Could not save friend requests");
                }
            });
        },
        error: function(error)
        {
            response.error("Could not query users");
        }
    });
});


Parse.Cloud.define("sendFriendRequest", function(request, response)
{
    Parse.Cloud.useMasterKey();



    // send friend request to user and notify toUser

    // params:
    //      toUser - objectId of the User who's receiving the request
    //      note - personal note to go with the request


    // if a pending friend request already exist for this user pair, then
    // the function will result in an error with "Friend request already exists"

        // this error message can be accessed through:

            // iOS - from associated NSError, [error.userInfo objectForKey:@"error"]


    // also sends a push to the recieving user with data:

    //      badge: "Increment"
    //      alert: message
    //      friendRequestId: objectId of the friend request object
    //      fromUserId: objectId of the sending user
    //      pushType: "FriendRequestRecieved"
    //      sound: "Notification.caf"


    var fromUser = Parse.User.current();

    var toUserQuery = new Parse.Query(Parse.User);

    toUserQuery.get(request.params.toUser,
    {
        success: function(toUser)
        {
            // check to make sure that there isn't already a friendRequest for this pair

            var FriendRequest = Parse.Object.extend("FriendRequest");

            var duplicateCheckQuery = new Parse.Query(FriendRequest);

            duplicateCheckQuery.equalTo("status", FriendRequestStatus.pending);
            duplicateCheckQuery.equalTo("fromUser", fromUser);
            duplicateCheckQuery.equalTo("toUser", toUser);

            // also check the reversed to/from pair

            var reversedDuplicateCheckQuery = new Parse.Query(FriendRequest);

            reversedDuplicateCheckQuery.equalTo("status", FriendRequestStatus.pending);
            reversedDuplicateCheckQuery.equalTo("fromUser", toUser);
            reversedDuplicateCheckQuery.equalTo("toUser", fromUser);

            // or together, check if the query returns any objects

            var orQuery = Parse.Query.or(duplicateCheckQuery, reversedDuplicateCheckQuery);

            orQuery.first(
            {
                success: function(result)
                {
                    if (result != undefined)
                    {
                        response.error("Friend request already exists");
                    }
                    else
                    {
                        var FriendRequest = Parse.Object.extend("FriendRequest");
                        var friendRequest = new FriendRequest();

                        friendRequest.set("toUser", toUser);
                        friendRequest.set("fromUser", fromUser);

                        friendRequest.set("status", FriendRequestStatus.pending);
                        friendRequest.set("isAccepted", false);

                        if (request.params.note && request.params.note.length > 0)
                            friendRequest.set("note", request.params.note);

                        friendRequest.save(null, 
                        {
                            success: function(friendRequest)
                            {
                                toUser.increment("pendingFriendRequests", 1);

                                var toUserFriendRequests = toUser.relation("friendRequests");
                                var fromUserFriendRequests = fromUser.relation("friendRequests");

                                toUserFriendRequests.add(friendRequest);
                                fromUserFriendRequests.add(friendRequest);

                                Parse.Object.saveAll([toUser, fromUser],
                                {
                                    success: function(list)
                                    {
                                        var pushQuery = new Parse.Query(Parse.Installation);
                                        pushQuery.equalTo("user", toUser);

                                        Parse.Push.send(
                                        {
                                            where: pushQuery,
                                            data:
                                            {
                                                alert: fromUser.get("firstName") + " sent you a friend request!",
                                                pushType: "FriendRequestReceived",
                                                sound: "Notification.caf",

                                                fromUserId: fromUser.id
                                                // Note: provide the fromUser's id instead of the friendRequest's id
                                                // to make it easier on batchSend (where we can't provide all of the
                                                // separate friendRequest ids)
                                            }
                                        },{
                                            success: function()
                                            {
                                                response.success(friendRequest.id);
                                            },
                                            error: function()
                                            {
                                                response.success(friendRequest.id);
                                            }
                                        });
                                    },
                                    error: function(error) { response.error("Could not save users"); }
                                });
                            },
                            error: function(error) { response.error("Could not create new FriendRequest object"); }
                        });
                    }
                },
                error: function(error) { response.error("Could not query duplicates"); }
            });
        },
        error: function(error) { response.error("Could not query fromUser!"); }
    });
});


Parse.Cloud.define("acceptFriendRequest", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // accept a pending friend request and notify fromUser

    // params:
    //      friendRequest - objectId of the friend request

    var query = new Parse.Query(Parse.Object.extend("FriendRequest"));

    query.include("toUser");
    query.include("fromUser");

    query.get(request.params.friendRequest,
    {
        success: function(friendRequest)
        {
            var toUser = friendRequest.get("toUser");
            var fromUser = friendRequest.get("fromUser");

            // decrement pending requests tally

            toUser.increment("pendingFriendRequests", -1);

            if (toUser.get("pendingFriendRequests") < 0)
            {
                toUser.set("pendingFriendRequests", 0);
                console.log("WARNING!! Tried to set pendingFriendRequests below 0 on user " + toUser.id);
            }

            // accept the request

            friendRequest.set("status", FriendRequestStatus.accepted);
            friendRequest.set("isAccepted", true);

            // rip out request object from relations

            var toUserFriendRequests = toUser.relation("friendRequests");
            var fromUserFriendRequests = fromUser.relation("friendRequests");

            toUserFriendRequests.remove(friendRequest);
            fromUserFriendRequests.remove(friendRequest);

            // add each user to the other's friends

            var toUserFriends = toUser.relation("friends");
            var fromUserFriends = fromUser.relation("friends");

            toUserFriends.add(fromUser);
            fromUserFriends.add(toUser);

            // save!

            Parse.Object.saveAll([friendRequest, toUser, fromUser],
            {
                success: function(list)
                {
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", fromUser);

                    Parse.Push.send(
                    {
                        where: pushQuery,
                        data:
                        {
                            alert: toUser.get("firstName") + " accepted your friend request!",
                            pushType: "FriendRequestAccepted",
                            sound: "Notification.caf",

                            toUserId: toUser.id
                        }
                    },{
                        success: function()
                        {
                            response.success();
                        },
                        error: function()
                        {
                            response.success();
                        }
                    });
                },
                error: function(error) { response.error("Could not save objects"); }
            });
        },
        error: function(error) { response.error("Could not query friendRequest!"); }
    });
});


Parse.Cloud.define("declineFriendRequest", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // decline a pending friend request. don't notify fromUser.

    // params:
    //      friendRequest - objectId of the friend request


    var query = new Parse.Query(Parse.Object.extend("FriendRequest"));

    query.include("toUser");
    query.include("fromUser");

    query.get(request.params.friendRequest,
    {
        success: function(friendRequest)
        {
            var toUser = friendRequest.get("toUser");
            var fromUser = friendRequest.get("fromUser");

            // decrement pending requests tally

            toUser.increment("pendingFriendRequests", -1);

            if (toUser.get("pendingFriendRequests") < 0)
            {
                toUser.set("pendingFriendRequests", 0);
                console.log("WARNING!! Tried to set pendingFriendRequests below 0 on user " + toUser.id);
            }

            // decline the request

            friendRequest.set("status", FriendRequestStatus.declined);

            // rip out request object from relations

            var toUserFriendRequests = toUser.relation("friendRequests");
            var fromUserFriendRequests = fromUser.relation("friendRequests");

            toUserFriendRequests.remove(friendRequest);
            fromUserFriendRequests.remove(friendRequest);

            // save!

            Parse.Object.saveAll([friendRequest, toUser, fromUser],
            {
                success: function(list)
                {
                    response.success();
                },
                error: function(error) { response.error("Could not save objects"); }
            });
        },
        error: function(error) { response.error("Could not query friendRequest!"); }
    });
});
