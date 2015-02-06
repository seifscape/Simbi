Parse.Cloud.beforeSave("Chat", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // Chat beforeSave:
    //
    //      Sets the initial flags for a new Chat.


    // Check to ensure that both users get set
    if (request.object.get("userOne") == undefined || request.object.get("userTwo") == undefined)
        response.error();


    if (request.object.id == undefined)
    {
        request.object.set("isActive", true);
        request.object.set("isAccepted", false);
        request.object.set("isDeclined", false);
        request.object.set("userOneRead", true);
        request.object.set("userTwoRead", false);

        if (request.object.get("userOneRevealed") == undefined)
            request.object.set("userOneRevealed", false);
        if (request.object.get("userTwoRevealed") == undefined)
            request.object.set("userTwoRevealed", false);

        if (request.object.get("startedWithChallenge") === true)
            request.object.set("lastMessage", "Challenge!");
        if (request.object.get("startedWithQuestion") === true)
            request.object.set("lastMessage", "Question Answered!");

        var date = new Date();
        request.object.set("dateLastMessageSent", date);
    }
    else if (request.object.get("isAccepted") == true && request.object.get("dateStarted") == undefined)
    {
        var date = new Date();
        request.object.set("dateStarted", date);
    }
    
    response.success();
});


Parse.Cloud.define("revealUserInChat", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // revealUserInChat:
    //
    //      Reveals the current user to the other user in the chat. Sets the corresponding 'userFooRevealed' flag and sends a push.
    //
    //      Params:
    //          chatId - objectId of the chat object.

    var Chat = Parse.Object.extend("Chat");

    var query = new Parse.Query(Chat);
    query.include("userOne");
    query.include("userTwo");

    query.get(request.params.chatId, 
    {
        success: function(chat)
        {
            // Flip the revealed flag for this user, find the otherUser

            var otherUser;

            if (Parse.User.current().id === chat.get("userOne").id)
            {
                chat.set("userOneRevealed", true);
                otherUser = chat.get("userTwo");
            }
            else if (Parse.User.current().id === chat.get("userTwo").id)
            {
                chat.set("userTwoRevealed", true);
                otherUser = chat.get("userOne");
            }
            else
                response.error("Current user is neither userOne nor userTwo");

            chat.save(null,
            {
                success: function(chat)
                {
                    // Send a push notificaton to the otherUser

                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", otherUser);

                    Parse.Push.send(
                    {
                        where: pushQuery,
                        data:
                        {
                            alert: Parse.User.current().get("firstName") + " revealed!",
                            chatMessage: "Revealed!",
                            "content-available": 1,
                            chatId: chat.id,
                            pushType: "ChatRevealed",
                            sound: "Notification.caf"
                        }
                    },{
                        success: function()
                        {
                            // Create a message indication

                            var Message = Parse.Object.extend("Message");

                            var message = new Message();
                            message.set("messageText", "Revealed!");
                            message.set("isAction", true);
                            message.set("fromUser", Parse.User.current());
                            message.set("toUser", otherUser);
                            message.set("chat", chat);

                            message.save(null,
                            {
                                success: function(message)
                                {
                                    chat.relation("messages").add(message);
                                    chat.set("lastMessage", "Revealed!");
                                    chat.save();

                                    response.success();
                                },
                                error: function(error) { response.success(); }
                            });
                        },
                        error: function() { response.success(); }
                    });
                },
                error: function(error) { response.error("Could not save chat"); }
            });
        },
        error: function(error) { response.error("Could not query chat"); }
    });
});


Parse.Cloud.define("removeUserFromChat", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // removeUserFromChat:
    //
    //      Removes the current user from the chat and notifies the other user. Sets the corresponding 'userFooRemoved' flag.
    //
    //      Params:
    //          chatId - objectId of the chat object.

    var Chat = Parse.Object.extend("Chat");

    var query = new Parse.Query(Chat);
    query.include("userOne");
    query.include("userTwo");

    query.get(request.params.chatId, 
    {
        success: function(chat)
        {
            var shouldSendPush = true;

            // Find which user is the current user and flip the right flag

            if (Parse.User.current().id === chat.get("userOne").id)
            {
                chat.set("userOneRemoved", true);

                if (chat.get("userTwoRemoved") == true) // If the other user's flag is set, don't send a push
                    shouldSendPush = false;
            }
            else if (Parse.User.current().id === chat.get("userTwo").id)
            {
                chat.set("userTwoRemoved", true);

                if (chat.get("userOneRemoved") == true) // If the other user's flag is set, don't send a push
                    shouldSendPush = false;
            }
            else
                response.error("Current user is neither userOne nor userTwo");

            chat.save(null,
            {
                success: function(chat)
                {
                    if (shouldSendPush)
                    {
                        // Send a push notification if the other user hasn't left

                        var otherUser;

                        if (Parse.User.current().id === chat.get("userOne").id)
                            otherUser = chat.get("userTwo");
                        else
                            otherUser = chat.get("userOne");

                        var pushQuery = new Parse.Query(Parse.Installation);
                        pushQuery.equalTo("user", otherUser);

                        Parse.Push.send(
                        {
                            where: pushQuery,
                            data:
                            {
                                alert: Parse.User.current().get("firstName") + " left the chat.",
                                chatMessage: "Left the chat.",
                                chatId: chat.id,
                                pushType: "ChatRemoved",
                                sound: "Notification.caf"
                            }
                        },{
                            success: function()
                            {
                                // Create a message indication

                                var Message = Parse.Object.extend("Message");

                                var message = new Message();
                                message.set("messageText", "Left the chat.");
                                message.set("isAction", true);
                                message.set("fromUser", Parse.User.current());
                                message.set("toUser", otherUser);
                                message.set("chat", chat);

                                message.save(null,
                                {
                                    success: function(message)
                                    {
                                        chat.relation("messages").add(message);
                                        chat.set("lastMessage", "Left the chat.");
                                        chat.save();

                                        response.success();
                                    },
                                    error: function(error) { response.success(); }
                                });
                            },
                            error: function() { response.success(); }
                        });
                    }
                    else
                    {
                        response.success();
                    }
                },
                error: function(error) { response.error("Could not save chat"); }
            });
        },
        error: function(error) { response.error("Could not query chat"); }
    });
});