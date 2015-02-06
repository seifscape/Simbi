Parse.Cloud.afterSave("Activity", function(request)
{
    Parse.Cloud.useMasterKey();

    // Activity afterSave:
    //
    //      Sends a push to friends that the current user checked in.


    // Query the fromUser so we can get their friends.
    var user = Parse.User.current();
    var friends = user.relation("friends");

    if (request.object.get("activityType") == "CheckIn")
    {    
        friends.query().find(
        {
            success: function(friendList) 
            {
                var pushQuery = new Parse.Query(Parse.Installation);
                pushQuery.containedIn("user", friendList);

                Parse.Push.send(
                {   
                    where: pushQuery,
                    data:
                    {
                        alert: Parse.User.current().get("firstName") + " has checked in at " + request.object.get("activityText"),
                        pushType: "CheckInActivity",
                        activityId: request.object.id,
                        sound: "Notification.caf"
                    }
                 }, {
                    success: function() 
                    { 

                    },
                    error: function() 
                    { 
                        error.log("ERROR: Failed to send push");
                    }
                });
            },
            error: function(error)
            {
                error.log("ERROR: Could not query friends");
            }
        });
    }
});