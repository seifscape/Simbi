/* Challenge and Action types */

var ChallengeType = {
    PokeORama       : "Poke-O-Rama",
    DrinkRoulette   : "DrinkRoulette"
}


var PokeORamaActions = {
    Poke : "poke",
    Surrender : "surrender"
}

var DrinkRouletteActions = {
    Spin : "spin"
}


/* Parse Cloud Functions */

Parse.Cloud.beforeSave("Challenge", function(request, response)
{
    Parse.Cloud.useMasterKey();


    // Check to ensure that both users get set
    if (request.object.get("toUser") == undefined || request.object.get("fromUser") == undefined)
        response.error();
    

    if (request.object.id == undefined)
    {
        request.object.set("challengeInfo", initialChallengeInfo(request.object.get("challengeType")));

        if (request.object.get("challengeInfo") == undefined)
            response.error("Initial challengeInfo undefined for challengeType " + request.object.get("challengeType"));
    }

    response.success();
});


Parse.Cloud.define("createChatForChallenge", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // createChatForChallenge:
    //
    //      Takes an existing challenge and creates a chat object and attaches the challenge to the chat.
    //
    //      Params:
    //          challengeId - The objectId of the challenge object.
    //          isFriend - Boolean value that indicates if they are friends or not.
    //
    //      Returns the objectId of the Chat created.

    var Chat = Parse.Object.extend("Chat");
    var Challenge = Parse.Object.extend("Challenge");
    var Message = Parse.Object.extend("Message");

    var challengeQuery = new Parse.Query(Challenge);
    challengeQuery.include("fromUser");
    challengeQuery.include("toUser");

    challengeQuery.get(request.params.challengeId,
    {
        success: function(challenge)
        {
            var fromUser = challenge.get("fromUser");
            var toUser = challenge.get("toUser");

            // Create Message

            var message = new Message();
            message.set("fromUser", fromUser);
            message.set("toUser", toUser);
            message.set("isAction", true);
            message.set("challengeId", challenge.id);
            message.set("messageText", "I challenge you to a game of " + challenge.get("challengeName") + "!");

            message.save(null,
            {
                success: function(message)
                {
                    // Create Chat

                    var chat = new Chat();
                    chat.set("userOne", fromUser);
                    chat.set("userTwo", toUser);
                    chat.set("currentChallenge", challenge);
                    chat.relation("messages").add(message);
                    chat.relation("gameMessages").add(message);

                    var date = new Date();

                    chat.set("dateLastMessageSent", date);

                    chat.set("startedWithChallenge", true);

                    if (request.params.isFriend == true)
                    {
                        chat.set("userOneRevealed", true);
                        chat.set("userTwoRevealed", true);
                    }

                    chat.save(null,
                    {
                        success: function(chat)
                        {
                            challenge.set("chat", chat);
                            challenge.save();

                            message.set("chat", chat);
                            message.save();

                            // Send a push

                            var pushQuery = new Parse.Query(Parse.Installation);
                            pushQuery.equalTo("user", toUser);

                            Parse.Push.send(
                            {
                                where: pushQuery,
                                data:
                                {
                                    alert: Parse.User.current().get("firstName") + " challenged you to a game of " + challenge.get("challengeName") + "!",
                                    chatId: chat.id,
                                    "content-available": 1,
                                    pushType: "ChallengeReceived",
                                    sound: "Notification.caf"
                                }
                            },{
                                success: function()
                                {
                                    toUser.increment("unreadMessageCount");
                                    toUser.set("hasNewMessage", true);
                                    toUser.save();

                                    response.success(chat.id);
                                },
                                error: function() { response.success(chat.id); } // Don't care if it succeeds - challenge/chat is already created
                            });
                        },
                        error: function(chat, error)
                        {
                            chat.destroy();
                            response.error("Could not create chat!")
                        }
                    });
                },
                error: function(message, error)
                {
                    message.destroy();
                    response.error("Could not save message");
                }
            });
        },
        error: function(error)
        {
            response.error("Could not query challenge!");
        }
    });
});


