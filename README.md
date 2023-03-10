
# HelloID-Task-SA-Target-AzureActiveDirectory-AccountGrantGroupMembership

## Prerequisites

## Description

This code snippet executes the following tasks:

1. Define a hash table `$formObject`. The keys of the hash table represent the parameters needed for this action, while the values represent the values entered in the form.

> To view an example of the form output, please refer to the JSON code pasted below.

```json
{
    "UserPrincipalName": "testuser@mydomain.local",
    "GroupsToAdd": [
        {
            "name": "testgroup1",
            "Id" : "599bba95-e5ac-45f9-a3a0-e6e2674bb7df"
        },
        {
            "name": "testgroup2",
            "Id" : "938a3e5d-2093-4ed9-b6b9-777c144ad08d"
        }
    ]
}

```

> :exclamation: It is important to note that the names of your form fields might differ. Ensure that the `$formObject` hashtable is appropriately adjusted to match your form fields.
