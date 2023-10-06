# HelloID-Task-SA-Target-AzureActiveDirectory-AccountGrantGroupMembership
#########################################################################
# Form mapping
$formObject = @{
    UserIdentity = $form.UserIdentity
    GroupsToAdd  = $form.GroupsToAdd
}

try {
    Write-Information "Executing AzureActiveDirectory action: [AccountGrantGroupMembership] for: [$($formObject.UserIdentity)]"

    # Action logic here
    Write-Information "Retrieving Microsoft Graph AccessToken for tenant: [$AADTenantID]"
    $splatTokenParams = @{
        Uri         = "https://login.microsoftonline.com/$AADTenantID/oauth2/token"
        ContentType = 'application/x-www-form-urlencoded'
        Method      = 'POST'
        Verbose     = $false
        Body        = @{
            grant_type    = 'client_credentials'
            client_id     = $AADAppID
            client_secret = $AADAppSecret
            resource      = 'https://graph.microsoft.com'
        }
    }

    $accessToken = (Invoke-RestMethod @splatTokenParams).access_token
    $splatCreateUserParams = @{
        Uri     = "https://graph.microsoft.com/v1.0/users/$($formObject.UserIdentity)"
        Method  = 'GET'
        Verbose = $false
        Headers = @{
            Authorization  = "Bearer $accessToken"
            Accept         = 'application/json'
            'Content-Type' = 'application/json'
        }
    }
    $azureADUser = Invoke-RestMethod @splatCreateUserParams
}
catch {
    Write-Error "Could not execute AzureActiveDirectory action [AccountGrantGroupMembership] for: [$($formObject.UserIdentity)]. User not found in the directory. Error: [$($_.Exception.Message)], Details : [$($_.Exception.ErrorDetails)]"
    return
}
try {

    foreach ( $group in $formObject.GroupsToAdd) {

        try {

            $splatAddParams = @{
                Uri     = "https://graph.microsoft.com/v1.0/groups/$($group.id)/members/`$ref"
                Method  = 'POST'
                Body    = @{ '@odata.id' = "https://graph.microsoft.com/v1.0/users/$($azureADUser.id)" } | ConvertTo-Json -Depth 10
                Verbose = $false
                Headers = @{
                    Authorization  = "Bearer $accessToken"
                    Accept         = 'application/json'
                    'Content-Type' = 'application/json'
                }
            }

            $null = Invoke-RestMethod @splatAddParams
            $message = "AzureActiveDirectory action: [AccountGrantGroupMembership to group [$($group.Name)($($group.id))] ] for: [$($formObject.UserIdentity)] executed successfully"
            $auditLog = @{
                Action            = 'GrantMembership'
                System            = 'AzureActiveDirectory'
                TargetIdentifier  = "$($azureADUser.id)"
                TargetDisplayName = "$($formObject.UserIdentity)"
                Message           = $message
                IsError           = $false
            }
            Write-Information -Tags 'Audit' -MessageData $auditLog
            Write-Information $message
        }
        catch {
            $ex = $_
            if (($ex.Exception.Response) -and ($Ex.Exception.Response.StatusCode -eq 400))  {
                # 400 indicates already member
                $message = "AzureActiveDirectory action: [AccountGrantGroupMembership to group [$($group.Name)($($group.id))] ] for: [$($formObject.UserIdentity)] executed successfully"
                $auditLog = @{
                    Action            = 'GrantMembership'
                    System            = 'AzureActiveDirectory'
                    TargetIdentifier  = "$($azureADUser.id)"
                    TargetDisplayName = "$($formObject.UserIdentity)"
                    Message           = $message
                    IsError           = $false
                }
                Write-Information -Tags 'Audit' -MessageData $auditLog
                Write-Information $message

            }
            else {
                $message = "Could not execute AzureActiveDirectory action:[AccountGrantGroupMembership to group [$($group.Name)($($group.id))] ] for: [$($formObject.UserIdentity)], error: $($ex.Exception.Message), Details : [$($ex.ErrorDetails.message)]"
                $auditLog = @{
                    Action            = 'GrantMembership'
                    System            = 'AzureActiveDirectory'
                    TargetIdentifier  = "$($azureADUser.id)"
                    TargetDisplayName = "$($formObject.UserIdentity)"
                    Message           = $message
                    IsError           = $true
                }
                Write-Information -Tags "Audit" -MessageData $auditLog
                Write-Error $message
            }

        }
    }
}
catch {
    $ex = $_
    $message = "Could not execute AzureActiveDirectory action: [AccountGrantGroupMembership] for: [$($formObject.UserIdentity)], error: $($ex.Exception.Message) details : [$($ex.ErrorDetails.message)] "
    $auditLog = @{
        Action            = 'GrantMembership'
        System            = 'AzureActiveDirectory'
        TargetIdentifier  = "$($azureADUser.id)"
        TargetDisplayName = $formObject.UserIdentity
        Message           = $message
        IsError           = $true
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error  $message
}
#########################################################################
