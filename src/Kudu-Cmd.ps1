<#
.SYNOPSIS
Run a command line command within an Azure Web App via the
Kudu API interface.

.PARAMETER apiKey
The API key used to connect to the Kudu service. Too look up
the API key the following functions could be used:

    function Get-AzureRmWebAppPublishingCredentials($resourceGroupName, $webAppName, $slotName = $null){
        if ([string]::IsNullOrWhiteSpace($slotName)){
            $resourceType = "Microsoft.Web/sites/config"
            $resourceName = "$webAppName/publishingcredentials"
        }
        else{
            $resourceType = "Microsoft.Web/sites/slots/config"
            $resourceName = "$webAppName/$slotName/publishingcredentials"
        }
        $publishingCredentials = Invoke-AzureRmResourceAction -ResourceGroupName $resourceGroupName -ResourceType $resourceType -ResourceName $resourceName -Action list -ApiVersion 2015-08-01 -Force
            return $publishingCredentials
    }

    function Get-KuduApiAuthorizationHeaderValue($resourceGroupName, $webAppName, $slotName = $null){
        $publishingCredentials = Get-AzureRmWebAppPublishingCredentials $resourceGroupName $webAppName $slotName
        return ("Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $publishingCredentials.Properties.PublishingUserName, $publishingCredentials.Properties.PublishingPassword))))
    }

.PARAMETER kuduUrl
The URL of the web app with the .scm. addition to reach Kudu.
For example a web app could by my-web-app.azurewebsites.net,
the kudu URL would be my-wb-app.scm.azurewebsites.net

.PARAMETER command
The command you'd like to run on the web app server.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$apiKey,

    [Parameter(Mandatory=$true)]
    [string]$kuduUrl,

    [Parameter(Mandatory=$true)]
    [string]$command
)

$kuduApiAuthorisationToken = "Basic $apiKey"

$body = @"
{
    "command": "$command"
}
"@

Invoke-RestMethod -Method POST -Uri "$kuduUrl/api/command" `
                    -Headers @{"Authorization"=$kuduApiAuthorisationToken;"If-Match"="*"} `
                    -Body $body `
                    -ContentType "application/json"