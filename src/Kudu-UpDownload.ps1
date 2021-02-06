<#
.SYNOPSIS
Upload files to Azure Web Apps or download from the Web App
using the Kudu API.

.PARAMETER type
Are you going to 'upload' or 'download'

.PARAMETER kuduAuthorizationToken
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

.PARAMETER resourceGroupName
The resource group that contains the web app

.PARAMETER webAppName
Name of the web app, not the URL

.PARAMETER slotName
If you are running against a slot include the name, not the URL.
Leave this blank if there are not any slots in the app.

.PARAMETER kuduPath
The path on the azure web app to upload to or download from.

.PARAMETER localPath
The path in the context of the script to download the file
to or upload the file from. Should include the file name.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("upload","download","upload-zip")]
    [string]$type,

    [Parameter(Mandatory=$true)]
    [string]$kuduApiAuthorizationToken,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$webAppName,

    [Parameter(Mandatory=$false)]
    [string]$slotName = "",

    [Parameter(Mandatory=$true)]
    [string]$kuduPath,

    [Parameter(Mandatory=$true)]
    [string]$localPath
)

function Upload-FileToWebApp($resourceGroupName, $webAppName, $slotName = "", $localPath, $kuduPath) {

    if ($slotName -eq ""){
        $kuduApiUrl = "https://$webAppName.scm.azurewebsites.net/api/vfs/site/wwwroot/$kuduPath"
    }
    else{
        $kuduApiUrl = "https://$webAppName`-$slotName.scm.azurewebsites.net/api/vfs/site/wwwroot/$kuduPath"
    }
    $virtualPath = $kuduApiUrl.Replace(".scm.azurewebsites.", ".azurewebsites.").Replace("/api/vfs/site/wwwroot", "")
    Write-Host " Uploading Files to WebApp. Source: '$localPath'. Target: '$virtualPath'..."  -ForegroundColor DarkGray

    Invoke-RestMethod -Uri $kuduApiUrl `
                        -Headers @{"Authorization"=$kuduApiAuthorizationToken;"If-Match"="*"} `
                        -Method PUT `
                        -InFile $localPath `
                        -ContentType "multipart/form-data"
}

function Upload-ZipToWebApp($resourceGroupName, $webAppName, $slotName = "", $localPath, $kuduPath) {
    if ($slotName -eq ""){
        $kuduApiUrl = "https://$webAppName.scm.azurewebsites.net/api/zip/site/wwwroot/$kuduPath"
    }
    else{
        $kuduApiUrl = "https://$webAppName`-$slotName.scm.azurewebsites.net/api/zip/site/wwwroot/$kuduPath"
    }
    $virtualPath = $kuduApiUrl.Replace(".scm.azurewebsites.", ".azurewebsites.").Replace("/api/zip/site/wwwroot", "")
    Write-Host " Uploading File to WebApp. Source: '$localPath'. Target: '$virtualPath'..."  -ForegroundColor DarkGray

    Invoke-RestMethod -Uri $kuduApiUrl `
                        -Headers @{"Authorization"=("Basic {0}" -f $kuduApiAuthorizationToken)} `
                        -Method PUT `
                        -InFile $localPath `
                        -ContentType "multipart/form-data"
}

function Download-FileFromWebApp($resourceGroupName, $webAppName, $slotName = "", $kuduPath, $localPath) {

    if ($slotName -eq ""){
        $kuduApiUrl = "https://$webAppName.scm.azurewebsites.net/api/vfs/site/wwwroot/$kuduPath"
    }
    else{
        $kuduApiUrl = "https://$webAppName`-$slotName.scm.azurewebsites.net/api/vfs/site/wwwroot/$kuduPath"
    }
    $virtualPath = $kuduApiUrl.Replace(".scm.azurewebsites.", ".azurewebsites.").Replace("/api/vfs/site/wwwroot", "")
    Write-Host " Downloading File from WebApp. Source: '$virtualPath'. Target: '$localPath'..." -ForegroundColor DarkGray

    Invoke-RestMethod -Uri $kuduApiUrl `
                        -Headers @{"Authorization"=$kuduApiAuthorizationToken;"If-Match"="*"} `
                        -Method GET `
                        -OutFile $localPath `
                        -ContentType "multipart/form-data"
}

$params = @{resourceGroupName=$resourceGroupName;
    webAppName=$webAppName;
    slotName=$slotName;
    localPath=$localPath;
    kuduPath=$kuduPath}

switch ($type)
{
    "upload" {
        Write-Output "Requesting upload of $localPath to $kuduPath"
        Upload-FileToWebApp @params
    }
    "upload-zip" {
        Write-Output "Requesting upload of $localPath to $kuduPath"
        Upload-ZipToWebApp @params
    }
    "download" {
        Write-OutPut "Requesting download of $kuduPath to $localPath"
        Download-FileFromWebApp @params
    }
    default {
        Write-Error "Unexpected action: $type"
    }
}