Parse.Cloud.define("acceptChallenge", function(request, response)
{
    Parse.Cloud.useMasterKey()

    // acceptAction:
    //
    //      Cloud function that accepts the challenge, starts the chat, and sends a push. Returns the chat message.
    //
    //  Parameters:
    //
    //      challengeId - the objectId of the challenge object

    var Challenge = Parse.Object.extend("Challenge");

    var query = new Parse.Query(Challenge);
    query.include("chat");
    query.include("fromUser");
    query.include("toUser");

    query.get(request.params.challengeId,
    {
        success: function(challenge)
        {
            var toUser = challenge.get("fromUser"); // these are backwards (toUser is accepting)
            var fromUser = challenge.get("toUser");
            var chat = challenge.get("chat");

            challenge.set("accepted", true);
            challenge.save();

            var chatMessage = "I accept!";

            var Message = Parse.Object.extend("Message");

            var message = new Message();
            message.set("fromUser", challenge.get("toUser"));
            message.set("toUser", challenge.get("fromUser"));
            message.set("chat", chat);
            message.set("isAction", true);
            message.set("messageText", chatMessage);
            message.set("challengeId", challenge.id);
            message.set("isAccept", true);

            message.save(null,
            {
                success: function(message)
                {
                    chat.set("isAccepted", true);
                    chat.set("startedWithChallenge", false);
                    chat.relation("messages").add(message);
                    chat.relation("gameMessages").add(message);

                    var date = new Date();
                    chat.set("dateLastMessageSent", date);

                    chat.save(null,
                    {
                        success: function(chat)
                        {
                            var pushQuery = new Parse.Query(Parse.Installation);
                            pushQuery.equalTo("user", toUser);

                            Parse.Push.send(
                            {
                                where: pushQuery,
                                data:
                                {
                                    alert: fromUser.get("firstName") + " accepted your challenge to play " + challenge.get("challengeName") + "!",
                                    chatId: chat.id,
                                    "content-available": 1,
                                    challengeId: challenge.id,
                                    chatMessage: chatMessage,
                                    pushType: "ChallengeAccepted",
                                    sound: "Notification.caf"
                                }
                            },{
                                success: function()
                                {
                                    toUser.increment("unreadMessageCount");
                                    toUser.set("hasNewMessage", true);
                                    toUser.save();

                                    response.success(chatMessage);
                                },
                                error: function()
                                {
                                    response.success(chatMessage);
                                }
                            });
                        },
                        error: function(error) { response.error("Could not save Chat"); }
                    });
                },
                error: function(error) { response.error("Couldn't save message"); }
            });
        },
        error: function(error) { response.error("Could not query the challenge"); }
    });
});


