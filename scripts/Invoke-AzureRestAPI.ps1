<#
.SYNOPSIS
Call any Azure REST API from PowerShell

.DESCRIPTION
Azure CLI, Azure PowerShell, and Terraform are not updated at the same cadence as their corresponding Azure REST API.
Using this PowerShell script, you can call any Azure REST API, and leave the hard work to the script.

.EXAMPLE
Invoke-AzureRestAPI

.INPUTS
None

.OUTPUTS
System.String

.NOTES

Create an Application Registration and grant it the required RBAC role. 
In the example below, grant the  Reader RBAC role to the Application Registration on the Root Tenant Management Group or required Azure Subscriptions.

https://learn.microsoft.com/en-us/rest/api/gettingstarted/

How to find your Azure Active Directory tenant ID: 
https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant

Use the portal to create an Azure AD application and service principal that can access resources: 
https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

#>

<# Service Principal #>
$TenantId       = "" # <insert your Tenant ID>
$ApplicationID  = "" # <insert your Application ID>
$ClientSecret   = "" # <insert the value of you created secret>

<# Global Variables #>
$Header  = @{}
$Results = @()

Function Get-BearerToken {
    <#
    .SYNOPSIS
    Return a header compatible with Invoke-RestMethod

    .DESCRIPTION
    Authenticate to Azure AD with the SPN and return a header compatible with Invoke-RestMethod

    .PARAMETER TenantId
    TenantId is a guid found through the Azure portal: https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant#find-tenant-id-through-the-azure-portal

    .PARAMETER ApplicationID
    ApplicationID is the guid of your service principal or application registration.

    .PARAMETER ClientSecret
    ClientSecret is the secret of your service principal or application registration.

    .PARAMETER Resource
    Resource is the URL to authenticate to the REST API

    .EXAMPLE
    Get-BearerToken -TenantId "99999999-9999-9999-9999-999999999999" -ApplicationID "99999999-9999-9999-9999-999999999999" -ClientSecret "asdfasdfasdfasdfasdfasdf" -Resource "https://management.core.windows.net/"

    .NOTES
    Tokens are only requested if the current one has expired
    https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

    #>
    
    Param (
        [Parameter(Mandatory = $True)] [String] $TenantId,
        [Parameter(Mandatory = $True)] [String] $ApplicationID,
        [Parameter(Mandatory = $True)] [String] $ClientSecret,
        [Parameter(Mandatory = $True)] [String] $Resource
    )
    
    $CurrentDateTime = Get-Date
    $TokenExpiresOn = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($Header.ExpiresOn))

    # Only regerate bearer token if expired
    If (!($CurrentDateTime -lt $TokenExpiresOn)) {

        # Request Body
        $RequestBody = @{
            grant_type    = 'client_credentials'
            client_id     = $ApplicationID
            client_secret = $ClientSecret
            resource      = $Resource
        }
    
        # Request Header
        Try {

            $Token = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $RequestBody

            $Header["Authorization"] = "$($Token.token_type) $($Token.access_token)"
            $Header["ExpiresOn"]     = $Token.expires_on
            $Header["Content-type"]  = "application/json"
            $Header["Cache-Control"] = ''

        } Catch {

            If($_.ErrorDetails.Message) {
                Write-Host $_.ErrorDetails.Message
            } Else {
                Write-Host $_
            }

        }
        
    }
    
}

<# 
This example returns all Azure Subscriptions that your Service Principal has access to. You can replace the Uri with any Azure REST API.
#>

# Authenticate to Azure AD with the Service Principal if the bearer token expired
Get-BearerToken -TenantId $TenantId -ApplicationID $ApplicationID -ClientSecret $ClientSecret -Resource "https://management.core.windows.net/"

# https://learn.microsoft.com/en-us/rest/api/resources/subscriptions/list?tabs=HTTP

# Get initial page
Try {

    $Results += Invoke-RestMethod -Method "GET" -Header $Header -Uri "https://management.azure.com/subscriptions?api-version=2020-01-01"
    $Pages = $Results."@nextLink"

} Catch {

    If ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message
    } Else {
        Write-Host $_
    }

}

# Get subsuquent pages
Try {

    While($Null -ne $Pages) {
        $MoreResults = Invoke-RestMethod -Method "GET" -Header $Header -Uri $Pages
        If ($Pages) {
            $Pages = $Additional."@nextLink"
        }
        $Results += $MoreResults
    }

} Catch {

    If ($_.ErrorDetails.Message) {
        Write-Host $_.ErrorDetails.Message
    } Else {
        Write-Host $_
    }

}

$Results.Value | Format-List
