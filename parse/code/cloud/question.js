Parse.Cloud.beforeSave("Question", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // Check to ensure that both users get set
    if (request.object.get("toUser") == undefined || request.object.get("fromUser") == undefined)
        response.error();
    else
        response.success();
});


Parse.Cloud.define("createChatForQuestion", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // createChatForQuestion:
    //
    //      Takes an existing question and creates a chat object and attaches the question to the chat.
    //
    //      Params:
    //          questionId - The objectId of the question object.
    //          isFriend - Boolean value that indicates if they are friends or not.
    //
    //      Returns the objectId of the Chat created.

    var Chat = Parse.Object.extend("Chat");
    var Message = Parse.Object.extend("Message");
    var Question = Parse.Object.extend("Question");

    var questionQuery = new Parse.Query(Question);
    questionQuery.include("fromUser");
    questionQuery.include("toUser");

    questionQuery.get(request.params.questionId,
    {
        success: function(question)
        {
            var fromUser = question.get("fromUser");
            var toUser = question.get("toUser");

            // Create Message

            var message = new Message();
            message.set("fromUser", fromUser);
            message.set("toUser", toUser);
            message.set("isAction", true);
            message.set("questionId", question.id);
            message.set("messageText", "I answered a question!");

            message.save(null,
            {
                success: function(message)
                {
                    // Create Chat

                    var chat = new Chat();
                    chat.set("userOne", fromUser);
                    chat.set("userTwo", toUser);
                    chat.set("currentQuestion", question);
                    chat.relation("messages").add(message);

                    var date = new Date();
                    chat.set("dateLastMessageSent", date);

                    chat.set("startedWithQuestion", true);

                    if (request.params.isFriend == true)
                    {
                        chat.set("userOneRevealed", true);
                        chat.set("userTwoRevealed", true);
                    }

                    chat.save(null,
                    {
                        success: function(chat)
                        {
                            question.set("chat", chat);
                            question.save();

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
                                    alert: Parse.User.current().get("firstName") + " answered a question!",
                                    chatId: chat.id,
                                    pushType: "QuestionReceived",
                                    "content-available": 1,
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
                                error: function() { response.success(chat.id); } // Don't care if it succeeds - question/chat is already created
                            });
                        },
                        error: function(error)
                        {
                            chat.destroy();
                            response.error("Could not create chat!")
                        }
                    });
                },
                error: function(error)
                {
                    response.error("Could not save message");
                }
            });
        },
        error: function(error)
        {
            response.error("Could not query question!");
        }
    });
});


Parse.Cloud.define("acceptQuestion", function(request, response)
{
    Parse.Cloud.useMasterKey()

    // acceptQuestion:
    //
    //      Cloud function that accepts the question, starts the chat, and sends a push. Returns the chat message.
    //
    //  Parameters:
    //
    //      questionId - the objectId of the question object

    var Question = Parse.Object.extend("Question");

    var query = new Parse.Query(Question);
    query.include("chat");
    query.include("fromUser");
    query.include("toUser");

    query.get(request.params.questionId,
    {
        success: function(question)
        {
            var toUser = question.get("fromUser"); // these are backwards (toUser is accepting)
            var fromUser = question.get("toUser");
            var chat = question.get("chat");

            question.set("accepted", true);
            question.save();

            var chatMessage = "I liked your answer!";

            var Message = Parse.Object.extend("Message");

            var message = new Message();
            message.set("fromUser", question.get("toUser"));
            message.set("toUser", question.get("fromUser"));
            message.set("chat", chat);
            message.set("isAction", true);
            message.set("messageText", chatMessage);
            message.set("isQuestionAccept", true);
            message.set("isAccept", true);

            message.save(null,
            {
                success: function(message)
                {
                    chat.set("isAccepted", true);
                    chat.set("startedWithQuestion", false);
                    chat.relation("messages").add(message);

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
                                    alert: fromUser.get("firstName") + " accepted your chat!",
                                    chatId: chat.id,
                                    questionId: question.id,
                                    chatMessage: chatMessage,
                                    "content-available": 1,
                                    pushType: "QuestionAccepted",
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
                        error: function(chat, error) { chat.destroy(); response.error("Could not save Chat"); }
                    });
                },
                error: function(message, error) { message.destroy(); response.error("Couldn't save message"); }
            });
        },
        error: function(error) { response.error("Could not query the question"); }
    });
});