Parse.Cloud.define("challengeAction", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // challengeAction:
    //
    //      Cloud function that will take some action for a given challenge and carry out the necessary
    //      tasks and send a push notification to the other user.
    //
    //  Parameters:
    //
    //      challengeId - The objectId of the challenge object
    //      otherUserId - The objectId of the other user, typically the user who's receiving the notification
    //      action - The action associated with the challenge (ex: "madeMove")
    //
    //  Returns:
    //
    //      If the requests succeeds, the response's success message will be the chat message (to populate an
    //      open chat with)

    var Challenge = Parse.Object.extend("Challenge");

    var query = new Parse.Query(Challenge);
    query.include("chat");
    query.include("fromUser");
    query.include("toUser");

    query.get(request.params.challengeId,
    {
        success: function(challenge)
        {
            var otherUser;

            if (request.params.otherUserId === challenge.get("fromUser").id)
                otherUser = challenge.get("fromUser");
            else if (request.params.otherUserId === challenge.get("toUser").id)
                otherUser = challenge.get("toUser");
            else
                response.error("Supplied user neither matches fromUser nor toUser");


            // Modify challengeInfo according to requested action

            var challengeInfo = challenge.get("challengeInfo");
            var newChallengeInfo = modifiedChallengeInfo(challenge.get("challengeType"), request.params.action, challengeInfo);

            if (newChallengeInfo == undefined)
                response.error("No behavior defined for challengeType " + challenge.get("challengeType"));

            challenge.set("challengeInfo", newChallengeInfo);


            // Save the challenge with the new challengeInfo

            challenge.save(null,
            {
                success: function(challenge)
                {
                    // Craft messages for the chat and push

                    var message = pushMessageForAction(challenge.get("challengeType"), request.params.action, Parse.User.current().get("firstName"));
                    var chatMessage = chatMessageForAction(challenge.get("challengeType"), request.params.action, request.params);

                    if (message === undefined)
                        response.error("No message for challengeType " + challenge.get("challengeType"));
                    if (chatMessage === undefined)
                        response.error("No chatMessage for challengeType " + challenge.get("challengeType"));

                    // Send a push

                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", otherUser);

                    Parse.Push.send(
                    {
                        where: pushQuery,
                        data:
                        {
                            alert: message,
                            chatMessage: chatMessage,
                            challengeId: challenge.id,
                            chatId: challenge.get("chat").id,
                            pushType: "ChallengeAction",
                            actionType: request.params.action,
                            "content-available": 1,
                            sound: "Notification.caf"
                        }
                    },{
                        success: function()
                        {
                            // Indicate to the other user that they have a new message

                            otherUser.increment("unreadMessageCount");
                            otherUser.set("hasNewMessage", true);
                            otherUser.save();

                            if (chatMessage != undefined)
                            {
                                // If there's a chatMessage, create a new message and add it to the chat.

                                var chat = challenge.get("chat");

                                var Message = Parse.Object.extend("Message");

                                var message = new Message();
                                message.set("messageText", chatMessage);
                                message.set("isAction", true);
                                message.set("fromUser", Parse.User.current());
                                message.set("toUser", otherUser);
                                message.set("chat", chat);
                                message.set("challengeId", challenge.id);

                                message.save(null,
                                {
                                    success: function(message)
                                    {
                                        chat.relation("gameMessages").add(message);
                                        chat.set("lastMessage", chatMessage);

                                        var date = new Date();
                                        chat.set("dateLastMessageSent", date);
                                        
                                        chat.save();

                                        // Return the chatMessage in the response.
                                        response.success(chatMessage);
                                    },
                                    error: function(error)
                                    {
                                        // Succeed anyway. Return the chatMessage in the response.
                                        response.success(chatMessage);
                                    }
                                });
                            }
                            else
                            {
                                console.log("No chat message!");
                                response.success();
                            }
                        },
                        error: function()
                        {
                            // Don't care if it fails or not
                            response.success();
                        } 
                    });
                },
                error: function(error)
                {
                    response.error("Couldn't save challenge");
                }
            });   
        },
        error: function(error)
        {
            response.error("Could not query challenge!");
        }
    });
});


/*   Game-specific functions   */

function initialChallengeInfo(challengeType)
{
    if (challengeType === ChallengeType.PokeORama)
    {
        return { pokeCount: 0 };
    }
    else if (challengeType === ChallengeType.DrinkRoulette)
    {
        return { drinks: 0 };
    }
    else
        return undefined;
}


function modifiedChallengeInfo(challengeType, action, challengeInfo)
{
    if (challengeType === ChallengeType.PokeORama)
    {
        if (action === PokeORamaActions.Poke)
        {
            challengeInfo.pokeCount++;
            return challengeInfo;
        }
        else if (action === PokeORamaActions.Surrender)
        {
            // No modifications
            return challengeInfo;
        }
        else
            return undefined;
    }
    else if (challengeType === ChallengeType.DrinkRoulette)
    {
        if (action === DrinkRouletteActions.Spin)
        {
            challengeInfo.drinks++;
            return challengeInfo;
        }
        else
            return undefined;
    }
    else
        return undefined;
}


function pushMessageForAction(challengeType, action, userName)
{
    if (challengeType === ChallengeType.PokeORama)
    {
        if (action === PokeORamaActions.Poke)
        {
            return userName + " poked you!";
        }
        else if (action === PokeORamaActions.Surrender)
        {
            return "Victory! " + userName + " surrendered to your pokes!";
        }
        else
            return undefined;
    }
    else if (challengeType === ChallengeType.DrinkRoulette)
    {
        if (action === DrinkRouletteActions.Spin)
        {
            return userName + " spun the drink wheel!";
        }
        else
            return undefined;
    }
    else
        return undefined;
}


function chatMessageForAction(challengeType, action, params)
{
    if (challengeType === ChallengeType.PokeORama)
    {
        if (action === PokeORamaActions.Poke)
        {
            return "Poke!";
        }
        else if (action === PokeORamaActions.Surrender)
        {
            return "I surrender to your pokes!";
        }
        else
            return undefined;
    }
    else if (challengeType === ChallengeType.DrinkRoulette)
    {
        if (action === DrinkRouletteActions.Spin)
        {
            var message = "I spun the wheel and got " + params.drink + "!";
            if (params.drink === "whiskey")
                message += " (neat!)";
            return message;
        }
        else
            return undefined;
    }
    else
        return undefined;
}

