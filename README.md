
# HelloID-Task-SA-Target-AzureActiveDirectory-AccountGrantGroupMembership

## Prerequisites

## Description

This code snippet executes the following tasks:

1. Define a hash table `$formObject`. The keys of the hash table represent the parameters needed for this action, while the values represent the values entered in the form.

> To view an example of the form output, please refer to the JSON code pasted below.

```json
{
    "UserIdentity": "testuser@mydomain.local",
    "GroupsToAdd": [
        {
            "Name": "testgroup1",
            "Id" : "599bba95-e5ac-45f9-a3a0-e6e2674bb7df"
        },
        {
            "Name": "testgroup2",
            "Id" : "938a3e5d-2093-4ed9-b6b9-777c144ad08d"
        }
    ]
}

```

> :exclamation: It is important to note that the names of your form fields might differ. Ensure that the `$formObject` hashtable is appropriately adjusted to match your form fields.
> [See the Microsoft Docs page](https://learn.microsoft.com/en-us/graph/api/group-post-members?view=graph-rest-1.0&tabs=http)

2. Receive a bearer token by making a POST request to: `https://login.microsoftonline.com/$AADTenantID/oauth2/token`, where `$AADTenantID` is the ID of your Azure Active Directory tenant.

3. Looks up the user in Azure by its UPN, by making a GET request to  `https://graph.microsoft.com/v1.0/users/$($formObject.userPrincipalName)`.  This is done to get the Objectid of the user in Azure.

4. For each group in the specified groups in  `GroupsToAdd` the user is added to the group. by making a POST request to  `https://graph.microsoft.com/v1.0/groups/<group.id>/members/$ref`
