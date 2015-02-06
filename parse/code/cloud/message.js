Parse.Cloud.define("sendMessage", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // sendMessage:
    //
    //      Adds the message object to a chat and sends a push notification. Returns the objectId of the new message object.
    //
    //  Parameters:
    //
    //      chatId - The objectId of the chat object
    //      messageText - The text of the message

    var Chat = Parse.Object.extend("Chat");

    var query = new Parse.Query(Chat);
    query.include("userOne");
    query.include("userTwo");

    query.get(request.params.chatId,
    {
        success: function(chat)
        {
            // Figure out who the toUser is

            var fromUser = Parse.User.current();

            var toUser;
            var toUserNumber = 0;

            if (fromUser.id === chat.get("userOne").id)
            {
                toUser = chat.get("userTwo");
                toUserNumber = 2;
            }
            else if (fromUser.id === chat.get("userTwo").id)
            {
                toUser = chat.get("userOne");
                toUserNumber = 1;
            }
            else
                response.error("The current user is not in this chat!");


            // Create the message

            var Message = Parse.Object.extend("Message");

            var message = new Message();
            message.set("fromUser", fromUser);
            message.set("toUser", toUser);
            message.set("chat", chat);
            message.set("messageText", request.params.messageText);

            message.save(null,
            {
                success: function(message)
                {
                    // Add the message to the chat relation and save

                    chat.relation("messages").add(message);

                    if (toUserNumber == 1)
                        chat.set("userOneRead", false);
                    else if (toUserNumber == 2)
                        chat.set("userTwoRead", false);

                    chat.set("lastMessage", request.params.messageText);
                    var date = new Date();
                    chat.set("dateLastMessageSent", date);


                    chat.save(null,
                    {
                        success: function(chat)
                        {
                            // Send the push

                            var pushQuery = new Parse.Query(Parse.Installation);
                            pushQuery.equalTo("user", toUser);

                            Parse.Push.send(
                            {
                                where: pushQuery,
                                data:
                                {
                                    // aps
                                    alert: fromUser.get("firstName") + " sent you a message!",
                                    "content-available": 1,
                                    sound: "Notification.caf",

                                    // custom
                                    chatId: chat.id,
                                    messageId: message.id,
                                    pushType: "MessageReceived"
                                }
                            },{
                                success: function()
                                {
                                    // Flip it and save

                                    toUser.increment("unreadMessageCount");
                                    toUser.set("hasNewMessage", true);
                                    toUser.save();

                                    response.success();
                                },
                                error: function()
                                {
                                    chat.relation("messages").remove(message);
                                    chat.save();

                                    message.destroy();

                                    response.error("Could not send push");
                                }
                            });
                        },
                        error: function(error)
                        {
                            response.error("Could not save chat");
                        }
                    })
                },
                error: function(error)
                {
                    response.error("Could not create message");
                }
            });
        },
        error: function(error)
        {
            response.error("Could not query the chat");
        }
    });
});


