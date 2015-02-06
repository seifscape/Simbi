Parse.Cloud.beforeSave("Receipt", function(request, response)
{
    Parse.Cloud.useMasterKey();

    // Receipt beforeSave:
    //
    //      Locks all receipts down with ACL.
    //
    //      TODO - Validate receipts and ensure that they are authentic.

    var acl = new Parse.ACL();
    acl.setPublicWriteAccess(false);
    acl.setPublicReadAccess(false);

    request.object.setACL(acl);

    response.success();
});