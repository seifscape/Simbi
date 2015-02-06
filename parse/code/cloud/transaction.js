// Types of transactions:

var TransactionType = {
    Purchase : "Purchase",
    Share    : "Share",
    Send     : "Send",
    Receive  : "Receive",
    Leave    : "Leave",
    Spend    : "Spend"
}


Parse.Cloud.define("spendCredits", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // spendCredits:
    //
    //      When the user wants to use some feature that costs credits, this function is called
    //      first to verify that the user has enough credits, create a transaction object to
    //      document the expense, and decrement the user's credit balance.
    //
    //      If the user cannot afford this item, this function will respond with "CANNOT_AFFORD"
    //
    // Parameters:
    //
    //      amount          : The amount to spend (positive number)
    //      information     : Any addition information to describe what the credits were spent on.

    getCreditBalance(Parse.User.current(),
    {
        success: function(user, userCredits, balance)
        {
            if (balance < request.params.amount)
            {
                response.error("CANNOT_AFFORD");
            }
            else
            {
                userCredits.set("balance", balance-request.params.amount);

                var transaction = createTransaction(user, -request.params.amount, TransactionType.Spend);

                if (request.params.information != undefined)
                    transaction.set("information", request.params.information);

                saveTransaction(transaction, user,
                {
                    success: function(transaction, user)
                    {
                        response.success();
                    },
                    error: function(error)
                    {
                        response.error(error);
                    }
                });
            }
        },
        error: function(error)
        {
            response.error(error);
        }
    });
});


Parse.Cloud.define("purchaseCredits", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // purchaseCredits:
    //
    //      After a purchase has been made, this function creates a transaction object and
    //      increments the purchaser's balance.
    //
    // Parameters:
    //
    //      amount          : Amount that was purchased.
    //      receiptId       : objectId of the receipt for this payment, provided from payment vendor.
    //      information     : Any addition information to describe the purchase and how it was done.

    if (request.params.receiptId == undefined || request.params.amount == undefined)
    {
        response.error();
    }
    else
    {
        getCreditBalance(Parse.User.current(),
        {
            success: function(user, userCredits, balance)
            {
                // Query the receipt

                var Receipt = Parse.Object.extend("Receipt");

                var query = new Parse.Query(Receipt);

                query.get(request.params.receiptId,
                {
                    success: function(receipt)
                    {
                        // Increment the balance and create a transaction object

                        userCredits.set("balance", balance + request.params.amount);

                        var transaction = createTransaction(Parse.User.current(), request.params.amount, TransactionType.Purchase);

                        transaction.set("receipt", receipt);

                        if (request.params.information != undefined)
                            transaction.set("information", request.params.information);

                        saveTransaction(transaction, userCredits,
                        {
                            success: function(transaction, userCredits)
                            {
                                response.success();
                            },
                            error: function(error)
                            {
                                reportError(Parse.User.current(), request.params.receiptId, request.params.information,
                                function() {
                                    response.error(error);
                                });
                            }
                        });
                    },
                    error: function(error)
                    {
                        reportError(Parse.User.current(), request.params.receiptId, request.params.information,
                        function() {
                            response.error("Could not query receipt");
                        });
                    }
                });
            },
            error: function(error)
            {
                reportError(Parse.User.current(), request.params.receiptId, request.params.information,
                function() {
                    response.error(error);
                });
            }
        });
    }
});


Parse.Cloud.define("sendCredits", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // sendCredits:
    //
    //      This functionality needs to be defined. (Implied in the mock-up designs)

});


Parse.Cloud.define("leaveCredits", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // leaveCredits:
    //
    //      This functionality needs to be defined. (Implied in the mock-up designs)

});


