var activity = require('cloud/activity.js');

var challenge = require('cloud/challenge.js');
    var createChatForChallenge = require('cloud/challenge.js');
    var acceptChallenge = require('cloud/challenge.js');
    var challengeAction = require('cloud/challenge.js');

var chat = require('cloud/chat.js');
    var revealUserInChat = require('cloud/chat.js');
    var removeUserFromChat = require('cloud/chat.js');

var encounter = require('cloud/challenge.js');

var friendRequest = require('cloud/friendRequest.js');
    var sendBatchFriendRequests = require('cloud/friendRequest.js');
    var sendFriendRequest = require('cloud/friendRequest.js');
    var acceptFriendRequest = require('cloud/friendRequest.js');
    var declineFriendRequest = require('cloud/friendRequest.js');

var image = require('cloud/image.js');
    var makeThumbnailImage = require('cloud/image.js');
    var makeMediumImage = require('cloud/image.js');

var message = require('cloud/message.js');
    var sendMessage = require('cloud/message.js');

var question = require('cloud/question.js');
    var createChatForQuestion = require('cloud/question.js');

var receipt = require('cloud/receipt.js');

var transaction = require('cloud/transaction.js');
	var spendCredits = require('cloud/transaction.js');
	var purchaseCredits = require('cloud/transaction.js');
	var sendCredits = require('cloud/transaction.js');
	var leaveCredits = require('cloud/transaction.js');

var user = require('cloud/user.js');
    var sendConfirmationCode = require('cloud/user.js');
    var checkConfirmationCode = require('cloud/user.js');
    var phoneNumberExists = require('cloud/user.js');


Parse.Cloud.define("echo", function(request, response) { response.success(); });

