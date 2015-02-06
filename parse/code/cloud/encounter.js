Parse.Cloud.beforeSave("Encounter", function(request, response)
{
    Parse.Cloud.useMasterKey();

    response.success();
});