function getCreditBalance(user, callback)
{
    // getCreditBalance:
    //
    //      Function that can be called to retrieve a user's balance from their UserCredits object.
    //
    //      callback:
    //          function success(user, userCredits, balance)
    //          function error(errorMessage)

    if (user != undefined)
    {
        if (user.get("credits") == undefined)
        {
            // User does not have a UserCredits object - need to create one first.

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

            userCredits.save(null, 
            {
                success: function(userCredits)
                {
                    user.set("credits", userCredits);

                    user.save(null,
                    {
                        success: function(user)
                        {
                            if (callback.success != undefined)
                                callback.success(user, userCredits, 0);
                        },
                        error: function(user, error)
                        {
                            if (callback.error != undefined)
                                callback.error("Unable to save user")
                        }
                    });

                    if (callback.success != undefined)
                        callback.success(user, userCredits, 0);
                },
                error: function(userCredits, error)
                {
                    if (callback.error != undefined)
                        callback.error("Unable to create UserCredits");
                }
            });
        }
        else
        {
            var userCredits = user.get("credits");

            userCredits.fetch(
            {
                success: function(userCredits)
                {
                    var amount = userCredits.get("balance") != undefined ? userCredits.get("balance") : 0;

                    if (callback.success != undefined)
                        callback.success(user, userCredits, amount);
                },
                error: function(userCredits, error)
                {
                    if (callback.error != undefined)
                        callback.error("Unable to fetch UserCredits");
                }
            });
        }
    }
    else 
    {
        if (callback.error != undefined)
            callback.error("getCreditBalance: user is undefined!");
    }
}


function createTransaction(user, amount, type)
{
    // createTransaction:
    //
    //      Returns a new transaction object for a given user, amount, and type. Set the ACL
    //      to deny public read and write, but allow reading for the owning user.

    var Transaction = Parse.Object.extend("Transaction");

    var transaction = new Transaction();

    transaction.set("user", user);
    transaction.set("amount", amount);
    transaction.set("type", type);

    var acl = new Parse.ACL();
    acl.setPublicWriteAccess(false);
    acl.setPublicReadAccess(false);
    acl.setReadAccess(user.id, true);

    transaction.setACL(acl);

    return transaction;
}


function saveTransaction(transaction, userCredits, callback)
{
    // saveTransaction:
    //
    //      Saves a transaction and adds it to the user's UserCredits "transactions" relation. In case of
    //      error, this function will attempt to destroy the transaction object.
    //
    //      callback:
    //          success(transaction, user)
    //          error(errorMessage)

    transaction.save(null,
    {
        success: function(transaction)
        {
            userCredits.relation("transactions").add(transaction);

            userCredits.save(null,
            {
                success: function(userCredits)
                {
                    if (callback.success != undefined)
                        callback.success(transaction, userCredits);
                },
                error: function(userCredits, error)
                {
                    // If the userCredits can't save, make sure the transaction is destroyed

                    transaction.destroy(
                    {
                        success: function(transaction)
                        {
                            if (callback.error != undefined)
                                callback.error("Unable to save userCredits - Transaction destroyed");
                        },
                        error: function(transaction, error)
                        {
                            if (callback.error != undefined)
                                callback.error("Unable to save userCredits - Transaction NOT destroyed");
                        }
                    });
                }
            });
        },
        error: function(transaction, error)
        {
            if (callback.error != undefined)
                callback.error("Could not save transaction");
        }
    });
}


function reportError(user, receiptId, information, callback)
{
    // reportError:
    //
    //      If an error occurs while trying to purchase credits, attempt to document the error.

    var TransactionError = Parse.Object.extend("TransactionError");

    var transactionError = new TransactionError();
    transactionError.set("user", user);
    transactionError.set("receiptId", receiptId);
    transactionError.set("information", information);

    var acl = new Parse.ACL();
    acl.setPublicWriteAccess(false);
    acl.setPublicReadAccess(false);

    transactionError.setACL(acl);

    transactionError.save(null,
    {
        success: function(transactionError)
        {
            if (callback != undefined)
                callback();
        },
        error: function(transactionError, error)
        {
            if (callback != undefined)
                callback();
        }
    });
}

